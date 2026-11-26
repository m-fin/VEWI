//
//  SaxKey.swift
//  VEWI
//
//  Keys on an alto saxophone, named the way a player talks about them.
//  Foundation only so the fingering harness can compile this without UIKit.
//

import Foundation

enum SaxKey: String, CaseIterable, Codable, Hashable {
    // Left hand
    case octave
    case l1
    case l2
    case l3
    case bis
    case gSharp
    case lowCSharp
    case lowB
    case lowBFlat
    case palmD
    case palmEFlat
    case palmF
    // Right hand
    case r1
    case r2
    case r3
    case lowEFlat
    case lowC
    // Side keys (left index on a real horn: Ta, Tc, Tf, Tf♯)
    case sideBFlat
    case sideC
    case frontE
    case chromaticFSharp

    /// Main stack, in reading order. The live diagram draws these as six dots.
    static let stack: Set<SaxKey> = [.l1, .l2, .l3, .r1, .r2, .r3]

    /// Stable order for charts and the hint line.
    static let chartOrder: [SaxKey] = [
        .octave,
        .l1, .l2, .l3, .bis,
        .r1, .r2, .r3,
        .gSharp, .lowCSharp, .lowB, .lowBFlat,
        .lowEFlat, .lowC,
        .palmD, .palmEFlat, .palmF,
        .sideBFlat, .sideC, .frontE, .chromaticFSharp
    ]

    var shortName: String {
        switch self {
        case .octave: return "Oct"
        case .l1: return "L1"
        case .l2: return "L2"
        case .l3: return "L3"
        case .bis: return "Bis"
        case .gSharp: return "G♯"
        case .lowCSharp: return "low C♯"
        case .lowB: return "low B"
        case .lowBFlat: return "low B♭"
        case .palmD: return "palm D"
        case .palmEFlat: return "palm E♭"
        case .palmF: return "palm F"
        case .r1: return "R1"
        case .r2: return "R2"
        case .r3: return "R3"
        case .lowEFlat: return "E♭"
        case .lowC: return "low C"
        case .sideBFlat: return "side B♭"
        case .sideC: return "side C"
        case .frontE: return "front E"
        case .chromaticFSharp: return "F♯ key"
        }
    }

    /// Two-line title drawn on the key itself.
    var buttonTitle: String {
        switch self {
        case .octave: return "Oct"
        case .l1: return "L1\nB"
        case .l2: return "L2\nA"
        case .l3: return "L3\nG"
        case .bis: return "Bis\nB♭"
        case .gSharp: return "G♯"
        case .lowCSharp: return "C♯"
        case .lowB: return "B"
        case .lowBFlat: return "B♭"
        case .palmD: return "Palm\nD"
        case .palmEFlat: return "Palm\nE♭"
        case .palmF: return "Palm\nF"
        case .r1: return "R1\nF"
        case .r2: return "R2\nE"
        case .r3: return "R3\nD"
        case .lowEFlat: return "E♭"
        case .lowC: return "C"
        case .sideBFlat: return "Ta\nB♭"
        case .sideC: return "Tc\nC"
        case .frontE: return "Tf\nE"
        case .chromaticFSharp: return "F♯"
        }
    }

    var family: Family {
        switch self {
        case .l1, .l2, .l3: return .leftStack
        case .r1, .r2, .r3: return .rightStack
        case .octave: return .octave
        case .bis: return .bis
        case .gSharp, .lowCSharp, .lowB, .lowBFlat, .lowEFlat, .lowC: return .pinky
        case .palmD, .palmEFlat, .palmF: return .palm
        case .sideBFlat, .sideC, .frontE, .chromaticFSharp: return .side
        }
    }

    enum Family {
        case leftStack, rightStack, octave, bis, pinky, palm, side
    }
}
