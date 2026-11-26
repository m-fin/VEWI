//
//  SynthDSP.swift
//  VEWI
//
//  One sample of the wind synth: portamento, a click-free amplitude envelope,
//  and a little delayed vibrato. The iOS engine runs this inside AVAudioSourceNode.
//

import Foundation
#if canImport(Darwin)
import Darwin
#elseif canImport(Glibc)
import Glibc
#endif

struct VoiceState: Equatable {
    var currentHz: Double
    var targetHz: Double
    var currentAmp: Double
    var targetAmp: Double
    var phase: Double
    var vibratoPhase: Double
    var glide: Double
    var attack: Double
    var release: Double
    var sampleRate: Double
    var preset: SoundPreset
    var vibratoSemitones: Double
    var samplesSinceOn: Double

    static func fresh(sampleRate: Double = 48_000) -> VoiceState {
        return VoiceState(
            currentHz: 440, targetHz: 440,
            currentAmp: 0, targetAmp: 0,
            phase: 0, vibratoPhase: 0,
            glide: 0.05, attack: 0.03, release: 0.08,
            sampleRate: sampleRate,
            preset: .warmReed,
            vibratoSemitones: 0.15,
            samplesSinceOn: 0
        )
    }
}

enum SynthDSP {
    static func step(_ voice: inout VoiceState) -> Double {
        let sampleRate = max(voice.sampleRate, 1)
        let rising = voice.targetAmp > voice.currentAmp
        let tau = max(rising ? voice.attack : voice.release, 0.001)
        let ampCoeff = exp(-1.0 / (sampleRate * tau))
        voice.currentAmp = voice.targetAmp + (voice.currentAmp - voice.targetAmp) * ampCoeff
        // Inaudible tails snap to zero so a released note cannot hang.
        if abs(voice.currentAmp) < 1e-5 { voice.currentAmp = 0 }

        if voice.glide < 0.001 {
            voice.currentHz = voice.targetHz
        } else {
            let glideCoeff = exp(-1.0 / (sampleRate * voice.glide))
            voice.currentHz = voice.targetHz + (voice.currentHz - voice.targetHz) * glideCoeff
        }

        let sounding = voice.currentAmp > 0.0001
        voice.samplesSinceOn = sounding ? voice.samplesSinceOn + 1 : 0

        var vibrato = 0.0
        if voice.vibratoSemitones > 0 && sounding {
            let ramp = min(1, voice.samplesSinceOn / (sampleRate * 0.35))
            vibrato = voice.vibratoSemitones * ramp
        }
        voice.vibratoPhase += 5.2 / sampleRate
        if voice.vibratoPhase >= 1 { voice.vibratoPhase -= floor(voice.vibratoPhase) }
        let hz = max(20, voice.currentHz * pow(2, sin(2 * Double.pi * voice.vibratoPhase) * vibrato / 12))

        let delta = hz / sampleRate
        voice.phase += delta
        if voice.phase >= 1 { voice.phase -= floor(voice.phase) }
        return waveform(voice.phase, dt: delta, preset: voice.preset) * voice.currentAmp
    }

    static func waveform(_ phase: Double, dt: Double, preset: SoundPreset) -> Double {
        let p = phase - floor(phase)
        switch preset {
        case .sine:
            return sin(2 * Double.pi * p)
        case .triangle:
            return p < 0.5 ? (4 * p - 1) : (3 - 4 * p)
        case .saw:
            return (2 * p - 1) - polyBLEP(p, dt: dt)
        case .square:
            var sample = p < 0.5 ? 1.0 : -1.0
            sample += polyBLEP(p, dt: dt)
            let shifted = p + 0.5
            let wrapped = shifted - floor(shifted)
            sample -= polyBLEP(wrapped, dt: dt)
            return sample * 0.7
        case .warmReed:
            let fundamental = sin(2 * Double.pi * p)
            let second = sin(4 * Double.pi * p)
            let third = sin(6 * Double.pi * p)
            let fourth = sin(8 * Double.pi * p)
            return (0.70 * fundamental + 0.22 * second + 0.14 * third + 0.06 * fourth) / 1.12
        case .brightLead:
            let saw = (2 * p - 1) - polyBLEP(p, dt: dt)
            let fundamental = sin(2 * Double.pi * p)
            return 0.62 * saw + 0.38 * fundamental
        case .subtone:
            return 0.92 * sin(2 * Double.pi * p) + 0.08 * sin(4 * Double.pi * p)
        }
    }

    /// Polynomial band-limited step, so saw and square don't click at the wrap.
    private static func polyBLEP(_ t: Double, dt: Double) -> Double {
        let width = min(max(dt, 1e-5), 0.5)
        if t < width {
            let x = t / width
            return x + x - x * x - 1
        }
        if t > 1 - width {
            let x = (t - 1) / width
            return x * x + x + x + 1
        }
        return 0
    }
}
