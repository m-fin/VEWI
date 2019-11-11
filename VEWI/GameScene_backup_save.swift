//
//  GameScene.swift
//  VirtualSax-Beta1
//
//  Created by Matthew Finley on 6/6/19.
//  Copyright © 2019 Matthew Finley. All rights reserved.
//

import SpriteKit
import GameplayKit

import UIKit
import AudioKit
import AudioKitUI

class GameScene: SKScene {
    
    //Initializes keys as sprite nodes
    var arraySprites :[SKSpriteNode] = [SKSpriteNode]()
    
    var key0 = SKSpriteNode()
    var key1 = SKSpriteNode()
    var key2 = SKSpriteNode()
    var key3 = SKSpriteNode()
    var key4 = SKSpriteNode()
    var key5 = SKSpriteNode()
    
    var arrKey :[SKSpriteNode] = [SKSpriteNode]()

    
    override func didMove(to view: SKView) {

        
        //Connects sprites from scene editor to code
        key0 = (self.childNode(withName: "key0") as? SKSpriteNode)!
        key1 = (self.childNode(withName: "key1") as? SKSpriteNode)!
        key2 = (self.childNode(withName: "key2") as? SKSpriteNode)!
        key3 = (self.childNode(withName: "key3") as? SKSpriteNode)!
        key4 = (self.childNode(withName: "key4") as? SKSpriteNode)!
        key5 = (self.childNode(withName: "key5") as? SKSpriteNode)!
        
        arrKey = [key0, key1, key2, key3, key4, key5]
        }
    

    
    //Initializes oscillator
    @IBOutlet var plot: AKNodeOutputPlot?
    
    var oscillator = AKOscillator()
    var mixer = AKMixer()
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        mixer = AKMixer(oscillator)
        mixer.volume = 1
        AudioKit.output = mixer
        do {
            try AudioKit.start()
            oscillator.frequency = 0
            oscillator.start()
        } catch {
            AKLog("AudioKit did not start!")
        }
    }
    
    //Booleans declared and initialized to represent if key is up or down
    var blnKey = [false, false, false, false, false, false]
    
    //Whenever any key is changed, this method is called to change the pitch accordingly
    func updateSound() {
        oscillator.frequency = finalPitch(saxNote: getSaxNote())
        print("blnKey1: \(blnKey[0])")
        print("blnKey2: \(blnKey[1])")
        print("blnKey3: \(blnKey[2])")
        print("blnKey4: \(blnKey[3])")
        print("blnKey5: \(blnKey[4])")
        print("blnKey6: \(blnKey[5])")
    }
    
    //Logic to determine note being played based on position of keys
    /*
     Null = -1
     A = 0
     A#/Bb = 1
     B = 2
     C = 3
     C#/Db = 4
     D = 5
     D#/Eb = 6
     E = 7
     F = 8
     F#/Gb = 9
     G = 10
     G#/Ab = 11
     */
    func getSaxNote() -> Int {
        //C
        if (!blnKey[0] && blnKey[1]) {
            return 3
        }
        //B
        else if (blnKey[0] && !blnKey[1])
        {
            return 2
        }
        //A
        else if (blnKey[0] && blnKey[1] && !blnKey[2]) {
            return 0
        }
        //G
        else if (blnKey[0] && blnKey[1] && blnKey[2]) {
            return 10
        }
        else {
            return -1
        }
    }
        /*
        //F#
        else if (!blnKey4 && (blnKey5 || blnKey6) || (blnKey5 && blnKey6)) {
            return 9
        }
        //F
        else if (blnKey4 && !blnKey5) {
            return 8
        }
            //E
        else if (blnKey4 && blnKey5 && !blnKey6) {
            return 7
        }
            //D
        else if (blnKey4 && blnKey5 && blnKey6) {
            return 5
        }
        else {
            return -1
        }
    }
 */
    
    //Takes inputted sax note, converts to numerical value (0-11, for notes A, A#/Bb, B, C.. G#/Ab), augments value to account for transposition, adjusts for octave, then finally converts note to pitch in hertz
    func finalPitch(saxNote: Int) -> Double {
        let octave = 0 //implement later for user control
        var finalNote = 0.00
        
        //First octave
        if (octave == 0 && saxNote >= 0) {
            if (saxNote <= 3) {
                finalNote = 440 * pow(pow(2, 1 / 12), Double(saxNote))
            }
            else {
                finalNote = 220 * pow(pow(2, 1 / 12), Double(saxNote))
            }
                /*
             Formula for the frequencies of equal tempered notes: fn = f0 * (a)^n
             In this case, I am using A3 = 220 Hz as the fixed frequency and calculating all pitches based on this fixed pitch
             */
            print(finalNote) //for debugging purposes
            return finalNote
        }
        else {
            return 0.00
        }
    }
        
    //private???
    var activeTouches = [UITouch:String]()
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            let button = findButtonName(from:touch)
            activeTouches[touch] = button
            tapBegin(on: button)
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            guard let button = activeTouches[touch] else { fatalError("Touch just ended but not found into activeTouches")}
            activeTouches[touch] = nil
            tapEnd(on: button)
        }
    }
    
    private func tapBegin(on button: String) {
        print("Begin press \(button)")
        
        for n in 0...5 {
            if (button == arrKey[n].name) {
                blnKey[n] = true
            }
        }
        /*
        if (button == key1.name) {
            blnKey1 = true
        }
        else if (button == key2.name) {
            blnKey2 = true
        }
        else if (button == key3.name) {
            blnKey3 = true
        }
        else if (button == key4.name) {
            blnKey4 = true
        }
        else if (button == key5.name) {
            blnKey5 = true
        }
        else if (button == key6.name) {
            blnKey6 = true
        }
        */
        updateSound()
    }
    
    private func tapEnd(on button:String) {
        print("End press \(button)")
        
        for n in 0...5 {
            if (button == arrKey[n].name) {
                blnKey[n] = false
            }
        }
        
        /*
        if (button == key1.name) {
            blnKey[0] = false
        }
        else if (button == key2.name) {
            blnKey[1] = false
        }
        else if (button == key3.name) {
            blnKey[2] = false
        }
        else if (button == key4.name) {
            blnKey[3] = false
        }
        else if (button == key5.name) {
            blnKey[4] = false
        }
        else if (button == key6.name) {
            blnKey[5] = false
        }
        */
        updateSound()
    }
    
    private func findButtonName(from touch: UITouch) -> String {
        let location = touch.location(in: self)
        
        for n in 0...5 {
            if (location.x > (arrKey[n].position.x - arrKey[n].size.width / 2) && location.x < (arrKey[n].position.x + arrKey[n].size.width / 2)) && location.y > (arrKey[n].position.y - arrKey[n].size.height / 2) && location.y < (arrKey[n].position.y + arrKey[n].size.height / 2) {
                return arrKey[n].name!
            }
        }
        
        return "null_space"
    }
        /*
        if (location.x > (key1.position.x - key1.size.width / 2) && location.x < (key1.position.x + key1.size.width / 2)) && location.y > (key1.position.y - key1.size.height / 2) && location.y < (key1.position.y + key1.size.height / 2) {
            return "key1"
        }
        else if (location.x > (key2.position.x - key2.size.width / 2) && location.x < (key2.position.x + key2.size.width / 2)) && location.y > (key2.position.y - key2.size.height / 2) && location.y < (key2.position.y + key2.size.height / 2) {
            return "key2"
        }
        else if (location.x > (key3.position.x - key3.size.width / 2) && location.x < (key3.position.x + key3.size.width / 2)) && location.y > (key3.position.y - key3.size.height / 2) && location.y < (key3.position.y + key3.size.height / 2) {
            return "key3"
        }
        else if (location.x > (key4.position.x - key4.size.width / 2) && location.x < (key4.position.x + key4.size.width / 2)) && location.y > (key4.position.y - key4.size.height / 2) && location.y < (key4.position.y + key4.size.height / 2) {
            return "key4"
        }
        else if (location.x > (key5.position.x - key5.size.width / 2) && location.x < (key5.position.x + key5.size.width / 2)) && location.y > (key5.position.y - key5.size.height / 2) && location.y < (key5.position.y + key5.size.height / 2) {
            return "key5"
        }
        else if (location.x > (key6.position.x - key6.size.width / 2) && location.x < (key6.position.x + key6.size.width / 2)) && location.y > (key6.position.y - key6.size.height / 2) && location.y < (key6.position.y + key6.size.height / 2) {
            return "key6"
        }
        else {
            return "null_space"
        }
        */
}

