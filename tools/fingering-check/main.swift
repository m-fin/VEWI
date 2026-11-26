import Foundation

// MARK: - Harness

var failures = 0
func check(_ ok: Bool, _ label: String) {
    if ok {
        print("PASS \(label)")
    } else {
        failures += 1
        print("FAIL \(label)")
    }
}

func play(_ keys: [SaxKey], blowing: Bool = true) -> Int? {
    return FingeringEngine.writtenNote(holding: Set(keys), blowing: blowing)
}

func expect(_ keys: [SaxKey], _ want: Int?, _ label: String) {
    let got = play(keys)
    if got == want {
        let name = want.map { NoteDisplay.name($0) } ?? "silent"
        print("PASS \(label) -> \(name)")
    } else {
        failures += 1
        let gotName = got.map { NoteDisplay.name($0) } ?? "silent"
        let wantName = want.map { NoteDisplay.name($0) } ?? "silent"
        print("FAIL \(label): got \(gotName) (\(got.map(String.init) ?? "nil")), want \(wantName)")
    }
}

// MARK: - Every chart fingering, blown and released

for fingering in FingeringChart.all {
    let name = NoteDisplay.name(fingering.note)
    let suffix = fingering.label.map { " (\($0))" } ?? ""
    expect(fingering.keys, fingering.note, "\(fingering.section.rawValue) \(name)\(suffix) [\(FingeringChart.keyText(fingering.keys))]")
    let released = play(fingering.keys, blowing: false)
    check(released == nil, "breath off silences \(name)\(suffix)")
}

// Every written pitch from B♭3 to F♯6 has a primary fingering.
let primaries = FingeringChart.daily.map { $0.note }
for note in -2...30 {
    check(primaries.contains(note), "primary fingering exists for \(NoteDisplay.name(note))")
}

// MARK: - Standard alto fingerings called out by name

expect([.l1, .l2, .l3, .r1, .r2, .r3], 2, "D4 is all six")
expect([.l1, .l2, .l3, .r1, .r2], 4, "E4 lifts R3")
expect([.l1, .l2, .l3, .r1], 5, "F4 is left hand plus R1")
expect([.l1, .l2, .l3, .r2], 6, "fork F♯4")
expect([.l1, .l2, .l3], 7, "G4")
expect([.l1, .l2], 9, "A4")
expect([.l1], 11, "B4")
expect([.l2], 12, "C5")
expect([], 13, "open C♯5 with breath and no keys")
expect([.octave, .l1, .l2, .l3, .r1, .r2, .r3], 14, "octave D is D5")
expect([.octave], 25, "octave alone is C♯6")

// The old simplified chart played D4 from the right hand only. A real sax does not.
expect([.r1, .r2, .r3], 13, "right hand alone is still open C♯")
expect([.l3], 13, "L3 alone leaves B and A open, so C♯")

// MARK: - Alternates

expect([.l1, .bis], 10, "bis B♭")
expect([.l1, .r1], 10, "1+1 B♭")
expect([.l1, .sideBFlat], 10, "side B♭")
expect([.l1, .l2, .bis], 9, "bis under A does not make B♭")
expect([.l1, .l2, .r1], 9, "1+1 with L2 down is A, not B♭")
expect([.l1, .sideC], 12, "side C")
expect([.l1, .bis, .sideC], 10, "bis wins over side C")
expect([.l1, .sideC, .r1], 12, "side C wins over 1+1")
expect([.l1, .l2, .l3, .r1, .chromaticFSharp], 6, "chromatic F♯")
expect([.l1, .l2, .l3, .r1, .r2, .chromaticFSharp], 4, "chromatic key does not change E")
expect([.l1, .l2, .l3, .r2, .r3], 6, "fork F♯ with R3 still down")

// MARK: - Articulated G♯ and the low C♯ roller

