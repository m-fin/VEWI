//
//  FingeringChart.swift
//  VEWI
//
//  Every real alto fingering VEWI plays, from written B♭3 to F♯6.
//  The fingering harness plays each one through FingeringEngine.
//

import Foundation

struct Fingering: Equatable {
    var note: Int
    var keys: [SaxKey]
    var label: String?
    var section: Section

    enum Section: String, CaseIterable {
        case low = "Low register · B♭3–C♯5"
        case octave = "Octave key · D5–C♯6"
        case palm = "Palm keys · D6–F♯6"
    }
}

enum FingeringChart {
    /// First register, including the alternates a player actually uses.
    static let low: [Fingering] = [
        Fingering(note: -2, keys: [.l1, .l2, .l3, .r1, .r2, .r3, .lowBFlat], label: nil, section: .low),
        Fingering(note: -1, keys: [.l1, .l2, .l3, .r1, .r2, .r3, .lowB], label: nil, section: .low),
        Fingering(note: 0, keys: [.l1, .l2, .l3, .r1, .r2, .r3, .lowC], label: nil, section: .low),
        Fingering(note: 1, keys: [.l1, .l2, .l3, .r1, .r2, .r3, .lowCSharp], label: nil, section: .low),
        Fingering(note: 2, keys: [.l1, .l2, .l3, .r1, .r2, .r3], label: nil, section: .low),
        Fingering(note: 3, keys: [.l1, .l2, .l3, .r1, .r2, .r3, .lowEFlat], label: nil, section: .low),
        Fingering(note: 4, keys: [.l1, .l2, .l3, .r1, .r2], label: nil, section: .low),
        Fingering(note: 5, keys: [.l1, .l2, .l3, .r1], label: nil, section: .low),
        Fingering(note: 6, keys: [.l1, .l2, .l3, .r2], label: nil, section: .low),
        Fingering(note: 6, keys: [.l1, .l2, .l3, .r1, .chromaticFSharp], label: "chromatic", section: .low),
        Fingering(note: 7, keys: [.l1, .l2, .l3], label: nil, section: .low),
        Fingering(note: 8, keys: [.l1, .l2, .l3, .gSharp], label: nil, section: .low),
        Fingering(note: 9, keys: [.l1, .l2], label: nil, section: .low),
        Fingering(note: 10, keys: [.l1, .bis], label: nil, section: .low),
        Fingering(note: 10, keys: [.l1, .r1], label: "1+1", section: .low),
        Fingering(note: 10, keys: [.l1, .sideBFlat], label: "side", section: .low),
        Fingering(note: 11, keys: [.l1], label: nil, section: .low),
        Fingering(note: 12, keys: [.l2], label: nil, section: .low),
        Fingering(note: 12, keys: [.l1, .sideC], label: "side", section: .low),
        Fingering(note: 13, keys: [], label: nil, section: .low)
    ]

    /// Same fingerings with the octave key, from D5 to C♯6. Bell notes stay put.
    static let octave: [Fingering] = low.filter { $0.note >= 2 }.map { fingering in
        Fingering(note: fingering.note + 12,
                  keys: fingering.keys + [.octave],
                  label: fingering.label,
                  section: .octave)
    }

    static let palm: [Fingering] = [
        Fingering(note: 26, keys: [.octave, .l1, .l2, .l3, .r1, .r2, .r3, .palmD], label: nil, section: .palm),
        Fingering(note: 27, keys: [.octave, .l1, .l2, .l3, .r1, .r2, .r3, .palmD, .palmEFlat], label: nil, section: .palm),
        Fingering(note: 28, keys: [.octave, .l1, .l2, .l3, .r1, .r2, .palmD], label: nil, section: .palm),
        Fingering(note: 28, keys: [.octave, .l1, .l2, .l3, .r1, .r2, .r3, .frontE], label: "front E", section: .palm),
        Fingering(note: 29, keys: [.octave, .l1, .l2, .l3, .r1, .r2, .r3, .palmD, .palmEFlat, .palmF], label: nil, section: .palm),
        Fingering(note: 29, keys: [.octave, .l1, .l2, .l3, .r1, .palmD, .palmEFlat], label: "half palm", section: .palm),
        Fingering(note: 30, keys: [.octave, .l1, .l2, .l3, .r2, .palmD, .palmEFlat, .palmF], label: nil, section: .palm),
        Fingering(note: 30, keys: [.octave, .l1, .l2, .l3, .r1, .chromaticFSharp, .palmD, .palmEFlat, .palmF], label: "chromatic", section: .palm)
    ]

    static var all: [Fingering] { return low + octave + palm }

    /// One canonical fingering per written note, for the widget and the chart's "today" pick.
    static var daily: [Fingering] { return all.filter { $0.label == nil } }

    static var sections: [(title: String, rows: [Fingering])] {
        return Fingering.Section.allCases.map { section in
            (section.rawValue, all.filter { $0.section == section })
        }
    }

    static func keyText(_ keys: [SaxKey]) -> String {
        let held = Set(keys)
        let names = SaxKey.chartOrder.filter { held.contains($0) }.map { $0.shortName }
        return names.isEmpty ? "open" : names.joined(separator: " ")
    }

    /// Six stack dots plus any extra keys, for the playing-screen hint.
    /// "Oct  ●●● ●●●  palm D" — filled dots are down.
    static func diagram(_ keys: Set<SaxKey>) -> String {
        func dot(_ key: SaxKey) -> String { return keys.contains(key) ? "●" : "○" }
        let oct = keys.contains(.octave) ? "Oct" : "oct"
        let stack = "\(dot(.l1))\(dot(.l2))\(dot(.l3)) \(dot(.r1))\(dot(.r2))\(dot(.r3))"
        let extras = SaxKey.chartOrder.filter { key in
            keys.contains(key) && key != .octave && !SaxKey.stack.contains(key)
        }.map { $0.shortName }
        if extras.isEmpty { return "\(oct)  \(stack)" }
        return "\(oct)  \(stack)  \(extras.joined(separator: " "))"
    }
}
