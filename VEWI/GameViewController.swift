//
//  GameViewController.swift
//  VEWI
//
//  Playing screen: real alto keys, a breath pad, and the note you're sounding.
//

import UIKit
import AVFoundation

class GameViewController: UIViewController {
    private let keyboard = SaxKeyboardView()
    private let noteLabel = UILabel()
    private let hintLabel = UILabel()
    private let menuButton = UIButton(type: .system)
    private let chartButton = UIButton(type: .system)
    private let hintButton = UIButton(type: .system)
    private let synth = SaxSynth()
    private var settings = SaxSettings.load()
    private var pressed: Set<SaxKey> = []
    private var breath = BreathState()
    private var micTimer: Timer?
    private var hintHeight: NSLayoutConstraint?

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        buildChrome()
        keyboard.onChange = { [weak self] keys, breath in
            self?.pressed = keys
            self?.breath = breath
            self?.pushAudio()
        }
        synth.prepare(settings: settings)
        synth.start()
        keyboard.apply(mode: settings.breathMode)
        applyChrome()
        pushAudio()

        NotificationCenter.default.addObserver(self, selector: #selector(settingsDidChange), name: SaxSettings.didChangeNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(silenceForInterruption), name: UIApplication.willResignActiveNotification, object: nil)
    }

    deinit {
        micTimer?.invalidate()
        synth.stop()
        NotificationCenter.default.removeObserver(self)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
        settings = SaxSettings.load()
        keyboard.apply(mode: settings.breathMode)
        applyChrome()
        configureMicrophone()
        pushAudio()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
        silenceForInterruption()
    }

    override var prefersStatusBarHidden: Bool { return true }