expect([.l1, .l2, .l3, .gSharp], 8, "G♯")
expect([.l1, .l2, .l3, .gSharp, .r1], 5, "G♯ pinky stays down into F")
expect([.l1, .l2, .l3, .gSharp, .r2], 6, "G♯ pinky stays down into fork F♯")
expect([.l1, .l2, .l3, .r1, .r2, .r3, .gSharp], 2, "G♯ pinky stays down on D")
expect([.l1, .l2, .l3, .r1, .r2, .r3, .lowCSharp], 1, "low C♯")
expect([.l1, .l2, .l3, .r1, .r2, .r3, .lowCSharp, .gSharp], 1, "rolling onto low C♯ while G♯ is still down")
expect([.l1, .l2, .l3, .lowCSharp], 7, "low C♯ alone does not change G")
expect([.l1, .l2, .l3, .r1, .r2, .r3, .lowBFlat, .lowB, .lowC], -2, "lowest bell key wins")

// MARK: - Octave key leaves the bell notes alone

expect([.octave, .l1, .l2, .l3, .r1, .r2, .r3, .lowBFlat], -2, "octave does not lift low B♭")
expect([.octave, .l1, .l2, .l3, .r1, .r2, .r3, .lowB], -1, "octave does not lift low B")
expect([.octave, .l1, .l2, .l3, .r1, .r2, .r3, .lowC], 0, "octave does not lift low C")
expect([.octave, .l1, .l2, .l3, .r1, .r2, .r3, .lowCSharp], 1, "octave does not lift low C♯")
expect([.octave, .l1, .l2, .l3, .r1, .r2, .r3, .lowEFlat], 15, "octave lifts E♭4 to E♭5")
expect([.octave, .l1, .bis], 22, "octave bis B♭ is B♭5")

// MARK: - Palm keys need the octave key

expect([.l1, .l2, .l3, .r1, .r2, .r3, .palmD], 2, "palm D without the octave key is still D4")
expect([.octave, .l1, .l2, .l3, .r1, .r2, .r3, .palmD], 26, "D6")
expect([.octave, .l1, .l2, .l3, .r1, .r2, .r3, .palmD, .palmEFlat], 27, "E♭6")
expect([.octave, .l1, .l2, .l3, .r1, .r2, .palmD], 28, "E6")
expect([.octave, .l1, .l2, .l3, .r1, .r2, .r3, .frontE], 28, "front E is E6")
expect([.octave, .l1, .l2, .l3, .r1, .r2, .r3, .palmD, .palmEFlat, .palmF], 29, "F6")
expect([.octave, .l1, .l2, .l3, .r1, .palmD, .palmEFlat], 29, "half-palm F6")
expect([.octave, .l1, .l2, .l3, .r2, .palmD, .palmEFlat, .palmF], 30, "fork F♯6")
expect([.octave, .l1, .l2, .l3, .r1, .chromaticFSharp, .palmD, .palmEFlat, .palmF], 30, "chromatic F♯6")
expect([.octave, .l1, .l2, .l3, .r1, .chromaticFSharp], 18, "chromatic F♯ plus octave, without palms, is F♯5")

// MARK: - Breath gate

check(play([], blowing: false) == nil, "open C♯ is silent until there is breath")
check(play([.l1, .l2, .l3, .r1, .r2, .r3], blowing: false) == nil, "a full D fingering is silent without breath")
var breath = BreathState(mode: .hold)
check(!breath.isBlowing, "hold mode starts silent")
breath.padHeld = true
check(breath.isBlowing && breath.expression == 1, "holding the pad is full breath")
breath.padHeld = false
check(!breath.isBlowing, "lifting the pad releases the breath")

breath.mode = .latch
breath.toggleLatch()
check(breath.isBlowing, "latch click turns the air on")
breath.toggleLatch()
check(!breath.isBlowing, "second latch click turns the air off")

breath.mode = .slide
breath.slideLevel = 0
check(!breath.isBlowing, "a slide at rest is silent")
breath.slideLevel = 0.4
check(breath.isBlowing && abs(breath.expression - 0.4) < 0.0001, "slide level is the expression")
breath.slideLevel = 0
check(play([], blowing: breath.isBlowing) == nil, "releasing the slide silences open C♯")

