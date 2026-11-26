//
//  SaxKeyboardView.swift
//  VEWI
//
//  Both hands on one screen. Every touch is tracked until it ends or the
//  system cancels it, and a finger can slide from key to key without
//  leaving the old key down.
//

import UIKit

final class SaxKeyboardView: UIView {
    var onChange: ((Set<SaxKey>, BreathState) -> Void)?

    private(set) var breath = BreathState()
    private var pads: [SaxKey: KeyPad] = [:]
    private let breathPad = BreathPad()
    private var tracker = KeyTouchTracker<ObjectIdentifier>()
    private var breathTouches = Set<ObjectIdentifier>()
    private var liveTouches: [ObjectIdentifier: UITouch] = [:]

    override init(frame: CGRect) {
        super.init(frame: frame)
        isMultipleTouchEnabled = true
        backgroundColor = UIColor(red: 0.06, green: 0.07, blue: 0.09, alpha: 1)
        for key in SaxKey.allCases {
            let pad = KeyPad(key: key)
            pads[key] = pad
            addSubview(pad)
        }
        addSubview(breathPad)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func apply(mode: BreathMode) {
        if breath.mode != mode {
            breath.padHeld = false
            breath.slideLevel = 0
            breath.latched = false
            breath.micLevel = 0
            breathTouches.removeAll()
        }
        breath.mode = mode
        publish()
    }

    func setMicLevel(_ level: Double) {
        guard breath.mode == .microphone else { return }
        breath.micLevel = level
        publish()
    }

    /// Phone call, backgrounding, or leaving the screen. Nothing stays down.
    func releaseAll() {
        tracker.endAll()
        breathTouches.removeAll()
        liveTouches.removeAll()
        breath.padHeld = false
        breath.slideLevel = 0
        breath.latched = false
        breath.micLevel = 0
        publish()
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        let plan = SaxLayout.plan(width: Double(bounds.width), height: Double(bounds.height))
        for (key, box) in plan.keys {
            pads[key]?.frame = CGRect(x: box.x, y: box.y, width: box.width, height: box.height)
        }
        breathPad.frame = CGRect(x: plan.breath.x, y: plan.breath.y, width: plan.breath.width, height: plan.breath.height)
        breathPad.setNeedsLayout()
    }

    // MARK: - Touches

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            if breath.mode == .latch, breathPad.frame.contains(touch.location(in: self)) {
                breath.toggleLatch()
                continue
            }
            assign(touch)
        }
        syncBreath()
        publish()
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches { assign(touch) }
        syncBreath()
        publish()
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        release(touches)
    }

    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        release(touches)
    }

    private func assign(_ touch: UITouch) {
        let id = ObjectIdentifier(touch)
        liveTouches[id] = touch
        let point = touch.location(in: self)
        if breath.mode != .microphone, breathPad.frame.contains(point) {
            tracker.move(id, to: nil)
            breathTouches.insert(id)
        } else if let key = key(at: point) {
            breathTouches.remove(id)
            tracker.move(id, to: key)
        } else {
            breathTouches.remove(id)
            tracker.move(id, to: nil)
        }
    }

    private func release(_ touches: Set<UITouch>) {
        for touch in touches {
            let id = ObjectIdentifier(touch)
            tracker.end(id)
            breathTouches.remove(id)
            liveTouches.removeValue(forKey: id)
        }
        syncBreath()
        publish()
    }

    private func key(at point: CGPoint) -> SaxKey? {
        var best: (SaxKey, CGFloat)?
        for (key, pad) in pads where pad.frame.contains(point) {
            let area = pad.frame.width * pad.frame.height
            if best == nil || area < best!.1 {
                best = (key, area)
            }
        }
        return best?.0
    }

    private func syncBreath() {
        switch breath.mode {
        case .hold:
            breath.padHeld = !breathTouches.isEmpty
        case .slide:
            var level = 0.0
            var touching = false
            for id in breathTouches {
                guard let touch = liveTouches[id] else { continue }
                let y = touch.location(in: self).y
                let pad = breathPad.frame
                let fraction = 1 - ((y - pad.minY) / max(pad.height, 1))
                level = max(level, min(1, max(0.12, fraction)))
                touching = true
            }
            breath.slideLevel = touching ? level : 0
        case .latch, .microphone:
            break
        }
    }

    private func publish() {
        for (key, pad) in pads {
            pad.isDown = tracker.pressed.contains(key)
        }
        breathPad.update(mode: breath.mode, active: breath.isBlowing, level: breath.expression)
        onChange?(tracker.pressed, breath)
    }
}

