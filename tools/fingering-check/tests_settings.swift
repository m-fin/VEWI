
// ---- SaxSettings (save/load, old keys, clamping) ----
func check(_ ok: Bool, _ label: String) {
    if ok { print("PASS \(label)") } else { failures += 1; print("FAIL \(label)") }
}
let suite = "vewi-settings-test-\(Int.random(in: 0...1_000_000))"
let defaults = UserDefaults(suiteName: suite)!
check(SaxSettings.load(from: defaults) == SaxSettings(), "empty defaults load as defaults")

// Values saved by the old settings screen still load
defaults.set(2, forKey: "Transposition_Value_Index")
defaults.set(-1.0, forKey: "Octave_Value")
defaults.set(3, forKey: "Waveform_Value_Index")
let legacy = SaxSettings.load(from: defaults)
check(legacy.transposition == .eb && legacy.octaveShift == -1 && legacy.waveform == .triangle, "old keys: Eb, octave -1, triangle")
check(legacy.volume == 1.0 && legacy.rampDuration == 0.05 && !legacy.showFingeringChart && legacy.showNoteName, "missing new keys use defaults")

var s = SaxSettings()
s.transposition = .bb; s.octaveShift = 1; s.waveform = .square; s.volume = 0.4; s.rampDuration = 0.2; s.showFingeringChart = true; s.showNoteName = false
s.save(to: defaults)
check(SaxSettings.load(from: defaults) == s, "save then load round-trips")

s.octaveShift = 7; s.volume = 1.8; s.rampDuration = -1
s.save(to: defaults)
let c = SaxSettings.load(from: defaults)
check(c.octaveShift == 2 && c.volume == 1.0 && c.rampDuration == 0.0, "out-of-range values are clamped")

check(Transposition.concert.semitones == 0 && Transposition.bb.semitones == -2 && Transposition.eb.semitones == -9, "transposition semitones")
defaults.removePersistentDomain(forName: suite)
