// Expected notes for each fingering. Keys: 1-3 left-hand fingers, 4-5 G# keys,
// 6-8 right-hand fingers, 9 Eb key, 10 low C key. Note numbers: 0 = low C (C4).
let names = ["C", "C#", "D", "Eb", "E", "F", "F#", "G", "G#", "A", "Bb", "B"]
func noteName(_ n: Int) -> String { n < 0 ? "silent" : "\(names[n % 12])\(4 + n / 12)" }

let logic = NoteLogic()
func play(_ keys: [Int]) -> Int {
    logic.blnKey = [Bool](repeating: false, count: 11)
    for k in keys { logic.blnKey[k] = true }
    return logic.getSaxNote()
}

var failures = 0
func expect(_ keys: [Int], _ want: String) {
    let got = noteName(play(keys))
    if got != want { failures += 1; print("FAIL keys \(keys): got \(got), want \(want)") }
    else { print("PASS keys \(keys) -> \(got)") }
}

// Low register
expect([6, 7, 8, 10], "C4")
expect([4, 6, 7, 8, 10], "C#4")
expect([5, 6, 7, 8, 10], "C#4")
expect([6, 7, 8], "D4")
expect([6, 7, 8, 9], "Eb4")
expect([6, 7], "E4")
expect([6], "F4")
expect([7], "F#4")
expect([1, 2, 3], "G4")
expect([1, 2, 3, 4], "G#4")
expect([1, 2, 3, 5], "G#4")
expect([1, 2], "A4")
expect([1, 6], "Bb4")
expect([1, 2, 6], "Bb4")
expect([1], "B4")
expect([2], "C5")
expect([3], "C#5")
// Upper register (key 3 / key 8 act as the octave key)
expect([3, 6, 7, 8], "D5")
expect([3, 6], "F5")
expect([1, 2, 3, 8], "G5")
expect([1, 2, 3, 4, 8], "G#5")
expect([1, 2, 3, 5, 8], "G#5")
expect([1, 2, 8], "A5")
expect([1, 8], "B5")
expect([1, 3, 8], "D6")
// Nothing pressed
expect([], "silent")

// Pitch: concert pitch of written A4 (note 9) per transposition
func approx(_ a: Double, _ b: Double) -> Bool { abs(a - b) < 0.05 }
func expectPitch(_ t: Int, _ note: Int, _ hz: Double, _ label: String) {
    transpositionValue = t
    let got = logic.finalPitch(saxNote: note)
    if approx(got, hz) { print("PASS \(label): \(String(format: "%.2f", got)) Hz") }
    else { failures += 1; print("FAIL \(label): got \(String(format: "%.2f", got)) Hz, want \(hz)") }
}
expectPitch(0, 9, 440.00, "C instrument, written A4")
expectPitch(-2, 0, 233.08, "Bb instrument, written C4")

print(failures == 0 ? "ALL PASS" : "\(failures) FAILED")
exit(failures == 0 ? 0 : 1)
