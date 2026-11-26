//
//  BreathState.swift
//  VEWI
//
//  Whether the horn is being blown, separate from which keys are down.
//  Open C♯5 is a real fingering (nothing pressed), so silence has to come
//  from releasing the breath, not from lifting a key.
//

import Foundation

enum BreathMode: Int, CaseIterable, Codable {
    case hold = 0
    case latch = 1
    case slide = 2
    case microphone = 3

    var title: String {
        switch self {
        case .hold: return "Hold"
        case .latch: return "Latch"
        case .slide: return "Slide"
        case .microphone: return "Mic"
        }
    }

    var detail: String {
        switch self {
        case .hold: return "Hold the breath pad to play. Lift it to silence, including open C♯."
        case .latch: return "Tap the breath pad to keep the air on, tap again to stop."
        case .slide: return "Touch the breath pad and slide. Higher on the pad is louder."
        case .microphone: return "Blow into the microphone. Headphones keep the speaker out of the mic."
        }
    }
}

struct BreathState: Equatable {
    var mode: BreathMode = .hold
    var padHeld: Bool = false
    var latched: Bool = false
    /// 0 = finger is off the slider. Above 0 the note sounds, up to 1.
    var slideLevel: Double = 0
    /// 0...1 after the noise gate. The mic sets this; 0 is silence.
    var micLevel: Double = 0

    var expression: Double {
        switch mode {
        case .hold:
            return padHeld ? 1 : 0
        case .latch:
            return latched ? 1 : 0
        case .slide:
            return min(max(slideLevel, 0), 1)
        case .microphone:
            return min(max(micLevel, 0), 1)
        }
    }

    var isBlowing: Bool { return expression > 0.01 }

    mutating func toggleLatch() {
        latched.toggle()
    }
}
