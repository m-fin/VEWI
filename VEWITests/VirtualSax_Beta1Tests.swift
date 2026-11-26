//
//  VirtualSax_Beta1Tests.swift
//  VEWITests
//
//  The same alto fingerings the command-line harness checks, runnable from Xcode.
//

import UIKit
import XCTest
@testable import VEWI

class FingeringEngineTests: XCTestCase {
    func testEveryChartFingering() {
        for fingering in FingeringChart.all {
            let blown = FingeringEngine.writtenNote(holding: Set(fingering.keys), blowing: true)
            XCTAssertEqual(blown, fingering.note, FingeringChart.keyText(fingering.keys))
            let released = FingeringEngine.writtenNote(holding: Set(fingering.keys), blowing: false)
            XCTAssertNil(released)
        }
    }

    func testRangeIsCovered() {
        let notes = Set(FingeringChart.daily.map { $0.note })
        for note in -2...30 {
            XCTAssertTrue(notes.contains(note), NoteDisplay.name(note))
        }
    }

    func testOpenCSharpNeedsBreath() {
        XCTAssertEqual(FingeringEngine.writtenNote(holding: [], blowing: true), 13)
        XCTAssertNil(FingeringEngine.writtenNote(holding: [], blowing: false))
        XCTAssertEqual(FingeringEngine.fingeredNote([.r1, .r2, .r3]), 13)
    }

    func testAltoTransposition() {
        XCTAssertEqual(NoteDisplay.sounding(written: 9, transposition: .eb, octaveShift: 0), 0)
        XCTAssertEqual(NoteDisplay.frequency(written: 9, transposition: .eb, octaveShift: 0), 261.63, accuracy: 0.05)
        XCTAssertEqual(NoteDisplay.frequency(written: 9, transposition: .concert, octaveShift: 0), 440, accuracy: 0.05)
        XCTAssertEqual(SaxSettings().transposition, .eb)
    }

    func testTouchTrackerDoesNotStick() {
        var tracker = KeyTouchTracker<Int>()
        tracker.begin(1, on: .l1)
        tracker.begin(2, on: .r1)
        tracker.cancel(1)
        XCTAssertEqual(tracker.pressed, [.r1])
        tracker.move(2, to: nil)
        tracker.end(99)
        XCTAssertTrue(tracker.pressed.isEmpty)
        tracker.begin(3, on: .octave)
        tracker.endAll()
        XCTAssertTrue(tracker.pressed.isEmpty)
    }

    func testLayoutFits() {
        for size in [CGSize(width: 320, height: 500), CGSize(width: 390, height: 700), CGSize(width: 844, height: 390)] {
            let plan = SaxLayout.plan(width: Double(size.width), height: Double(size.height))
            XCTAssertEqual(Set(plan.keys.keys), Set(SaxKey.allCases))
            let boxes = Array(plan.keys.values)
            for index in boxes.indices {
                XCTAssertGreaterThanOrEqual(boxes[index].width, 28)
                XCTAssertGreaterThanOrEqual(boxes[index].height, 28)
                for other in boxes[(index + 1)...] {
                    XCTAssertFalse(boxes[index].overlaps(other))
                }
            }
        }
    }
}
