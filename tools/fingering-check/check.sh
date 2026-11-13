#!/usr/bin/env bash
# Builds the note logic from VEWI/GameScene.swift (getSaxNote + finalPitch) into a
# tiny command-line harness and checks it against tests.swift. No Xcode, AudioKit
# or simulator needed; any Swift 5+ toolchain works (macOS or Linux).
#   ./tools/fingering-check/check.sh
set -euo pipefail
here="$(cd "$(dirname "$0")" && pwd)"
root="$here/../.."
tmp="$(mktemp -d)"
trap 'rm -rf "$tmp"' EXIT
{
  echo 'import Foundation'
  echo 'var transpositionValue = 0'
  echo 'var octaveModifierValue = 0.0'
  echo 'final class NoteLogic {'
  echo '    var blnKey = [Bool](repeating: false, count: 11)'
  # everything from getSaxNote up to (not including) the touch handling
  awk '/func getSaxNote\(\)/{on=1} /Creates array of touches/{on=0} on' "$root/VEWI/GameScene.swift"
  echo '}'
  cat "$here/tests.swift"
} > "$tmp/main.swift"
# Foundation-only app files the tests also use (no UIKit/AudioKit)
models=()
for f in SaxSettings.swift FingeringChart.swift NoteDisplay.swift; do
  [ -f "$root/VEWI/$f" ] && models+=("$root/VEWI/$f")
done
for t in "$here"/tests_*.swift; do [ -f "$t" ] && cat "$t" >> "$tmp/main.swift"; done
echo 'print(failures == 0 ? "ALL PASS" : "\(failures) FAILED")' >> "$tmp/main.swift"
echo 'exit(failures == 0 ? 0 : 1)' >> "$tmp/main.swift"
swiftc "$tmp/main.swift" "${models[@]}" -o "$tmp/check" 2>&1 | grep -v 'warning:' || true
"$tmp/check"
