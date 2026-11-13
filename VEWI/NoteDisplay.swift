//
//  NoteDisplay.swift
//  VEWI
//
//  Note names and pitches for the on-screen note display and the fingering chart.
//  Notes are counted in semitones from written C4 (0 = C4), like getSaxNote().
//  Foundation only so tools/fingering-check can test it.
//

import Foundation

enum NoteDisplay {
    static let names = ["C", "C\u{266F}", "D", "E\u{266D}", "E", "F", "F\u{266F}", "G", "G\u{266F}", "A", "B\u{266D}", "B"]

    //"G4" for 7, "B\u{266D}2" for -14
    static func name(_ semitonesFromC4: Int) -> String {
        let pitchClass = ((semitonesFromC4 % 12) + 12) % 12
        let octave = 4 + Int((Double(semitonesFromC4) / 12.0).rounded(.down))
        return "\(names[pitchClass])\(octave)"
    }

    //The note that actually sounds for a written note, after transposition and octave shift
    static func sounding(written: Int, transposition: Transposition, octaveShift: Int) -> Int {
        return written + transposition.semitones + 12 * octaveShift
    }

    //Same equal-temperament formula as GameScene.finalPitch: C4 = 261.63 Hz
    static func frequency(written: Int, transposition: Transposition, octaveShift: Int) -> Double {
        let n = sounding(written: written, transposition: transposition, octaveShift: octaveShift)
        return 261.63 * pow(2.0, Double(n) / 12.0)
    }

    //Text for the playing screen, e.g. "G4 · 392.0 Hz" or "G4 · sounds B\u{266D}3 · 233.1 Hz". Empty when silent.
    static func text(written: Int, transposition: Transposition, octaveShift: Int) -> String {
        guard written >= 0 else { return "" }
        let hz = String(format: "%.1f Hz", frequency(written: written, transposition: transposition, octaveShift: octaveShift))
        let sound = sounding(written: written, transposition: transposition, octaveShift: octaveShift)
        if sound == written {
            return "\(name(written)) \u{00B7} \(hz)"
        }
        return "\(name(written)) \u{00B7} sounds \(name(sound)) \u{00B7} \(hz)"
    }
}
