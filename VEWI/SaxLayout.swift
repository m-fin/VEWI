//
//  SaxLayout.swift
//  VEWI
//
//  Frames for the playing screen, in points, with no UIKit types so the
//  fingering harness can prove the keys don't overlap.
//
//  Portrait is an EWI grip: left hand on top, right hand below, breath pad
//  under the right thumb. Landscape splits the hands to either side.
//

import Foundation

enum SaxLayout {
    struct Box: Equatable {
        var x: Double
        var y: Double
        var width: Double
        var height: Double

        var maxX: Double { return x + width }
        var maxY: Double { return y + height }

        /// Shared edges are not an overlap.
        func overlaps(_ other: Box) -> Bool {
            let eps = 0.75
            return x < other.maxX - eps && maxX > other.x + eps && y < other.maxY - eps && maxY > other.y + eps
        }
    }

    struct Plan: Equatable {
        var keys: [SaxKey: Box]
        var breath: Box
    }

    static func plan(width: Double, height: Double) -> Plan {
        if width > height * 1.15 {
            return landscape(width: width, height: height)
        }
        return portrait(width: width, height: height)
    }

    // MARK: - Portrait

    private static func portrait(width: Double, height: Double) -> Plan {
        let m = 4.0
        let g = 4.0
        let breathH = clamp(height * 0.15, 64, 108)
        let breath = Box(x: m, y: height - breathH, width: width - 2 * m, height: breathH - m)
        let top = m
        let bottom = breath.y - g
        let contentH = bottom - top
        let contentW = width - 2 * m

        let leftH = contentH * 0.58
        let sideW = min(86, contentW * 0.22)
        let mainW = contentW - sideW - g

        let palmH = min(52, max(32, leftH * 0.16))
        let pinkyH = min(56, max(34, leftH * 0.18))
        let midH = leftH - palmH - pinkyH - 2 * g
        let rowH = (midH - 2 * g) / 3

        let x0 = m
        let y0 = top
        let midY = y0 + palmH + g
        let pinkyY = midY + midH + g

        var keys: [SaxKey: Box] = [:]
        let palmKeys: [SaxKey] = [.palmD, .palmEFlat, .palmF]
        let palmW = (mainW - 2 * g) / 3
        for (index, key) in palmKeys.enumerated() {
            keys[key] = Box(x: x0 + Double(index) * (palmW + g), y: y0, width: palmW, height: palmH)
        }

        var octW = min(72, max(40, mainW * 0.22))
        var bisW = min(56, max(34, mainW * 0.18))
        if mainW - octW - bisW - 2 * g < 48 {
            octW = 40
            bisW = 34
        }
        let l1W = mainW - octW - bisW - 2 * g
        keys[.octave] = Box(x: x0, y: midY, width: octW, height: rowH)
        keys[.l1] = Box(x: x0 + octW + g, y: midY, width: l1W, height: rowH)
        keys[.bis] = Box(x: x0 + octW + g + l1W + g, y: midY, width: bisW, height: rowH)
        keys[.l2] = Box(x: x0, y: midY + rowH + g, width: mainW, height: rowH)
        keys[.l3] = Box(x: x0, y: midY + 2 * (rowH + g), width: mainW, height: rowH)

        let sideKeys: [SaxKey] = [.chromaticFSharp, .frontE, .sideC, .sideBFlat]
        let sideTop = y0
        let sideBottom = midY + midH
        let sideH = (sideBottom - sideTop - 3 * g) / 4
        let sideX = x0 + mainW + g
        for (index, key) in sideKeys.enumerated() {
            keys[key] = Box(x: sideX, y: sideTop + Double(index) * (sideH + g), width: sideW, height: sideH)
        }

        let pinkies: [SaxKey] = [.gSharp, .lowCSharp, .lowB, .lowBFlat]
        let pinkyW = (mainW - 3 * g) / 4
        for (index, key) in pinkies.enumerated() {
            keys[key] = Box(x: x0 + Double(index) * (pinkyW + g), y: pinkyY, width: pinkyW, height: pinkyH)
        }

        let rightY = y0 + leftH + g
        let rightH = bottom - rightY
        let rightPinkyH = min(52, max(32, rightH * 0.22))
        let stackH = rightH - rightPinkyH - g
        let rightRow = (stackH - 2 * g) / 3
        let rightKeys: [SaxKey] = [.r1, .r2, .r3]
        for (index, key) in rightKeys.enumerated() {
            keys[key] = Box(x: x0, y: rightY + Double(index) * (rightRow + g), width: contentW, height: rightRow)
        }
        let pinkyRowY = rightY + 3 * rightRow + 2 * g + g
        let half = (contentW - g) / 2
        keys[.lowEFlat] = Box(x: x0, y: pinkyRowY, width: half, height: rightPinkyH)
        keys[.lowC] = Box(x: x0 + half + g, y: pinkyRowY, width: half, height: rightPinkyH)

        return Plan(keys: keys, breath: breath)
    }

