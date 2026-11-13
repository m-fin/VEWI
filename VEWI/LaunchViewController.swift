//
//  LaunchViewController.swift
//  VEWI
//
//  Start page: app title, a short quick-start, and buttons into play mode
//  and settings. Built in code; AppDelegate puts it in front of the game.
//

import UIKit

class LaunchViewController: UIViewController {

    //The playing screen from the storyboard. AppDelegate hands it over at launch.
    var gameViewController: UIViewController?

    private let stack = UIStackView(arrangedSubviews: [])

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "VEWI"
        view.backgroundColor = .black

        let titleLabel = makeLabel("VEWI", font: UIFont.boldSystemFont(ofSize: 56), color: .white)
        let subtitle = makeLabel("Virtual Electronic Wind Instrument", font: UIFont.systemFont(ofSize: 17), color: .lightGray)

        let quickStart = makeLabel(LaunchViewController.quickStartText, font: UIFont.systemFont(ofSize: 16), color: .white)
        quickStart.textAlignment = .left

        let play = makeButton("Play", action: #selector(playTapped), primary: true)
        let settings = makeButton("Settings", action: #selector(settingsTapped), primary: false)

        stack.axis = .vertical
        stack.alignment = .fill
        stack.spacing = 16
        stack.translatesAutoresizingMaskIntoConstraints = false
        for v in [titleLabel, subtitle, quickStart, play, settings] as [UIView] {
            stack.addArrangedSubview(v)
        }
        view.addSubview(stack)

        let guide = view.safeAreaLayoutGuide
        NSLayoutConstraint.activate([
            stack.centerYAnchor.constraint(equalTo: guide.centerYAnchor),
            stack.leadingAnchor.constraint(equalTo: guide.leadingAnchor, constant: 32),
            stack.trailingAnchor.constraint(equalTo: guide.trailingAnchor, constant: -32),
            play.heightAnchor.constraint(equalToConstant: 52),
            settings.heightAnchor.constraint(equalToConstant: 52)
        ])
    }

    static let quickStartText = """
    Quick start
    • Hold the on-screen keys like saxophone keys: left column for your left hand, right column for your right hand.
    • Lift every key to stop the sound.
    • In Settings, pick your sax's key (Concert, B\u{266D} or E\u{266D}), octave, sound and volume.
    • Tap Menu on the playing screen to come back here.
    """

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }

    // MARK: - Actions

    @objc private func playTapped() {
        guard let game = gameViewController else { return }
        navigationController?.pushViewController(game, animated: true)
    }

    @objc private func settingsTapped() {
        navigationController?.pushViewController(SettingsViewController(style: .grouped), animated: true)
    }

    // MARK: - Helpers

    private func makeLabel(_ text: String, font: UIFont, color: UIColor) -> UILabel {
        let l = UILabel()
        l.text = text
        l.font = font
        l.textColor = color
        l.textAlignment = .center
        l.numberOfLines = 0
        return l
    }

    func makeButton(_ title: String, action: Selector, primary: Bool) -> UIButton {
        let b = UIButton(type: .system)
        b.setTitle(title, for: .normal)
        b.titleLabel?.font = UIFont.boldSystemFont(ofSize: 20)
        b.setTitleColor(primary ? .black : .white, for: .normal)
        b.backgroundColor = primary ? .white : UIColor(white: 0.2, alpha: 1)
        b.layer.cornerRadius = 12
        b.addTarget(self, action: action, for: .touchUpInside)
        return b
    }
}
