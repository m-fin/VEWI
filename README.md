# VEWI

**Virtual Electronic Wind Instrument**: an iOS app that turns the iPhone screen into saxophone keys. Hold the
on-screen keys the way you'd finger a sax, and VEWI plays the note with a synthesized tone (AudioKit). It's written
in Swift with SpriteKit.

[![Fingering check](https://github.com/m-fin/VEWI/actions/workflows/fingering-check.yml/badge.svg)](https://github.com/m-fin/VEWI/actions/workflows/fingering-check.yml)

<img src="demo/Screen%20Shot%202019-11-10%20at%209.01.27%20PM.png" width="320" alt="VEWI playing screen (2019 build) with two columns of saxophone keys">

## Features

- **Two columns of keys:** left hand on the left, right hand on the right. Lift every key to stop the sound.
- **Launch page** with a quick start and buttons for Play, Settings and Fingering Chart.
- **Settings** (saved between launches):
  - **Key:** Concert, B♭ or E♭. Notes are written pitch, so an alto player reads E♭ parts as usual.
  - **Octave shift:** −2 to +2.
  - **Sound:** sine, saw, square or triangle.
  - **Volume** and **glide** (how quickly the pitch slides between notes).
  - Show or hide the note name and the **Chart** button on the playing screen.
- **Live note display:** the playing screen shows the written note and its pitch in Hz, plus the sounding note when
  you're transposed (for example `G4 · sounds B♭3 · 233.1 Hz`).
- **Fingering chart:** every fingering the app understands, written C4 to D6, including an alternate B♭.

## Fingerings

Keys are counted 1–5 from the bottom of each column:
- Left column: 1–3 are your left-hand fingers, and 4–5 are the G♯ keys.
- Right column: 1–3 are your right-hand fingers, 4 is the E♭ key, and 5 is the low C key.
- The upper register adds the third key of the *other* hand as the octave key.

| Written note | Left column | Right column | |
|---|---|---|---|
| C4 | – | 1 2 3 5 |  |
| C♯/D♭4 | 4 | 1 2 3 5 |  |
| D4 | – | 1 2 3 |  |
| E♭4 | – | 1 2 3 4 |  |
| E4 | – | 1 2 |  |
| F4 | – | 1 |  |
| F♯/G♭4 | – | 2 |  |
| G4 | 1 2 3 | – |  |
| G♯/A♭4 | 1 2 3 4 | – |  |
| A4 | 1 2 | – |  |
| B♭4 | 1 | 1 |  |
| B♭4 | 1 2 | 1 | alternate |
| B4 | 1 | – |  |
| C5 | 2 | – |  |
| C♯/D♭5 | 3 | – |  |
| D5 | 3 | 1 2 3 |  |
| E♭5 | 3 | 1 2 3 4 |  |
| E5 | 3 | 1 2 |  |
| F5 | 3 | 1 |  |
| F♯/G♭5 | 3 | 2 |  |
| G5 | 1 2 3 | 3 |  |
| G♯/A♭5 | 1 2 3 4 | 3 |  |
| A5 | 1 2 | 3 |  |
| B♭5 | 1 | 1 3 |  |
| B5 | 1 | 3 |  |
| C6 | 2 | 3 |  |
| C♯/D♭6 | 3 | 3 |  |
| D6 | 1 3 | 3 |  |

On low C♯ and G♯, either G♯ key (left 4 or 5) works. The same table is in the app under **Fingering Chart**.

## Building

1. Open `VEWI.xcodeproj` in Xcode. The project targets iOS 12.2 and Swift 5.
2. Add the **AudioKit** and **AudioKitUI** frameworks (AudioKit 4, from https://audiokit.io/downloads/) to the
   VEWI target.
3. Make sure **Other Linker Flags** (Build Settings → Linking) includes `-lc++`. It's already set in the project.
4. Build and run on a device or the simulator.

## Tests

The note logic (which keys make which note, plus the pitch for each transposition) is checked without Xcode,
AudioKit or a simulator. The harness compiles the logic out of `GameScene.swift` and plays every fingering:

```bash
./tools/fingering-check/check.sh   # prints PASS/FAIL per fingering, then ALL PASS
```

It runs on macOS or Linux with any Swift 5+ toolchain. GitHub Actions runs it on every pull request.

Found a fingering that plays the wrong note? Open a **Wrong or missing note** issue. It asks for the keys you
pressed, so it's easy to turn into a test.
