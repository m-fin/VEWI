//
//  SaxSynth.swift
//  VEWI
//
//  Low-latency wind synth on AVAudioEngine. No third-party audio frameworks.
//

import AVFoundation
import os

final class SaxSynth {
    private let engine = AVAudioEngine()
    private var source: AVAudioSourceNode?
    private let state = OSAllocatedUnfairLock(initialState: EngineState())
    private var micTapInstalled = false
    private(set) var isRunning = false

    private struct EngineState {
        var voice = VoiceState.fresh()
        var volume = 1.0
        var preset = SoundPreset.warmReed
        var glide = 0.05
        var vibrato = true
        var useMic = false
        var micExpression = 0.0
        var fingerExpression = 0.0
        var frequency = 440.0
        var meter = 0.0
    }

    func prepare(settings: SaxSettings) {
        state.withLock { engineState in
            engineState.volume = settings.volume
            engineState.preset = settings.preset
            engineState.glide = settings.rampDuration
            engineState.vibrato = settings.vibrato
        }
    }

    func start() {
        restart()
    }

    func stop() {
        if micTapInstalled {
            engine.inputNode.removeTap(onBus: 0)
            micTapInstalled = false
        }
        engine.stop()
        if let source {
            engine.detach(source)
            self.source = nil
        }
        isRunning = false
    }

    /// Turns the input tap on or off. Restarts the engine so the session category matches.
    func setMicEnabled(_ enabled: Bool) {
        let unchanged = state.withLock { engineState -> Bool in
            let same = engineState.useMic == enabled && isRunning && micTapInstalled == enabled
            engineState.useMic = enabled
            return same
        }
        if unchanged { return }
        restart()
    }

    /// `expression` is 0...1 from the breath pad. Microphone mode ignores it and uses the input level.
    func play(frequency: Double, expression: Double, settings: SaxSettings) {
        state.withLock { engineState in
            engineState.volume = settings.volume
            engineState.preset = settings.preset
            engineState.glide = settings.rampDuration
            engineState.vibrato = settings.vibrato
            engineState.fingerExpression = min(max(expression, 0), 1)
            if frequency.isFinite && frequency > 0 {
                engineState.frequency = frequency
            }
        }
    }

    func silence() {
        state.withLock { engineState in
            engineState.fingerExpression = 0
            engineState.micExpression = 0
            engineState.meter = 0
        }
    }

    func meterLevel() -> Double {
        return state.withLock { $0.meter }
    }

    // MARK: - Graph

    private func restart() {
        let mic = state.withLock { $0.useMic }
        stop()
        do {
            try configureSession(mic: mic)
            try buildGraph(mic: mic)
            isRunning = true
        } catch {
            NSLog("VEWI audio failed: \(error.localizedDescription)")
        }
    }

    private func configureSession(mic: Bool) throws {
        let session = AVAudioSession.sharedInstance()
        if mic {
            try session.setCategory(.playAndRecord, mode: .measurement, options: [.defaultToSpeaker])
        } else {
            try session.setCategory(.playback, mode: .measurement, options: [.mixWithOthers])
        }
        try session.setPreferredIOBufferDuration(0.005)
        try session.setActive(true)
    }

    private func buildGraph(mic: Bool) throws {
        let sessionRate = AVAudioSession.sharedInstance().sampleRate
        let sampleRate = sessionRate > 0 ? sessionRate : 44_100
        guard let format = AVAudioFormat(standardFormatWithSampleRate: sampleRate, channels: 2) else { return }
        state.withLock { $0.voice.sampleRate = sampleRate }

        let lock = state
        let source = AVAudioSourceNode(format: format) { [lock] _, _, frameCount, audioBufferList -> OSStatus in
            let buffers = UnsafeMutableAudioBufferListPointer(audioBufferList)
            let frames = Int(frameCount)
            lock.withLock { engineState in
                let expression = engineState.useMic ? engineState.micExpression : engineState.fingerExpression
                let targetAmp = expression * engineState.volume * engineState.preset.outputGain
                let wasSilent = engineState.voice.targetAmp < 0.0001 && engineState.voice.currentAmp < 0.02
                engineState.voice.targetHz = max(20, engineState.frequency)
                if wasSilent && targetAmp > 0 {
                    engineState.voice.currentHz = engineState.voice.targetHz
                    engineState.voice.samplesSinceOn = 0
                }
                engineState.voice.targetAmp = targetAmp
                engineState.voice.glide = engineState.glide
                engineState.voice.attack = engineState.preset.attack
                engineState.voice.release = engineState.preset.release
                engineState.voice.preset = engineState.preset
                engineState.voice.vibratoSemitones = engineState.vibrato ? engineState.preset.vibratoSemitones : 0
                engineState.voice.sampleRate = sampleRate

                var pointers: [UnsafeMutablePointer<Float>] = []
                pointers.reserveCapacity(buffers.count)
                for buffer in buffers {
                    guard let data = buffer.mData else { continue }
                    pointers.append(data.assumingMemoryBound(to: Float.self))
                }
                for frame in 0..<frames {
                    let sample = Float(SynthDSP.step(&engineState.voice))
                    for pointer in pointers {
                        pointer[frame] = sample
                    }
                }
            }
            return 0
        }
        self.source = source
        engine.attach(source)
        engine.connect(source, to: engine.mainMixerNode, format: format)
        engine.prepare()
        try engine.start()
        if mic {
            installMicTap()
        }
    }

    private func installMicTap() {
        let input = engine.inputNode
        let format = input.outputFormat(forBus: 0)
        guard format.sampleRate > 0, format.channelCount > 0 else { return }
        input.installTap(onBus: 0, bufferSize: 256, format: format) { [state] buffer, _ in
            guard let channel = buffer.floatChannelData?[0] else { return }
            let count = Int(buffer.frameLength)
            guard count > 0 else { return }
            var sum = 0.0
            for index in 0..<count {
                let sample = Double(channel[index])
                sum += sample * sample
            }
            let rms = (sum / Double(count)).squareRoot()
            let level = min(1, max(0, (rms - 0.02) / 0.15))
            state.withLock { engineState in
                engineState.micExpression = level
                engineState.meter = level
            }
        }
        micTapInstalled = true
    }
}