// MARK: - Key

private final class KeyPad: UIView {
    let saxKey: SaxKey
    private let label = UILabel()

    var isDown = false {
        didSet { if isDown != oldValue { apply() } }
    }

    init(key: SaxKey) {
        saxKey = key
        super.init(frame: .zero)
        isUserInteractionEnabled = false
        isAccessibilityElement = true
        accessibilityLabel = key.shortName
        layer.cornerRadius = 12
        clipsToBounds = true
        label.text = key.buttonTitle
        label.numberOfLines = 2
        label.textAlignment = .center
        label.font = .systemFont(ofSize: 13, weight: .semibold)
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.6
        label.translatesAutoresizingMaskIntoConstraints = false
        addSubview(label)
        NSLayoutConstraint.activate([
            label.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 2),
            label.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -2),
            label.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
        apply()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func apply() {
        if isDown {
            backgroundColor = UIColor(red: 0.96, green: 0.66, blue: 0.16, alpha: 1)
            label.textColor = .black
        } else {
            backgroundColor = saxKey.family.color
            label.textColor = .white
        }
    }
}

private extension SaxKey.Family {
    var color: UIColor {
        switch self {
        case .leftStack: return UIColor(red: 0.16, green: 0.24, blue: 0.34, alpha: 1)
        case .rightStack: return UIColor(red: 0.12, green: 0.28, blue: 0.26, alpha: 1)
        case .octave: return UIColor(red: 0.12, green: 0.27, blue: 0.42, alpha: 1)
        case .bis: return UIColor(red: 0.28, green: 0.22, blue: 0.12, alpha: 1)
        case .pinky: return UIColor(red: 0.24, green: 0.18, blue: 0.32, alpha: 1)
        case .palm: return UIColor(red: 0.36, green: 0.18, blue: 0.16, alpha: 1)
        case .side: return UIColor(red: 0.32, green: 0.22, blue: 0.10, alpha: 1)
        }
    }
}

// MARK: - Breath

private final class BreathPad: UIView {
    private let fill = UIView()
    private let label = UILabel()
    private var level = 0.0

    override init(frame: CGRect) {
        super.init(frame: frame)
        isUserInteractionEnabled = false
        isAccessibilityElement = true
        accessibilityLabel = "Breath"
        layer.cornerRadius = 16
        clipsToBounds = true
        backgroundColor = UIColor(red: 0.08, green: 0.16, blue: 0.12, alpha: 1)
        fill.backgroundColor = UIColor(red: 0.18, green: 0.62, blue: 0.36, alpha: 1)
        addSubview(fill)
        label.numberOfLines = 2
        label.textAlignment = .center
        label.font = .systemFont(ofSize: 15, weight: .bold)
        label.textColor = .white
        label.translatesAutoresizingMaskIntoConstraints = false
        addSubview(label)
        NSLayoutConstraint.activate([
            label.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 8),
            label.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -8),
            label.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func update(mode: BreathMode, active: Bool, level: Double) {
        self.level = level
        switch mode {
        case .hold:
            label.text = active ? "BREATH" : "HOLD TO BLOW"
        case .latch:
            label.text = active ? "BREATH ON" : "TAP TO BLOW"
        case .slide:
            label.text = "SLIDE  ·  BREATH"
        case .microphone:
            label.text = active ? "MIC" : "BLOW INTO THE MIC"
        }
        accessibilityValue = active ? "on" : "off"
        setNeedsLayout()
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        let amount = CGFloat(min(max(level, 0), 1))
        if amount <= 0 {
            fill.frame = .zero
            return
        }
        fill.frame = CGRect(x: 0, y: bounds.height * (1 - amount), width: bounds.width, height: bounds.height * amount)
    }
}
