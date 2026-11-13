
// ---- Fingering chart: every entry plays its note ----
for f in FingeringChart.all {
    let got = play(f.keys)
    check(got == f.note, "chart \(NoteDisplay.name(f.note)) \(FingeringChart.keyText(f.keys)) -> \(noteName(got))")
}
check(FingeringChart.keyText([1, 2, 3, 8]) == "Left 1 2 3  |  Right 3", "chart key text")
check(FingeringChart.keyText([6]) == "Left \u{2013}  |  Right 1", "chart key text, one column")

// ---- Note display ----
check(NoteDisplay.name(0) == "C4" && NoteDisplay.name(7) == "G4" && NoteDisplay.name(12) == "C5", "note names")
check(NoteDisplay.name(-2) == "B\u{266D}3" && NoteDisplay.name(-9) == "E\u{266D}3" && NoteDisplay.name(-14) == "B\u{266D}2", "note names below C4")
check(NoteDisplay.text(written: -1, transposition: .concert, octaveShift: 0) == "", "silent shows nothing")
check(NoteDisplay.text(written: 9, transposition: .concert, octaveShift: 0) == "A4 \u{00B7} 440.0 Hz", "concert A4 text")
check(NoteDisplay.text(written: 0, transposition: .eb, octaveShift: 0) == "C4 \u{00B7} sounds E\u{266D}3 \u{00B7} 155.6 Hz", "alto written C4 text")
check(NoteDisplay.text(written: 2, transposition: .bb, octaveShift: 0) == "D4 \u{00B7} sounds C4 \u{00B7} 261.6 Hz", "Bb written D4 text")

// Display frequency matches what the app actually plays (finalPitch)
var pitchMismatch = 0
for t in Transposition.allCases {
    for o in SaxSettings.octaveRange {
        for n in 0...26 {
            transpositionValue = t.semitones
            octaveModifierValue = Double(o)
            if abs(logic.finalPitch(saxNote: n) - NoteDisplay.frequency(written: n, transposition: t, octaveShift: o)) > 0.001 { pitchMismatch += 1 }
        }
    }
}
transpositionValue = 0; octaveModifierValue = 0
check(pitchMismatch == 0, "display Hz == played Hz for all keys/octaves/notes (\(pitchMismatch) mismatches)")