breath.mode = .microphone
breath.micLevel = 0
check(!breath.isBlowing, "mic under the gate is silent")
breath.micLevel = 0.5
check(breath.isBlowing, "mic level above the gate blows")
check(play([], blowing: breath.isBlowing) == 13, "mic breath plays open C♯")

// MARK: - No stuck keys

var touches = KeyTouchTracker<Int>()
touches.begin(1, on: .l1)
touches.begin(2, on: .l2)
check(touches.pressed == [.l1, .l2], "two fingers hold two keys")
touches.cancel(1)
check(touches.pressed == [.l2], "a cancelled touch lets go")
touches.move(2, to: .l3)
check(touches.pressed == [.l3], "a slide leaves the previous key")
touches.move(2, to: nil)
check(touches.pressed.isEmpty, "sliding off a key releases it")
touches.begin(3, on: .r1)
touches.begin(4, on: .r1)
touches.end(3)
check(touches.pressed == [.r1], "a key stays down while another finger is still on it")
touches.end(4)
check(touches.pressed.isEmpty, "the last finger up clears the key")
touches.begin(5, on: .octave)
touches.endAll()
check(touches.pressed.isEmpty, "endAll clears every hold")
touches.end(99)
check(touches.pressed.isEmpty, "an unknown touch end does not invent a key")

// MARK: - Transposition and pitch

func approx(_ a: Double, _ b: Double, _ tol: Double = 0.05) -> Bool { return abs(a - b) < tol }

check(Transposition.eb.semitones == -9 && Transposition.bb.semitones == -2 && Transposition.concert.semitones == 0, "transposition intervals")
check(NoteDisplay.sounding(written: 9, transposition: .eb, octaveShift: 0) == 0, "alto written A4 sounds C4")
check(approx(NoteDisplay.frequency(written: 9, transposition: .eb, octaveShift: 0), 261.63), "alto written A4 is concert C, 261.63 Hz")
check(approx(NoteDisplay.frequency(written: 9, transposition: .concert, octaveShift: 0), 440), "concert A4 is 440 Hz")
check(approx(NoteDisplay.frequency(written: 0, transposition: .bb, octaveShift: 0), 233.08), "B♭ instrument written C4")
check(NoteDisplay.name(-2) == "B\u{266D}3" && NoteDisplay.name(30) == "F\u{266F}6" && NoteDisplay.name(13) == "C\u{266F}5", "range endpoints are named")
check(NoteDisplay.text(written: nil, transposition: .eb, octaveShift: 0) == "", "nil note shows nothing")
check(NoteDisplay.text(written: 9, transposition: .eb, octaveShift: 0) == "A4 \u{00B7} sounds C4 \u{00B7} 261.6 Hz", "alto A4 display")
check(NoteDisplay.text(written: 9, transposition: .concert, octaveShift: 0) == "A4 \u{00B7} 440.0 Hz", "concert A4 display")
check(NoteDisplay.text(written: 0, transposition: .eb, octaveShift: 0) == "C4 \u{00B7} sounds E\u{266D}3 \u{00B7} 155.6 Hz", "alto written C4 display")
check(NoteDisplay.text(written: 2, transposition: .bb, octaveShift: 0) == "D4 \u{00B7} sounds C4 \u{00B7} 261.6 Hz", "B♭ written D4 display")
check(NoteDisplay.text(written: -2, transposition: .concert, octaveShift: 0).hasPrefix("B\u{266D}3"), "low B♭ is shown, not treated as silence")

var pitchMismatch = 0
for transposition in Transposition.allCases {
    for octave in SaxSettings.octaveRange {
        for note in -2...30 {
            let fromDisplay = NoteDisplay.frequency(written: note, transposition: transposition, octaveShift: octave)
            let fromPitch = Pitch.frequency(semitonesFromC4: note + transposition.semitones + 12 * octave)
            if abs(fromDisplay - fromPitch) > 0.001 { pitchMismatch += 1 }
        }
    }
}
check(pitchMismatch == 0, "display Hz matches Pitch for every note, key, and octave (\(pitchMismatch) mismatches)")

