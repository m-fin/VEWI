# VEWI

**Virtual Electronic Wind Instrument**: an iOS app that turns an iPhone into an alto saxophone. The keys are the real ones — left-hand stack, octave key, bis, pinky table, palm keys, right-hand stack, and the side keys — and VEWI sounds the written note with a built-in wind synth. No third-party audio frameworks.

[![Fingering check](https://github.com/m-fin/VEWI/actions/workflows/fingering-check.yml/badge.svg)](https://github.com/m-fin/VEWI/actions/workflows/fingering-check.yml)

<img src="demo/Screen%20Shot%202019-11-10%20at%209.01.27%20PM.png" width="320" alt="Earlier VEWI playing screen">

## Features

- **Real alto fingerings**, written B♭3 to F♯6, including bis B♭, 1+1 B♭, side B♭, side C, fork and chromatic F♯, articulated G♯, the octave key, and palm keys.
- **Breath pad.** Hold it to play, latch it, slide it for dynamics, or blow into the mic. Nothing pressed is open C♯, and lifting the breath stops the note.
- **Portrait EWI grip** (left hand on top, right hand below) and a side-by-side landscape layout. Keys light up, and a cancelled touch cannot leave a note stuck.
- **Live readout** of the written note, the sounding note when you're transposed, the frequency, and an optional fingering diagram.
- **Transposition.** E♭ (alto) is the default: written A sounds concert C. B♭ (tenor/soprano) and concert are in Settings, with an octave shift.
- **Wind synth** on `AVAudioEngine`: Warm Reed, Bright Lead, Subtone, and pure sine, saw, square, and triangle, with glide, vibrato, and a click-free envelope.
- **Fingering of the Day** widget for the Home Screen and the Lock Screen. Tapping it opens VEWI (`vewi://play`).

## Fingerings

Written pitch. Add the octave key (left thumb) to a D4–C♯5 fingering to play D5–C♯6. The octave key does not move B♭3–C♯4.

| Written | Keys | |
|---|---|---|
| B♭3 | L1 L2 L3 · R1 R2 R3 · low B♭ | |
| B3 | L1 L2 L3 · R1 R2 R3 · low B | |
| C4 | L1 L2 L3 · R1 R2 R3 · low C | |
| C♯4 | L1 L2 L3 · R1 R2 R3 · low C♯ | |
| D4 | L1 L2 L3 · R1 R2 R3 | |
| E♭4 | L1 L2 L3 · R1 R2 R3 · E♭ | |
| E4 | L1 L2 L3 · R1 R2 | |
| F4 | L1 L2 L3 · R1 | |
| F♯4 | L1 L2 L3 · R2 | fork |
| F♯4 | L1 L2 L3 · R1 · F♯ key | chromatic |
| G4 | L1 L2 L3 | |
| G♯4 | L1 L2 L3 · G♯ | pinky lets go when the right hand closes a lower note |
| A4 | L1 L2 | |
| B♭4 | L1 · Bis | |
| B♭4 | L1 · R1 | 1+1 |
| B♭4 | L1 · side B♭ | Ta |
| B4 | L1 | |
| C5 | L2 | |
| C5 | L1 · side C | Tc |
| C♯5 | open | blow with no keys down |
| D5–C♯6 | octave key + the D4–C♯5 fingering | |
| D6 | octave · D4 · palm D | |
| E♭6 | octave · D4 · palm D · palm E♭ | |
| E6 | octave · E4 · palm D | |
| E6 | octave · D4 · front E | Tf |
| F6 | octave · D4 · palm D · palm E♭ · palm F | |
| F6 | octave · F4 · palm D · palm E♭ | half palm |
| F♯6 | octave · fork F♯ · palm D · palm E♭ · palm F | |
| F♯6 | octave · F4 · F♯ key · palm D · palm E♭ · palm F | chromatic |

L1 L2 L3 are B, A, and G. R1 R2 R3 are F, E, and D. The same chart is in the app under **Fingering Chart**.

On E♭ (alto), written A4 sounds concert C4. On B♭, written C4 sounds B♭3. Concert plays the written pitch.

## Building

1. Open `VEWI.xcodeproj` in Xcode. The app and the widget target iOS 16.
2. Build and run. There is nothing to download: the synth is `AVAudioEngine`, and AudioKit is not used.
3. The **VEWIWidget** extension is embedded in the app. Add the widget from the Home Screen or the Lock Screen. Its tap opens the horn through the `vewi://` URL scheme.

To share the last note you played with the widget, add the App Group `group.com.matthewfinley.VEWI` to both targets. Without it, the widget still shows the fingering of the day, which is computed from the date and does not need the group.

## Tests

The fingering model is Foundation-only. The harness plays every chart fingering, the alternates, all three transpositions, breath release (including open C♯), the touch tracker, and the synth envelope:

```bash
./tools/fingering-check/check.sh   # prints PASS per fingering, then ALL PASS
```

It runs on macOS or Linux with any Swift 5+ toolchain. GitHub Actions runs it on every pull request. The same checks are in `VEWITests/` for Xcode.

Found a fingering that plays the wrong note? Open a **Wrong or missing note** issue and name the keys you held.
