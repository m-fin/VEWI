//
//  FingeringEngine.swift
//  VEWI
//
//  Written-pitch fingerings for alto saxophone, B♭3 through F♯6.
//  The main stack follows the horn: the first open tone hole wins, with the
//  real cross-fingerings (open C♯, C, B, bis / side / 1+1 B♭, fork and
//  chromatic F♯) called out on their own. The G♯ touchpiece is articulated,
//  so a parked left pinky does not sharpen F, E, or D. Bell notes ignore the
//  octave key. Palm keys and the front-E key (Tf) only speak in the octave
//  register.
//

import Foundation

enum FingeringEngine {
    /// Semitones from written C4, or nil when the player is not blowing.
    static func writtenNote(holding keys: Set<SaxKey>, blowing: Bool) -> Int? {
        guard blowing else { return nil }
        return fingeredNote(keys)
    }

    /// The note the fingers spell, whether or not there is air.
    /// Empty hands are open C♯5 (13), not silence.
    static func fingeredNote(_ keys: Set<SaxKey>) -> Int {
        if let high = palmNote(keys) { return high }
        let base = stackNote(keys)
        if keys.contains(.octave) && base >= 2 { return base + 12 }
        return base
    }

    // MARK: - Palm register (D6–F♯6), octave key required

    private static func palmNote(_ keys: Set<SaxKey>) -> Int? {
        guard keys.contains(.octave) else { return nil }
        guard keys.contains(.l1), keys.contains(.l2), keys.contains(.l3) else { return nil }
        // A bell key is doing the talking; don't also jump to the palm register.
        if keys.contains(.lowBFlat) || keys.contains(.lowB) || keys.contains(.lowC) || keys.contains(.lowCSharp) {
            return nil
        }
        let r1 = keys.contains(.r1)
        let r2 = keys.contains(.r2)
        let r3 = keys.contains(.r3)
        let palmD = keys.contains(.palmD)
        let palmEb = keys.contains(.palmEFlat)
        let palmF = keys.contains(.palmF)
        let front = keys.contains(.frontE)
        let chrom = keys.contains(.chromaticFSharp)
        let six = r1 && r2 && r3

        // F♯6 — fork (R2) or chromatic (R1 + F♯ key), with all three palm keys.
        if !r1 && r2 && palmD && palmEb && palmF { return 30 }
        if r1 && !r2 && chrom && palmD && palmEb && palmF { return 30 }
        // F6 — full palm stack, or the half-palm F (palm D+E♭ over an F fingering).
        if six && palmD && palmEb && palmF { return 29 }
        if r1 && !r2 && palmD && palmEb && !chrom { return 29 }
        // E♭6 — palm D+E♭ over the D fingering. Front E is not this note.
        if six && palmD && palmEb && !palmF && !front { return 27 }
        // E6 — front E (Tf) over D or E, or palm D over the E fingering.
        if six && front && !palmEb && !palmF { return 28 }
        if r1 && r2 && !r3 && front && !palmEb && !palmF { return 28 }
        if r1 && r2 && !r3 && palmD && !palmEb && !palmF && !front { return 28 }
        // D6 — palm D alone over the D fingering.
        if six && palmD && !palmEb && !palmF && !front { return 26 }
        return nil
    }

    // MARK: - First register (B♭3–C♯5)

    private static func stackNote(_ keys: Set<SaxKey>) -> Int {
        let l1 = keys.contains(.l1)
        let l2 = keys.contains(.l2)
        let l3 = keys.contains(.l3)

        // Both B and A holes covered: G and everything below it.
        if l1 && l2 && l3 {
            return rightHand(keys)
        }
        // A hole covered, G hole open: A. Keys below the open G hole don't speak.
        if l1 && l2 {
            return 9
        }
        // B hole covered, A hole open: B, or a B♭ / side-C cross-fingering.
        if l1 {
            if keys.contains(.bis) { return 10 }
            if keys.contains(.sideBFlat) { return 10 }
            if keys.contains(.sideC) { return 12 }
            if keys.contains(.r1) { return 10 }
            return 11
        }
        // A hole covered and the B hole open: C. L3 under that doesn't matter.
        if l2 {
            return 12
        }
        // B and A both open: open C♯, even if the right hand is down.
        return 13
    }

    private static func rightHand(_ keys: Set<SaxKey>) -> Int {
        let r1 = keys.contains(.r1)
        let r2 = keys.contains(.r2)
        let r3 = keys.contains(.r3)

        if r1 && r2 && r3 {
            // Lowest open bell pad wins. G♯ is articulated shut by the right hand.
            if keys.contains(.lowBFlat) { return -2 }
            if keys.contains(.lowB) { return -1 }
            if keys.contains(.lowC) { return 0 }
            if keys.contains(.lowCSharp) { return 1 }
            if keys.contains(.lowEFlat) { return 3 }
            return 2
        }
        if r1 && r2 {
            return 4 // E; the D hole is open, so the E♭ pinky does nothing
        }
        if r1 {
            if keys.contains(.chromaticFSharp) { return 6 }
            return 5
        }
        if r2 {
            return 6 // fork F♯; R3 may stay down
        }
        // G, or G♯ if the pinky is on the G♯ touch. Low C♯ does nothing here.
        if keys.contains(.gSharp) { return 8 }
        return 7
    }
}

/// Which touch is holding which key. A cancelled or ended touch always releases
/// its key, and a slide moves the hold instead of leaving the old key down.
struct KeyTouchTracker<Touch: Hashable>: Equatable {
    private(set) var keyByTouch: [Touch: SaxKey] = [:]
    private(set) var pressed: Set<SaxKey> = []

    mutating func begin(_ touch: Touch, on key: SaxKey?) {
        move(touch, to: key)
    }

    mutating func move(_ touch: Touch, to key: SaxKey?) {
        if let key {
            keyByTouch[touch] = key
        } else {
            keyByTouch.removeValue(forKey: touch)
        }
        rebuild()
    }

    mutating func end(_ touch: Touch) {
        guard keyByTouch[touch] != nil else { return }
        keyByTouch.removeValue(forKey: touch)
        rebuild()
    }

    mutating func cancel(_ touch: Touch) {
        end(touch)
    }

    mutating func endAll() {
        keyByTouch.removeAll()
        pressed = []
    }

    private mutating func rebuild() {
        pressed = Set(keyByTouch.values)
    }
}