    override var preferredScreenEdgesDeferringSystemGestures: UIRectEdge { return .all }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return UIDevice.current.userInterfaceIdiom == .phone ? .allButUpsideDown : .all
    }

    // MARK: - Chrome

    private func buildChrome() {
        noteLabel.textColor = .white
        noteLabel.font = .monospacedDigitSystemFont(ofSize: 17, weight: .semibold)
        noteLabel.textAlignment = .center
        noteLabel.adjustsFontSizeToFitWidth = true
        noteLabel.minimumScaleFactor = 0.55
        noteLabel.translatesAutoresizingMaskIntoConstraints = false

        hintLabel.textColor = UIColor(white: 0.82, alpha: 1)
        hintLabel.font = .monospacedSystemFont(ofSize: 13, weight: .medium)
        hintLabel.textAlignment = .center
        hintLabel.adjustsFontSizeToFitWidth = true
        hintLabel.minimumScaleFactor = 0.6
        hintLabel.translatesAutoresizingMaskIntoConstraints = false

        configure(menuButton, title: "\u{2039} Menu", action: #selector(menuTapped))
        configure(chartButton, title: "Chart", action: #selector(chartTapped))
        configure(hintButton, title: "Hint", action: #selector(hintTapped))

        keyboard.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(noteLabel)
        view.addSubview(hintLabel)
        view.addSubview(menuButton)
        view.addSubview(chartButton)
        view.addSubview(hintButton)
        view.addSubview(keyboard)

        let guide = view.safeAreaLayoutGuide
        let hint = hintLabel.heightAnchor.constraint(equalToConstant: 0)
        hintHeight = hint
        NSLayoutConstraint.activate([
            menuButton.topAnchor.constraint(equalTo: guide.topAnchor, constant: 4),
            menuButton.leadingAnchor.constraint(equalTo: guide.leadingAnchor, constant: 12),
            chartButton.centerYAnchor.constraint(equalTo: menuButton.centerYAnchor),
            chartButton.trailingAnchor.constraint(equalTo: guide.trailingAnchor, constant: -12),
            hintButton.centerYAnchor.constraint(equalTo: menuButton.centerYAnchor),
            hintButton.trailingAnchor.constraint(equalTo: chartButton.leadingAnchor, constant: -12),
            noteLabel.centerYAnchor.constraint(equalTo: menuButton.centerYAnchor),
            noteLabel.leadingAnchor.constraint(equalTo: menuButton.trailingAnchor, constant: 8),
            noteLabel.trailingAnchor.constraint(equalTo: hintButton.leadingAnchor, constant: -8),
            hintLabel.topAnchor.constraint(equalTo: menuButton.bottomAnchor, constant: 2),
            hintLabel.leadingAnchor.constraint(equalTo: guide.leadingAnchor, constant: 12),
            hintLabel.trailingAnchor.constraint(equalTo: guide.trailingAnchor, constant: -12),
            hint,
            keyboard.topAnchor.constraint(equalTo: hintLabel.bottomAnchor, constant: 4),
            keyboard.leadingAnchor.constraint(equalTo: guide.leadingAnchor),
            keyboard.trailingAnchor.constraint(equalTo: guide.trailingAnchor),
            keyboard.bottomAnchor.constraint(equalTo: guide.bottomAnchor)
        ])
    }

    private func configure(_ button: UIButton, title: String, action: Selector) {
        button.setTitle(title, for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = .boldSystemFont(ofSize: 16)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: action, for: .touchUpInside)
    }

    private func applyChrome() {
        noteLabel.isHidden = !settings.showNoteName
        let showHint = settings.showFingeringHint
        hintLabel.isHidden = !showHint
        hintHeight?.constant = showHint ? 18 : 0
        hintButton.setTitleColor(showHint ? UIColor(red: 0.96, green: 0.66, blue: 0.16, alpha: 1) : .white, for: .normal)
        chartButton.isHidden = !settings.showFingeringChart
    }

    // MARK: - Sound

    private func pushAudio() {
        let fingered = FingeringEngine.fingeredNote(pressed)
        let hz = NoteDisplay.frequency(written: fingered, transposition: settings.transposition, octaveShift: settings.octaveShift)
        let expression = settings.breathMode == .microphone ? 0 : breath.expression
        synth.play(frequency: hz, expression: expression, settings: settings)

        let written = FingeringEngine.writtenNote(holding: pressed, blowing: breath.isBlowing)
        noteLabel.text = NoteDisplay.text(written: written, transposition: settings.transposition, octaveShift: settings.octaveShift)
        hintLabel.text = FingeringChart.diagram(pressed)
        if let written {
            SharedPractice.saveLastWrittenNote(written)
        }
    }

    private func configureMicrophone() {
        guard settings.breathMode == .microphone else {
            micTimer?.invalidate()
            micTimer = nil
            synth.setMicEnabled(false)
            return
        }
        requestMic { [weak self] allowed in
            guard let self else { return }
            if allowed {
                self.synth.setMicEnabled(true)
                self.startMicTimer()
            } else {
                self.settings.breathMode = .hold
                self.settings.save()
                self.keyboard.apply(mode: .hold)
                self.breath = BreathState(mode: .hold)
            }
        }
    }

    private func requestMic(_ done: @escaping (Bool) -> Void) {
        if #available(iOS 17.0, *) {
            AVAudioApplication.requestRecordPermission { allowed in
                DispatchQueue.main.async { done(allowed) }
            }
        } else {
            AVAudioSession.sharedInstance().requestRecordPermission { allowed in
                DispatchQueue.main.async { done(allowed) }
            }
        }
    }

    private func startMicTimer() {
        micTimer?.invalidate()
        micTimer = Timer.scheduledTimer(withTimeInterval: 0.05, repeats: true) { [weak self] _ in
            guard let self else { return }
            self.keyboard.setMicLevel(self.synth.meterLevel())
        }
    }

    @objc private func settingsDidChange() {
        let previousBreath = settings.breathMode
        settings = SaxSettings.load()
        keyboard.apply(mode: settings.breathMode)
        applyChrome()
        if settings.breathMode != previousBreath {
            configureMicrophone()
        }
        pushAudio()
    }

    @objc private func silenceForInterruption() {
        keyboard.releaseAll()
        pressed = []
        breath = BreathState(mode: settings.breathMode)
        synth.silence()
        noteLabel.text = ""
        hintLabel.text = FingeringChart.diagram([])
    }

    @objc private func menuTapped() {
        navigationController?.popViewController(animated: true)
    }

    @objc private func chartTapped() {
        navigationController?.pushViewController(FingeringChartViewController(style: .insetGrouped), animated: true)
    }

    @objc private func hintTapped() {
        settings.showFingeringHint.toggle()
        settings.save()
        applyChrome()
        NotificationCenter.default.post(name: SaxSettings.didChangeNotification, object: nil)
    }
}
