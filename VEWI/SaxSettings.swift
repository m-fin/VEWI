//
//  SaxSettings.swift
//  VEWI
//
//  All user settings in one place, saved in UserDefaults.
//  Foundation only (no UIKit/AudioKit) so tools/fingering-check can test it.
//

import Foundation

//Which instrument key the app reads in. Raw values match the old settings screen's segment indexes.
enum Transposition: Int, CaseIterable {
    case concert = 0
    case bb = 1
    case eb = 2

    //Semitones from written to sounding pitch (Bb: down a major 2nd, Eb alto: down a major 6th)
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
}

//Oscillator shape. Raw values match the old settings screen's segment indexes.
enum Waveform: Int, CaseIterable {
    case sine = 0
    case sawtooth = 1
    case square = 2
    case triangle = 3

    var title: String {
        switch self {
        case .sine: return "Sine"
        case .sawtooth: return "Saw"
        case .square: return "Square"
        case .triangle: return "Triangle"
        }
    }
}

struct SaxSettings: Equatable {
    var transposition: Transposition = .concert
    var octaveShift: Int = 0            //whole octaves, -2...2
    var waveform: Waveform = .sine
    var volume: Double = 1.0            //0...1
    var rampDuration: Double = 0.05     //seconds, 0...1 (glide between notes)
    var showFingeringChart: Bool = false

    static let octaveRange = -2...2

    //UserDefaults keys. The first three are the keys the app already used, so saved settings carry over.
    enum Keys {
        static let transposition = "Transposition_Value_Index"
        static let octave = "Octave_Value"
        static let waveform = "Waveform_Value_Index"
        static let volume = "Volume_Value"
        static let rampDuration = "Ramp_Duration_Value"
        static let showFingeringChart = "Show_Fingering_Chart"
    }

    //Posted after settings are saved so the playing screen can update its sound
    static let didChangeNotification = Notification.Name("SaxSettingsDidChange")

    static func load(from defaults: UserDefaults = .standard) -> SaxSettings {
        var s = SaxSettings()
        s.transposition = Transposition(rawValue: defaults.integer(forKey: Keys.transposition)) ?? .concert
        s.octaveShift = Int(defaults.double(forKey: Keys.octave).rounded())
        s.waveform = Waveform(rawValue: defaults.integer(forKey: Keys.waveform)) ?? .sine
        if defaults.object(forKey: Keys.volume) != nil { s.volume = defaults.double(forKey: Keys.volume) }
        if defaults.object(forKey: Keys.rampDuration) != nil { s.rampDuration = defaults.double(forKey: Keys.rampDuration) }
        s.showFingeringChart = defaults.bool(forKey: Keys.showFingeringChart)
        return s.clamped()
    }

    func save(to defaults: UserDefaults = .standard) {
        let s = clamped()
        defaults.set(s.transposition.rawValue, forKey: Keys.transposition)
        defaults.set(Double(s.octaveShift), forKey: Keys.octave)
        defaults.set(s.waveform.rawValue, forKey: Keys.waveform)
        defaults.set(s.volume, forKey: Keys.volume)
        defaults.set(s.rampDuration, forKey: Keys.rampDuration)
        defaults.set(s.showFingeringChart, forKey: Keys.showFingeringChart)
    }

    //Keeps every value in its allowed range
    func clamped() -> SaxSettings {
        var s = self
        s.octaveShift = min(max(s.octaveShift, SaxSettings.octaveRange.lowerBound), SaxSettings.octaveRange.upperBound)
        s.volume = min(max(s.volume, 0), 1)
        s.rampDuration = min(max(s.rampDuration, 0), 1)
        return s
    }
}