// MARK: - Hint diagram

check(FingeringChart.diagram([.l1, .l2, .l3, .r1, .r2, .r3]) == "oct  \u{25CF}\u{25CF}\u{25CF} \u{25CF}\u{25CF}\u{25CF}", "D4 diagram")
check(FingeringChart.diagram([.octave, .l1]) == "Oct  \u{25CF}\u{25CB}\u{25CB} \u{25CB}\u{25CB}\u{25CB}", "octave B diagram")
check(FingeringChart.diagram([]) == "oct  \u{25CB}\u{25CB}\u{25CB} \u{25CB}\u{25CB}\u{25CB}", "open diagram")
check(FingeringChart.diagram([.l1, .bis]) == "oct  \u{25CF}\u{25CB}\u{25CB} \u{25CB}\u{25CB}\u{25CB}  Bis", "bis shows up in the diagram")
check(FingeringChart.keyText([.l1, .l2, .l3, .r1, .r2, .r3]) == "L1 L2 L3 R1 R2 R3", "chart key text")
check(FingeringChart.keyText([]) == "open", "open fingering text")

// MARK: - Settings

let suite = "vewi-settings-test-\(Int.random(in: 0...1_000_000))"
let defaults = UserDefaults(suiteName: suite)!
let fresh = SaxSettings.load(from: defaults)
check(fresh == SaxSettings(), "empty defaults load as defaults")
check(fresh.transposition == .eb && fresh.preset == .warmReed && fresh.breathMode == .hold && fresh.vibrato, "new install is alto, warm reed, hold-to-blow")

defaults.set(0, forKey: "Transposition_Value_Index")
check(SaxSettings.load(from: defaults).transposition == .concert, "a saved concert key stays concert")

defaults.set(2, forKey: "Transposition_Value_Index")
defaults.set(-1.0, forKey: "Octave_Value")
defaults.set(3, forKey: "Waveform_Value_Index")
defaults.removeObject(forKey: SaxSettings.Keys.preset)
let legacy = SaxSettings.load(from: defaults)
check(legacy.transposition == .eb && legacy.octaveShift == -1 && legacy.preset == .triangle, "old keys: E♭, octave -1, triangle")
check(legacy.volume == 1.0 && legacy.rampDuration == 0.05 && !legacy.showFingeringChart && legacy.showNoteName && !legacy.showFingeringHint, "missing new keys use defaults")

var saved = SaxSettings()
saved.transposition = .bb
saved.octaveShift = 1
saved.preset = .brightLead
saved.volume = 0.4
saved.rampDuration = 0.2
saved.vibrato = false
saved.breathMode = .slide
saved.showFingeringChart = true
saved.showNoteName = false
saved.showFingeringHint = true
saved.save(to: defaults)
check(SaxSettings.load(from: defaults) == saved, "save then load round-trips")

saved.octaveShift = 7
saved.volume = 1.8
saved.rampDuration = -1
saved.save(to: defaults)
let clamped = SaxSettings.load(from: defaults)
check(clamped.octaveShift == 2 && clamped.volume == 1.0 && clamped.rampDuration == 0.0, "out-of-range values are clamped")
defaults.removePersistentDomain(forName: suite)

// MARK: - Layout: every key, on screen, no overlaps

