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

let square = AKTable(.square, count: 256)
let triangle = AKTable(.triangle, count: 256)
let sine = AKTable(.sine, count: 256)
let sawtooth = AKTable(.sawtooth, count: 256)

class GameScene: SKScene {
    /*
    func onUserAction(data: Int)
    {
        testNum = data
        
        for n in 0...99 {
            print(testNum)
        }
    }
 */

    
    /*
    
    //Transposition
    var transpositionValue = 0
    
    @IBOutlet weak var segTransposition: UISegmentedControl!
    
    @IBAction func segTranspositionChanged(_ sender: UISegmentedControl) {
        //C
        if (segTransposition.selectedSegmentIndex == 0) {
            transpositionValue = 0
        }
        //Bb
        else if (segTransposition.selectedSegmentIndex == 1) {
            transpositionValue = -2
        }
        //Eb
        else if (segTransposition.selectedSegmentIndex == 2) {
            transpositionValue = -9
        }
        else {
            transpositionValue = 0
        }
    }
    
    //Octave modifier
    var octaveValue = 0.00
    
    @IBOutlet weak var lblOctaveModifier: UILabel!
    
    @IBAction func stepperOctaveModifier(_ sender: UIStepper) {
        lblOctaveModifier.text = String(sender.value)
        
        octaveValue = sender.value
    }
 
    */
    
    //Initializes keys as sprite nodes
    var arraySprites :[SKSpriteNode] = [SKSpriteNode]()
    
    var key1 = SKSpriteNode(), key2 = SKSpriteNode(), key3 = SKSpriteNode(),
        key4 = SKSpriteNode(), key5 = SKSpriteNode(), key6 = SKSpriteNode(),
        key7 = SKSpriteNode(), key8 = SKSpriteNode(), key9 = SKSpriteNode(),
        key10 = SKSpriteNode()
    
    var arrKey :[SKSpriteNode] = [SKSpriteNode]()
    
    var oscillator: AKOscillator!
    
    var mixer = AKMixer()
    
    override func didMove(to view: SKView) {
        //Connects sprites from scene editor to code
        key1 = (self.childNode(withName: "key1") as? SKSpriteNode)!
        key2 = (self.childNode(withName: "key2") as? SKSpriteNode)!
        key3 = (self.childNode(withName: "key3") as? SKSpriteNode)!
        key4 = (self.childNode(withName: "key4") as? SKSpriteNode)!
        key5 = (self.childNode(withName: "key5") as? SKSpriteNode)!
        key6 = (self.childNode(withName: "key6") as? SKSpriteNode)!
        key7 = (self.childNode(withName: "key7") as? SKSpriteNode)!
        key8 = (self.childNode(withName: "key8") as? SKSpriteNode)!
        key9 = (self.childNode(withName: "key9") as? SKSpriteNode)!
        key10 = (self.childNode(withName: "key10") as? SKSpriteNode)!
        
        arrKey = [key1, key2, key3, key4, key5, key6, key7, key8, key9, key10]
        
        audioSetup()
        
        /*
        let vc = ViewController(nibName: "ViewController", bundle: nil)
        vc.GameScene = self
         */
 }
    /*
    func onUserAction(data: Int)
    {
        print("Data received: \(data)")
        testNumber = data
    }
    */
    /*
    //Initializes oscillator
    @IBOutlet var plot: AKNodeOutputPlot?
    
    var oscillator = AKOscillator(waveform: waveformValue) //Initializes oscillator and sets waveform
    var mixer = AKMixer()
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        mixer = AKMixer(oscillator)
        mixer.volume = 1
        AudioKit.output = mixer
        AKSettings.playbackWhileMuted = true //Allows AudioKit to play regardless of mute switch
        do {
            try AudioKit.start()
            oscillator.frequency = 0
            oscillator.amplitude = 1
            oscillator.rampDuration = 0.05
            oscillator.start()
        } catch {
            AKLog("AudioKit did not start!")
        }
    }
    */
    
    private func audioSetup() {
        oscillator = AKOscillator(waveform: waveformValue) //Initializes oscillator and sets waveform
        
        mixer = AKMixer(oscillator)
        mixer.volume = 1
        AudioKit.output = mixer
        AKSettings.playbackWhileMuted = true //Allows AudioKit to play regardless of mute switch
        do {
            try AudioKit.start()
            oscillator.frequency = 0
            oscillator.amplitude = 1
            oscillator.rampDuration = rampDuration
            oscillator.start()
        } catch {
            AKLog("AudioKit did not start!")
        }
    }
    
