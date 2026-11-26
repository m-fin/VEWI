//
//  Pitch.swift
//  VEWI
//
//  Equal temperament. Concert C4 is 261.63 Hz, so concert A4 is 440 Hz.
//

import Foundation

enum Pitch {
    static let c4 = 261.63

    static func frequency(semitonesFromC4: Int) -> Double {
        return c4 * pow(2.0, Double(semitonesFromC4) / 12.0)
    }
}