    // MARK: - Landscape

    private static func landscape(width: Double, height: Double) -> Plan {
        let m = 4.0
        let g = 4.0
        let breathH = clamp(height * 0.2, 56, 84)
        let breath = Box(x: m, y: height - breathH, width: width - 2 * m, height: breathH - m)
        let top = m
        let bottom = breath.y - g
        let contentH = bottom - top
        let contentW = width - 2 * m

        let leftW = contentW * 0.56
        let rightX = m + leftW + g
        let rightW = contentW - leftW - g
        let sideW = min(76, leftW * 0.22)
        let mainW = leftW - sideW - g

        let palmH = min(40, max(28, contentH * 0.16))
        let pinkyH = min(44, max(30, contentH * 0.18))
        let midH = contentH - palmH - pinkyH - 2 * g
        let rowH = (midH - 2 * g) / 3
        let y0 = top
        let midY = y0 + palmH + g
        let pinkyY = midY + midH + g

        var keys: [SaxKey: Box] = [:]
        let palmKeys: [SaxKey] = [.palmD, .palmEFlat, .palmF]
        let palmW = (mainW - 2 * g) / 3
        for (index, key) in palmKeys.enumerated() {
            keys[key] = Box(x: m + Double(index) * (palmW + g), y: y0, width: palmW, height: palmH)
        }

        var octW = min(64, max(36, mainW * 0.22))
        var bisW = min(48, max(30, mainW * 0.16))
        if mainW - octW - bisW - 2 * g < 40 {
            octW = 36
            bisW = 30
        }
        let l1W = mainW - octW - bisW - 2 * g
        keys[.octave] = Box(x: m, y: midY, width: octW, height: rowH)
        keys[.l1] = Box(x: m + octW + g, y: midY, width: l1W, height: rowH)
        keys[.bis] = Box(x: m + octW + g + l1W + g, y: midY, width: bisW, height: rowH)
        keys[.l2] = Box(x: m, y: midY + rowH + g, width: mainW, height: rowH)
        keys[.l3] = Box(x: m, y: midY + 2 * (rowH + g), width: mainW, height: rowH)

        let sideKeys: [SaxKey] = [.chromaticFSharp, .frontE, .sideC, .sideBFlat]
        let sideX = m + mainW + g
        let sideBottom = midY + midH
        let sideH = (sideBottom - y0 - 3 * g) / 4
        for (index, key) in sideKeys.enumerated() {
            keys[key] = Box(x: sideX, y: y0 + Double(index) * (sideH + g), width: sideW, height: sideH)
        }

        let pinkies: [SaxKey] = [.gSharp, .lowCSharp, .lowB, .lowBFlat]
        let pinkyW = (mainW - 3 * g) / 4
        for (index, key) in pinkies.enumerated() {
            keys[key] = Box(x: m + Double(index) * (pinkyW + g), y: pinkyY, width: pinkyW, height: pinkyH)
        }

        let rightPinkyH = min(48, max(30, contentH * 0.2))
        let stackH = contentH - rightPinkyH - g
        let rightRow = (stackH - 2 * g) / 3
        let rightKeys: [SaxKey] = [.r1, .r2, .r3]
        for (index, key) in rightKeys.enumerated() {
            keys[key] = Box(x: rightX, y: y0 + Double(index) * (rightRow + g), width: rightW, height: rightRow)
        }
        let pinkyRowY = y0 + 3 * rightRow + 2 * g + g
        let half = (rightW - g) / 2
        keys[.lowEFlat] = Box(x: rightX, y: pinkyRowY, width: half, height: rightPinkyH)
        keys[.lowC] = Box(x: rightX + half + g, y: pinkyRowY, width: half, height: rightPinkyH)

        return Plan(keys: keys, breath: breath)
    }

    private static func clamp(_ value: Double, _ low: Double, _ high: Double) -> Double {
        return min(max(value, low), high)
    }
}