    //Booleans declared and initialized to represent if key is up or down
    //Extra element at index 0 so that array index starts at 1 and goes to 10 for readability and consistency
    var blnKey = [false, false, false, false, false, false, false, false, false, false, false] //change this to a loop
    
    var strHand = ""
    
    //Whenever any key is changed, this method is called to change the pitch accordingly
    func updateSound() {
        oscillator.frequency = finalPitch(saxNote: getSaxNote())
        
        //prints key presses to console for debugging
        for n in 1...10{
            print("key\(n): \(blnKey[n])")
        }
        
        //prints current hand to console for debugging
        print("hand: \(strHand)")
        
        //debug
        print(transpositionValue)
    }
    
    //Logic to determine note being played based on position of keys
    /*
     NEW
     C4 = 0
     C#/Db = 1
     D = 2
     D#/Eb = 3
     E = 4
     F = 5
     F#/Gb = 6
     G = 7
     G#/Ab = 8
     A = 9
     A#/Bb = 10
     B = 11
     C5 = 12
     C#/Db = 13
     */
    
    func getSaxNote() -> Int {
        //D
        if (blnKey[1] && !blnKey[2] && blnKey[3] && !blnKey[6] && !blnKey[7] && blnKey[8]) {
            return 26
        }
        //C#
        else if (!blnKey[1] && !blnKey[2] && blnKey[3] && !blnKey[6] && !blnKey[7] && blnKey[8]) {
            return 25
        }
        //High C (norm || side alt.)
        else if (!blnKey[1] && blnKey[2] && !blnKey[3] && !blnKey[6] && !blnKey[7] && blnKey[8]) || (blnKey[1] && !blnKey[2] && !blnKey[3] && !blnKey[6] && blnKey[7] && blnKey[8]){
            return 24
        }
        //B
        else if (blnKey[1] && !blnKey[2] && !blnKey[3] && !blnKey[6] && !blnKey[7] && blnKey[8]) {
            return 23
        }
        //A#/Bb (fake || bis)
        else if (blnKey[1] && blnKey[2] && !blnKey[3] && blnKey[6] && !blnKey[7] && blnKey[8]) || (blnKey[1] && !blnKey[2] && blnKey[6] && !blnKey[7] && blnKey[8]) {
            return 22
        }
        //A
        else if (blnKey[1] && blnKey[2] && !blnKey[3] && !blnKey[6] && !blnKey[7] && blnKey[8]) {
            return 21
        }
        //G#/Ab
        else if (blnKey[1] && blnKey[2] && blnKey[3] && blnKey[4] && !blnKey[6] && !blnKey[7] && blnKey[8]) {
            return 20
        }
        //G
        if (!blnKey[6] && !blnKey[7] && blnKey[8] && blnKey[1] && blnKey[2] && blnKey[3]) {
            return 19
        }
        //F#/Gb
        else if (!blnKey[1] && !blnKey[2] && blnKey[3] && !blnKey[6] && blnKey[7]) {
            return 18
        }
        //F
        else if (!blnKey[1] && !blnKey[2] && blnKey[3] && blnKey[6] && !blnKey[7]) {
            return 17
        }
        //E
        else if (!blnKey[1] && !blnKey[2] && blnKey[3] && blnKey[6] && blnKey[7] && !blnKey[8]) {
            return 16
        }
        //D#/Eb
        else if (!blnKey[1] && !blnKey[2] && blnKey[3] && blnKey[6] && blnKey[7] && blnKey[8] && blnKey[9]) {
            return 15
        }
        //D
        else if (!blnKey[1] && !blnKey[2] && blnKey[3] && blnKey[6] && blnKey[7] && blnKey[8]) {
            return 14
        }
        //C# (alternate)
        else if (!blnKey[1] && !blnKey[2] && blnKey[3] && !blnKey[6] && !blnKey[7] && !blnKey[8]) {
            return 13
        }
        //Mic C (normal || side alt.)
        else if (!blnKey[1] && blnKey[2]) || (blnKey[1] && !blnKey[2] && blnKey[7]) {
            return 12
        }
        //B
        else if (blnKey[1] && !blnKey[2] && !blnKey[6])
        {
            return 11
        }
        //A#/Bb (bis Bb || fake Bb)
        else if (blnKey[1] && !blnKey[2] && blnKey[6]) || (blnKey[1] && blnKey[2] && !blnKey[3] && blnKey[6]) {
            return 10
        }
        //A
        else if (blnKey[1] && blnKey[2] && !blnKey[3]) {
            return 9
        }
        //G#/Ab
        else if (blnKey[1] && blnKey[2] && blnKey[3] && (blnKey[4] || blnKey[5])) {
            return 8
        }
        //G
        else if (blnKey[1] && blnKey[2] && blnKey[3] && !(blnKey[4] || blnKey[5])) {
            return 7
        }
        //F#/Gb (normal || fake side alt.)]/
        else if (!blnKey[6] && blnKey[7]) || (blnKey[6] && !blnKey[7] && blnKey[8]) {
            return 6
        }
        //F
        else if (blnKey[6] && !blnKey[7]) {
            return 5
        }
        //E
        else if (blnKey[6] && blnKey[7] && !blnKey[8]) {
            return 4
        }
        //D#/Eb
        else if (blnKey[6] && blnKey[7] && blnKey[8] && blnKey[9]) {
            return 3
        }
        //D
        else if (blnKey[6] && blnKey[7] && blnKey[8] && !blnKey[9] && !blnKey[10]) {
            return 2
        }
        //C#/Db
        else if (blnKey[6] && blnKey[7] && blnKey[8] && blnKey[10] && (blnKey[5] || blnKey[4])) {
            return 1
        }
        //Low C
        else if (blnKey[6] && blnKey[7] && blnKey[8] && blnKey[10] && !blnKey[5]) {
            return 0
        }
        else {
            return -1
        }
    }
    
