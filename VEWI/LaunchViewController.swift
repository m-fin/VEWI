//
//  LaunchViewController.swift
//  VEWI
//
//  Start page. AppDelegate puts this in front of the playing screen.
//

import UIKit

class LaunchViewController: UIViewController {
    var gameViewController: UIViewController?

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "VEWI"
        view.backgroundColor = .black

        let titleLabel = makeLabel("VEWI", font: .boldSystemFont(ofSize: 56), color: .white)
        let subtitle = makeLabel("Virtual Electronic Wind Instrument", font: .systemFont(ofSize: 17), color: .lightGray)
        let quickStart = makeLabel(LaunchViewController.quickStartText, font: .systemFont(ofSize: 16), color: .white)
        quickStart.textAlignment = .left

        let play = makeButton("Play", action: #selector(playTapped), primary: true)
        let settings = makeButton("Settings", action: #selector(settingsTapped), primary: false)
        let chart = makeButton("Fingering Chart", action: #selector(chartTapped), primary: false)

        let stack = UIStackView(arrangedSubviews: [titleLabel, subtitle, quickStart, play, settings, chart])
        stack.axis = .vertical
        stack.alignment = .fill
        stack.spacing = 16
        stack.translatesAutoresizingMaskIntoConstraints = false

        let scroll = UIScrollView()
        scroll.translatesAutoresizingMaskIntoConstraints = false
        scroll.addSubview(stack)
        view.addSubview(scroll)

        let guide = view.safeAreaLayoutGuide
        NSLayoutConstraint.activate([
            scroll.topAnchor.constraint(equalTo: guide.topAnchor),
            scroll.bottomAnchor.constraint(equalTo: guide.bottomAnchor),
            scroll.leadingAnchor.constraint(equalTo: guide.leadingAnchor),
            scroll.trailingAnchor.constraint(equalTo: guide.trailingAnchor),
            scroll.contentLayoutGuide.widthAnchor.constraint(equalTo: scroll.frameLayoutGuide.widthAnchor),
            stack.leadingAnchor.constraint(equalTo: scroll.contentLayoutGuide.leadingAnchor, constant: 28),
            stack.trailingAnchor.constraint(equalTo: scroll.contentLayoutGuide.trailingAnchor, constant: -28),
            stack.topAnchor.constraint(equalTo: scroll.contentLayoutGuide.topAnchor, constant: 36),
            stack.bottomAnchor.constraint(equalTo: scroll.contentLayoutGuide.bottomAnchor, constant: -36),
            play.heightAnchor.constraint(equalToConstant: 52),
            settings.heightAnchor.constraint(equalToConstant: 52),
            chart.heightAnchor.constraint(equalToConstant: 52)
        ])
    }

    static let quickStartText = """
    Quick start
    • Left hand on top: octave (thumb), L1 B, L2 A, L3 G, and the pinky table. Right hand below: R1 F, R2 E, R3 D.
    • Hold the breath pad to play. Nothing pressed is open C♯ — lift the pad to stop.
    • Bis, side B♭ (Ta), and 1+1 are the three B♭s. The F♯ key is the chromatic F♯.
    • Settings defaults to alto (E♭): written A sounds concert C. B♭ and concert are there too.
    """

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }

    override var prefersStatusBarHidden: Bool { return true }

    @objc private func playTapped() {
        guard let game = gameViewController else { return }
        navigationController?.pushViewController(game, animated: true)
    }

    @objc private func settingsTapped() {
        navigationController?.pushViewController(SettingsViewController(style: .insetGrouped), animated: true)
    }

    @objc private func chartTapped() {
        navigationController?.pushViewController(FingeringChartViewController(style: .insetGrouped), animated: true)
    }

    private func makeLabel(_ text: String, font: UIFont, color: UIColor) -> UILabel {
        let label = UILabel()
        label.text = text
        label.font = font
        label.textColor = color
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }

    private func makeButton(_ title: String, action: Selector, primary: Bool) -> UIButton {
        let button = UIButton(type: .system)
        button.setTitle(title, for: .normal)
        button.titleLabel?.font = .boldSystemFont(ofSize: 20)
        button.setTitleColor(primary ? .black : .white, for: .normal)
        button.backgroundColor = primary ? .white : UIColor(white: 0.16, alpha: 1)
        button.layer.cornerRadius = 12
        button.addTarget(self, action: action, for: .touchUpInside)
        return button
    }
}