/*
 class Button:SKSpriteNode {
 init(size:CGSize, color:SKColor) {
 
 super.init(texture: nil, color: color, size: size)
 
 isUserInteractionEnabled = true
 }
 
 override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
 if let name = self.name {
 print("Button with \(name) pressed")
 }
 }
 
 override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
 if let name = self.name {
 print("Button with \(name) pressed")
 }
 }
 
 override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
 if let name = self.name {
 print("Button with \(name) released")
 }
 }
 
 required init?(coder aDecoder: NSCoder) {
 fatalError("init(coder:) has not been implemented")
 }
 }
 
 class GameScene: SKScene {
 override func didMove(to view: SKView) {
 
 let left = Button(size: CGSize(width: 100, height: 100), color: .black)
 left.name = "left"
 left.position = CGPoint(x: left.size.width/2.0, y: frame.midY)
 
 let right = Button(size: CGSize(width: 100, height: 100), color: .white)
 right.name = "right"
 right.position = CGPoint(x:frame.maxX-right.size.width/2.0, y: frame.midY)
 
 addChild(left)
 addChild(right)
 */
/*
 import SpriteKit
 import GameplayKit
 
 class GameScene: SKScene {
 
 var blnKey1 = false
 var blnKey2 = false
 
 override func didMove(to view: SKView) {
 }
 
 override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?)
 {
 let touch:UITouch = touches.first!
 let positionInScene = touch.location(in: self)
 let touchedNode = self.atPoint(positionInScene)
 
 if touchedNode.name == "key1"
 {
 blnKey1 = true
 }
 if touchedNode.name == "key2"
 {
 blnKey2 = true
 }
 
 }
 override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
 let touch:UITouch = touches.first!
 let positionInScene = touch.location(in: self)
 let touchedNode = self.atPoint(positionInScene)
 
 if touchedNode.name == "key1"
 {
 blnKey1 = false
 }
 if touchedNode.name == "key2"
 {
 blnKey2 = false
 }
 }
 override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
 let touch:UITouch = touches.first!
 let positionInScene = touch.location(in: self)
 let touchedNode = self.atPoint(positionInScene)
 
 if touchedNode.name == "key1" {
 blnKey1 = true
 }
 else {
 blnKey1 = false
 }
 if touchedNode.name == "key2" {
 blnKey2 = true
 }
 else {
 blnKey2 = false
 }
 }
 
 func updateKey() {
 if (blnKey1) {
 print("1: down")
 }
 else {
 print("1: up")
 }
 
 if (blnKey2) {
 print("2: down")
 }
 else {
 print("2: up")
 }
 }
 
 override func update(_ currentTime: TimeInterval) {
 updateKey()
 }
 }
 */
