//
//  SaxSettings.swift
//  VEWI
//
//  All user settings in one place, saved in UserDefaults.
//  Foundation only (no UIKit) so tools/fingering-check can test it.
//

import Foundation

/// Which instrument key the app reads in. Raw values match the old settings screen.
enum Transposition: Int, CaseIterable, Codable {
    case concert = 0
    case bb = 1
    case eb = 2

    /// Semitones from written to sounding pitch.
    /// B♭ (tenor/soprano): down a major 2nd. E♭ (alto): down a major 6th.
    var semitones: Int {
        switch self {
        case .concert: return 0
        case .bb: return -2
        case .eb: return -9
        }
    }

    var title: String {
        switch self {
        case .concert: return "Concert"
        case .bb: return "B\u{266D}"
        case .eb: return "E\u{266D}"
        }
    }

    var detail: String {
        switch self {
        case .concert: return "Written pitch sounds as written."
        case .bb: return "Tenor or soprano. Written C sounds B♭."
        case .eb: return "Alto. Written A sounds concert C."
        }
    }
}

/// Sax-inspired presets plus the plain oscillator shapes.
/// The old waveform control (0 sine, 1 saw, 2 square, 3 triangle) migrates into these.
enum SoundPreset: Int, CaseIterable, Codable {
    case warmReed = 0
    case brightLead = 1
    case subtone = 2
    case sine = 3
    case saw = 4
    case square = 5
    case triangle = 6

    var title: String {
        switch self {
        case .warmReed: return "Warm Reed"
        case .brightLead: return "Bright Lead"
        case .subtone: return "Subtone"
        case .sine: return "Sine"
        case .saw: return "Saw"
        case .square: return "Square"
        case .triangle: return "Triangle"
        }
    }

    var detail: String {
        switch self {
        case .warmReed: return "Alto synth"
        case .brightLead: return "EWI lead"
        case .subtone: return "Soft, fundamental-heavy"
        case .sine: return "Pure sine"
        case .saw: return "Pure saw"
        case .square: return "Pure square"
        case .triangle: return "Pure triangle"
        }
    }

    /// Keeps the presets at a similar loudness. Saw and square are much hotter than sine.
    var outputGain: Double {
        switch self {
        case .warmReed: return 0.55
        case .brightLead: return 0.28
        case .subtone: return 0.62
        case .sine: return 0.50
        case .saw: return 0.22
        case .square: return 0.18
        case .triangle: return 0.40
        }
    }

    var attack: Double {
        switch self {
        case .warmReed: return 0.035
        case .brightLead: return 0.02
        case .subtone: return 0.06
        case .sine, .saw, .square, .triangle: return 0.015
        }
    }

    var release: Double {
        switch self {
        case .warmReed: return 0.09
        case .brightLead: return 0.06
        case .subtone: return 0.14
        case .sine, .saw, .square, .triangle: return 0.05
        }
    }

    /// Semitones of delayed vibrato. Zero when the player turns vibrato off.
    var vibratoSemitones: Double {
        switch self {
        case .warmReed: return 0.18
        case .brightLead: return 0.12
        case .subtone: return 0.08
        case .sine, .saw, .square, .triangle: return 0.06
        }
    }

    static func fromLegacyWaveform(_ index: Int) -> SoundPreset {
        switch index {
        case 1: return .saw
        case 2: return .square
        case 3: return .triangle
        default: return .sine
        }
    }
}

struct SaxSettings: Equatable {
    var transposition: Transposition = .eb
    var octaveShift: Int = 0
    var preset: SoundPreset = .warmReed
    var volume: Double = 1.0
    var rampDuration: Double = 0.05
    var vibrato: Bool = true
    var breathMode: BreathMode = .hold
    var showFingeringChart: Bool = false
    var showNoteName: Bool = true
    var showFingeringHint: Bool = false

    static let octaveRange = -2...2

    enum Keys {
        static let transposition = "Transposition_Value_Index"
        static let octave = "Octave_Value"
        static let waveform = "Waveform_Value_Index"
        static let preset = "Sound_Preset"
        static let volume = "Volume_Value"
        static let rampDuration = "Ramp_Duration_Value"
        static let vibrato = "Vibrato_Enabled"
        static let breath = "Breath_Mode"
        static let showFingeringChart = "Show_Fingering_Chart"
        static let showNoteName = "Show_Note_Name"
        static let showFingeringHint = "Show_Fingering_Hint"
    }

    static let didChangeNotification = Notification.Name("SaxSettingsDidChange")

    static func load(from defaults: UserDefaults = .standard) -> SaxSettings {
        var settings = SaxSettings()
        if defaults.object(forKey: Keys.transposition) != nil {
            settings.transposition = Transposition(rawValue: defaults.integer(forKey: Keys.transposition)) ?? .eb
        }
        if defaults.object(forKey: Keys.octave) != nil {
            settings.octaveShift = Int(defaults.double(forKey: Keys.octave).rounded())
        }
        if defaults.object(forKey: Keys.preset) != nil {
            settings.preset = SoundPreset(rawValue: defaults.integer(forKey: Keys.preset)) ?? .warmReed
        } else if defaults.object(forKey: Keys.waveform) != nil {
            settings.preset = SoundPreset.fromLegacyWaveform(defaults.integer(forKey: Keys.waveform))
        }
        if defaults.object(forKey: Keys.volume) != nil { settings.volume = defaults.double(forKey: Keys.volume) }
        if defaults.object(forKey: Keys.rampDuration) != nil { settings.rampDuration = defaults.double(forKey: Keys.rampDuration) }
        if defaults.object(forKey: Keys.vibrato) != nil { settings.vibrato = defaults.bool(forKey: Keys.vibrato) }
        if defaults.object(forKey: Keys.breath) != nil {
            settings.breathMode = BreathMode(rawValue: defaults.integer(forKey: Keys.breath)) ?? .hold
        }
        settings.showFingeringChart = defaults.bool(forKey: Keys.showFingeringChart)
        if defaults.object(forKey: Keys.showNoteName) != nil {
            settings.showNoteName = defaults.bool(forKey: Keys.showNoteName)
        }
        if defaults.object(forKey: Keys.showFingeringHint) != nil {
            settings.showFingeringHint = defaults.bool(forKey: Keys.showFingeringHint)
        }
        return settings.clamped()
    }

    func save(to defaults: UserDefaults = .standard) {
        let settings = clamped()
        defaults.set(settings.transposition.rawValue, forKey: Keys.transposition)
        defaults.set(Double(settings.octaveShift), forKey: Keys.octave)
        defaults.set(settings.preset.rawValue, forKey: Keys.preset)
        defaults.set(settings.volume, forKey: Keys.volume)
        defaults.set(settings.rampDuration, forKey: Keys.rampDuration)
        defaults.set(settings.vibrato, forKey: Keys.vibrato)
        defaults.set(settings.breathMode.rawValue, forKey: Keys.breath)
        defaults.set(settings.showFingeringChart, forKey: Keys.showFingeringChart)
        defaults.set(settings.showNoteName, forKey: Keys.showNoteName)
        defaults.set(settings.showFingeringHint, forKey: Keys.showFingeringHint)
    }

    func clamped() -> SaxSettings {
        var settings = self
        settings.octaveShift = min(max(settings.octaveShift, SaxSettings.octaveRange.lowerBound), SaxSettings.octaveRange.upperBound)
        settings.volume = min(max(settings.volume, 0), 1)
        settings.rampDuration = min(max(settings.rampDuration, 0), 1)
        return settings
    }
}