    //Takes inputted sax note, converts to numerical value (0-11, for notes A, A#/Bb, B, C.. G#/Ab), augments value to account for transposition, adjusts for octave, then finally converts note to pitch in hertz
    func finalPitch(saxNote: Int) -> Double {
        //let octave = 0 //implement later for user control
        var finalNote: Double
        var fundamentalPitch = 0.00
        
        if (transpositionValue == 0) {
            fundamentalPitch = 261.63
        }
        else if (transpositionValue == -2) {
            fundamentalPitch = 233.08
        }
        else if (transpositionValue == -9) {
            fundamentalPitch = 311.13
        }
        
        if (saxNote >= 0) { //Condense this into one statement!!!
            
            finalNote = fundamentalPitch * pow(pow(2, 1 / 12), Double(saxNote)) * Double(pow(2.0, octaveModifierValue))
            
            /*
             Formula for the frequencies of equal tempered notes: fn = f0 * (a)^n.
             
             Modified to account for transposition value and octave modifier value.
             
             https://pages.mtu.edu/~suits/NoteFreqCalcs.html
             https://pages.mtu.edu/~suits/notefreqs.html
             */
            
            print(finalNote) //for debugging purposes
            return finalNote
        }
        else {
            return 0.00
        }
    }
    
    //Creates array of touches
    private var activeTouches = [UITouch:String]()
    
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
        print("Begin press \(button)") //prints button press to console for debugging
        
        /*
        if (button == "SettingsButton") {
            let transition = SKTransition.flipHorizontal(withDuration: 0.5)
            let settingsScene = SettingsScene(size: self.size)
            self.view?.presentScene(settingsScene, transition: transition)
        }
        */
        
        for n in 0...9 {
            if (button == arrKey[n].name) {
                blnKey[n+1] = true
            
                if (n <= 4) {
                    strHand = "Left"
                }
                else {
                    strHand = "Right"
                }
                /*
                if (blnLeftHand) {
                    for n in 5...9 {
                        blnKey[n+1] = false
                    }
                }
                else {
                    for n in 0...4 {
                        blnKey[n+1] = false
                    }
                 
                }
                */
                
                //break?
            }
        }
        
        updateSound()
    }
    
    private func tapEnd(on button:String) {
        print("End press \(button)") //prints button unpress to console for debugging
        
        for n in 0...9 {
            if (button == arrKey[n].name) {
                blnKey[n+1] = false
            }
        }

        updateSound()
    }
    
    private func findButtonName(from touch: UITouch) -> String {
        let location = touch.location(in: self)
        
        for n in 0...9 {
            if (location.x > (arrKey[n].position.x - arrKey[n].size.width / 2) && location.x < (arrKey[n].position.x + arrKey[n].size.width / 2)) && location.y > (arrKey[n].position.y - arrKey[n].size.height / 2) && location.y < (arrKey[n].position.y + arrKey[n].size.height / 2) {
                return arrKey[n].name!
                
                //break?
            }
        }
        
        return "null_space"
    }
    

 
}
