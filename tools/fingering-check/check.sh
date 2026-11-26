#!/usr/bin/env bash
# Compiles the Foundation fingering model and checks every real alto saxophone
# fingering (B♭3–F♯6), the alternates, the three transpositions, breath
# release, and the touch tracker. No Xcode, simulator, or audio framework.
#   ./tools/fingering-check/check.sh
set -euo pipefail
here="$(cd "$(dirname "$0")" && pwd)"
root="$here/../.."
tmp="$(mktemp -d)"
trap 'rm -rf "$tmp"' EXIT
sources=(
  "$root/VEWI/SaxKey.swift"
  "$root/VEWI/Pitch.swift"
  "$root/VEWI/BreathState.swift"
  "$root/VEWI/FingeringEngine.swift"
  "$root/VEWI/FingeringChart.swift"
  "$root/VEWI/NoteDisplay.swift"
  "$root/VEWI/SaxSettings.swift"
  "$root/VEWI/SaxLayout.swift"
  "$root/VEWI/SynthDSP.swift"
  "$root/VEWI/DailyFingering.swift"
)
swiftc "${sources[@]}" "$here/main.swift" -o "$tmp/check"
"$tmp/check"