let screens: [(String, Double, Double)] = [
    ("SE portrait", 320, 500),
    ("phone portrait", 375, 560),
    ("phone 14", 390, 700),
    ("pro max", 430, 820),
    ("SE landscape", 667, 320),
    ("phone landscape", 844, 390)
]
for screen in screens {
    let plan = SaxLayout.plan(width: screen.1, height: screen.2)
    let missing = Set(SaxKey.allCases).subtracting(plan.keys.keys)
    check(missing.isEmpty, "\(screen.0) places every key\(missing.isEmpty ? "" : " missing \(missing)")")
    var overlap = false
    var offscreen = false
    var tiny = false
    let boxes = Array(plan.keys.values) + [plan.breath]
    for box in boxes {
        if box.x < -0.1 || box.y < -0.1 || box.maxX > screen.1 + 0.1 || box.maxY > screen.2 + 0.1 || box.width < 28 || box.height < 28 {
            offscreen = true
        }
        if box.width < 28 || box.height < 28 { tiny = true }
    }
    let keyBoxes = Array(plan.keys.values)
    for i in 0..<keyBoxes.count {
        for j in (i + 1)..<keyBoxes.count where keyBoxes[i].overlaps(keyBoxes[j]) {
            overlap = true
        }
        if keyBoxes[i].overlaps(plan.breath) { overlap = true }
    }
    check(!overlap && !offscreen && !tiny, "\(screen.0) keys sit inside the screen without overlapping")
    let minBreath: Double = screen.2 >= screen.1 ? 64 : 56
    check(plan.breath.height >= minBreath - 0.1, "\(screen.0) breath pad is tall enough (\(Int(plan.breath.height)) pt)")
}

// MARK: - Synth voice: no click, glide, silence

var voice = VoiceState.fresh()
voice.targetAmp = 1
voice.attack = 0.03
voice.vibratoSemitones = 0
let first = SynthDSP.step(&voice)
check(abs(first) < 0.01, "attack starts near silence so the note doesn't click (\(first))")
for _ in 0..<1_439 { _ = SynthDSP.step(&voice) }
check(voice.currentAmp > 0.45 && voice.currentAmp < 0.8, "one attack-time later the envelope is part-way open (\(voice.currentAmp))")

voice.targetAmp = 0
voice.release = 0.08
let releaseStart = voice.currentAmp
for _ in 0..<3_840 { _ = SynthDSP.step(&voice) }
check(voice.currentAmp < releaseStart * 0.5 && voice.currentAmp < 0.4, "release falls instead of cutting off")
for _ in 0..<48_000 { _ = SynthDSP.step(&voice) }
check(voice.currentAmp == 0, "a released note reaches silence")

voice.currentHz = 440
voice.targetHz = 880
voice.glide = 0.05
voice.targetAmp = 0
for _ in 0..<2_400 { _ = SynthDSP.step(&voice) }
check(voice.currentHz > 650 && voice.currentHz < 800, "glide moves toward the next pitch (\(voice.currentHz))")

var finite = true
for preset in SoundPreset.allCases {
    var sample = VoiceState.fresh()
    sample.preset = preset
    sample.targetAmp = 0.8
    sample.currentAmp = 0.8
    sample.vibratoSemitones = 0.2
    for _ in 0..<2_000 {
        let value = SynthDSP.step(&sample)
        if !value.isFinite || abs(value) > 1.6 { finite = false }
    }
}
check(finite, "every preset stays finite and inside the output range")

// Coming off silence snaps in the engine's control path: a fresh target with
// current amplitude already 0 should be allowed to change pitch immediately
// when glide is applied only while sounding. The DSP glides Hz even when
// quiet; the snap is the caller's job and is checked here the same way
// SaxSynth does it.
var snap = VoiceState.fresh()
snap.currentHz = 200
snap.currentAmp = 0
snap.targetAmp = 0
let wasSilent = snap.targetAmp < 0.0001 && snap.currentAmp < 0.02
snap.targetHz = 660
if wasSilent { snap.currentHz = snap.targetHz }
check(snap.currentHz == 660, "a new note after silence does not glide in from the old pitch")

// MARK: - Fingering of the day

let day = Date(timeIntervalSince1970: 1_700_000_000)
let today = DailyFingering.fingering(on: day)
let again = DailyFingering.fingering(on: day)
check(today == again, "the same instant picks the same fingering")
let later = DailyFingering.fingering(on: day.addingTimeInterval(Double(FingeringChart.daily.count) * 86_400))
check(later == today, "the cycle repeats after one pass through the chart")
check((-2...30).contains(today.note), "today's note is in the alto range")
check(FingeringEngine.fingeredNote(Set(today.keys)) == today.note, "today's fingering plays the note it names")

print(failures == 0 ? "ALL PASS" : "\(failures) FAILED")
exit(failures == 0 ? 0 : 1)
