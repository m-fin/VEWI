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
                
                // Present the scene
                view.presentScene(scene)
            }
            
            view.ignoresSiblingOrder = true
            
            view.showsFPS = true
            view.showsNodeCount = true
        }
        
        addMenuButton()
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
