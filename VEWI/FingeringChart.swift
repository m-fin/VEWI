//
//  FingeringChart.swift
//  VEWI
//
//  Every fingering the app understands, written pitch -> keys to hold.
//  tools/fingering-check plays each one through getSaxNote() to keep this in sync.
//  Keys 1-5 are the left column, 6-10 the right column (key 1 / key 6 at the bottom).
//

import Foundation

struct Fingering {
    let note: Int       //semitones from written C4
    let keys: [Int]     //1-10
    let label: String?  //e.g. "alternate"
}

enum FingeringChart {
    static let low: [Fingering] = [
        Fingering(note: 0, keys: [6, 7, 8, 10], label: nil),
        Fingering(note: 1, keys: [4, 6, 7, 8, 10], label: nil),
        Fingering(note: 2, keys: [6, 7, 8], label: nil),
        Fingering(note: 3, keys: [6, 7, 8, 9], label: nil),
        Fingering(note: 4, keys: [6, 7], label: nil),
        Fingering(note: 5, keys: [6], label: nil),
        Fingering(note: 6, keys: [7], label: nil),
        Fingering(note: 7, keys: [1, 2, 3], label: nil),
        Fingering(note: 8, keys: [1, 2, 3, 4], label: nil),
        Fingering(note: 9, keys: [1, 2], label: nil),
        Fingering(note: 10, keys: [1, 6], label: nil),
        Fingering(note: 10, keys: [1, 2, 6], label: "alternate"),
        Fingering(note: 11, keys: [1], label: nil),
        Fingering(note: 12, keys: [2], label: nil),
        Fingering(note: 13, keys: [3], label: nil)
    ]

    //Upper register: left-column notes add right key 3 (key 8), right-column notes add left key 3
    static let high: [Fingering] = [
        Fingering(note: 14, keys: [3, 6, 7, 8], label: nil),
        Fingering(note: 15, keys: [3, 6, 7, 8, 9], label: nil),
        Fingering(note: 16, keys: [3, 6, 7], label: nil),
        Fingering(note: 17, keys: [3, 6], label: nil),
        Fingering(note: 18, keys: [3, 7], label: nil),
        Fingering(note: 19, keys: [1, 2, 3, 8], label: nil),
        Fingering(note: 20, keys: [1, 2, 3, 4, 8], label: nil),
        Fingering(note: 21, keys: [1, 2, 8], label: nil),
        Fingering(note: 22, keys: [1, 6, 8], label: nil),
        Fingering(note: 23, keys: [1, 8], label: nil),
        Fingering(note: 24, keys: [2, 8], label: nil),
        Fingering(note: 25, keys: [3, 8], label: nil),
        Fingering(note: 26, keys: [1, 3, 8], label: nil)
    ]

    static var all: [Fingering] { return low + high }

    //"Left 1 2 3  |  Right 1 2" (each column counted 1-5 from the bottom)
    static func keyText(_ keys: [Int]) -> String {
        let left = keys.filter { $0 >= 1 && $0 <= 5 }.sorted().map { String($0) }
        let right = keys.filter { $0 >= 6 && $0 <= 10 }.sorted().map { String($0 - 5) }
        let l = left.isEmpty ? "\u{2013}" : left.joined(separator: " ")
        let r = right.isEmpty ? "\u{2013}" : right.joined(separator: " ")
        return "Left \(l)  |  Right \(r)"
    }
}
