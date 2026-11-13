//
//  GameViewController.swift
//  VirtualSax-Beta1
//
//  Created by Matthew Finley on 6/6/19.
//  Copyright © 2019 Matthew Finley. All rights reserved.
//

import UIKit
import SpriteKit
import GameplayKit

class GameViewController: UIViewController {
    
    //Hides navigation bar for Game Scene
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let view = self.view as! SKView? {
            // Load the SKScene from 'GameScene.sks'
            if let scene = SKScene(fileNamed: "GameScene") {
                // Set the scale mode to scale to fit the window
                scene.scaleMode = .aspectFill
                
                //Show the note being played at the top of the screen
                (scene as? GameScene)?.onNoteChange = { [weak self] note in
                    self?.showNote(note)
                }
                
                // Present the scene
                view.presentScene(scene)
            }
            
            view.ignoresSiblingOrder = true
            
            view.showsFPS = true
            view.showsNodeCount = true
        }
        
        addMenuButton()
        addNoteLabelAndChartButton()
    }
    
    private let noteLabel = UILabel()
    private let chartButton = UIButton(type: .system)
    private var settings = SaxSettings.load()
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        //Settings may have changed while another screen was open
        settings = SaxSettings.load()
        noteLabel.isHidden = !settings.showNoteName
        chartButton.isHidden = !settings.showFingeringChart
    }
    
    //Note name + pitch at the top center, and the Chart button at the top right
    private func addNoteLabelAndChartButton() {
        noteLabel.textColor = .white
        noteLabel.font = UIFont.monospacedDigitSystemFont(ofSize: 20, weight: .semibold)
        noteLabel.textAlignment = .center
        noteLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(noteLabel)
        
        chartButton.setTitle("Chart", for: .normal)
        chartButton.setTitleColor(.white, for: .normal)
        chartButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 17)
        chartButton.translatesAutoresizingMaskIntoConstraints = false
        chartButton.addTarget(self, action: #selector(chartTapped), for: .touchUpInside)
        view.addSubview(chartButton)
        
        let guide = view.safeAreaLayoutGuide
        NSLayoutConstraint.activate([
            noteLabel.topAnchor.constraint(equalTo: guide.topAnchor, constant: 8),
            noteLabel.centerXAnchor.constraint(equalTo: guide.centerXAnchor),
            chartButton.topAnchor.constraint(equalTo: guide.topAnchor, constant: 8),
            chartButton.trailingAnchor.constraint(equalTo: guide.trailingAnchor, constant: -12)
        ])
        noteLabel.isHidden = !settings.showNoteName
        chartButton.isHidden = !settings.showFingeringChart
    }
    
    private func showNote(_ note: Int) {
        noteLabel.text = NoteDisplay.text(written: note, transposition: settings.transposition, octaveShift: settings.octaveShift)
    }
    
    @objc private func chartTapped() {
        navigationController?.pushViewController(FingeringChartViewController(style: .grouped), animated: true)
    }
    
    //Small button back to the start page (the navigation bar is hidden while playing)
    private func addMenuButton() {
        let menu = UIButton(type: .system)
        menu.setTitle("\u{2039} Menu", for: .normal)
        menu.setTitleColor(.white, for: .normal)
        menu.titleLabel?.font = UIFont.boldSystemFont(ofSize: 17)
        menu.translatesAutoresizingMaskIntoConstraints = false
        menu.addTarget(self, action: #selector(menuTapped), for: .touchUpInside)
        view.addSubview(menu)
        NSLayoutConstraint.activate([
            menu.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 8),
            menu.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 12)
        ])
    }
    
    @objc private func menuTapped() {
        navigationController?.popViewController(animated: true)
    }

    //The storyboard's settings button opens the settings screen built in code (SettingsViewController)
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        navigationController?.pushViewController(SettingsViewController(style: .grouped), animated: true)
        return false
    }

    override var shouldAutorotate: Bool {
        return true
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        if UIDevice.current.userInterfaceIdiom == .phone {
            return .allButUpsideDown
        } else {
            return .all
        }
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }
}
