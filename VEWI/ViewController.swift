//
//  ViewController.swift
//  VirtualSax-Beta1
//
//  Created by Matthew Finley on 6/8/19.
//  Copyright © 2019 Matthew Finley. All rights reserved.
//

import UIKit

import AudioKit
import AudioKitUI

//Global variables
var transpositionValue = 0
var octaveModifierValue = 0.0
var waveformValue: AKTable = sine
var rampDuration = 0.05

class ViewController: UITableViewController {
    
    var GameScene:GameScene?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        /*
        UserDefaults.standard.set(25, forKey: "Transposition_Value")
        transpositionValue = UserDefaults.standard.integer(forKey: "Transposition_Value")
        */
        
        segTransposition.selectedSegmentIndex = UserDefaults.standard.integer(forKey: "Transposition_Value_Index")
        
        stepperOctaveModifier.value = UserDefaults.standard.double(forKey: "Octave_Value")
        
        lblOctaveModifier.text = String(Int(stepperOctaveModifier.value))
        
        segWaveform.selectedSegmentIndex = UserDefaults.standard.integer(forKey: "Waveform_Value_Index")
        
        sliderRampDuration.value = Float(rampDuration)
        
        lblRampDuration.text = String(format: "%.2f", rampDuration)
 }
    
    @IBOutlet weak var segTransposition: UISegmentedControl!
    
    @IBAction func segTranspositionValueChanged(_ sender: UISegmentedControl) {
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
        
        UserDefaults.standard.set(segTransposition.selectedSegmentIndex, forKey: "Transposition_Value_Index")
        
        print(transpositionValue)
    }
    
    @IBOutlet weak var lblOctaveModifier: UILabel!
    
    @IBOutlet weak var stepperOctaveModifier: UIStepper!
    
    @IBAction func stepperOctaveModifierValueChanged(_ sender: UIStepper) {
        //set var to value
        octaveModifierValue = Double(stepperOctaveModifier.value)
        
        //set lbl to var (if > 0, display as "+n"
        if (octaveModifierValue > 0) {
            var octaveModifierValueString = String(Int(octaveModifierValue))
            lblOctaveModifier.text = "+\(octaveModifierValueString)"
        }
        else {
            lblOctaveModifier.text = String(Int(octaveModifierValue))
        }
        
        //set user default
        UserDefaults.standard.set(stepperOctaveModifier.value, forKey: "Octave_Value") //set user default to value
        
        //debugging
        print("octaveModifierValue: \(octaveModifierValue)")

    }
    
    @IBOutlet weak var segWaveform: UISegmentedControl!
    
    @IBAction func segWaveformValueChanged(_ sender: UISegmentedControl) {
        //Sine
        if (segWaveform.selectedSegmentIndex == 0) {
            waveformValue = sine
            print(0)
        }
        //Sawtooth
        else if (segWaveform.selectedSegmentIndex == 1) {
            waveformValue = sawtooth
            print(1)
        }
        //Square
        else if (segWaveform.selectedSegmentIndex == 2) {
            waveformValue = square
        }
        //Triangle
        else if (segWaveform.selectedSegmentIndex == 3) {
            waveformValue = triangle
        }
        else {
            waveformValue = sine
        }
        UserDefaults.standard.set(segWaveform.selectedSegmentIndex, forKey: "Waveform_Value_Index")
        
        print(waveformValue)
    }
    
    @IBOutlet weak var sliderRampDuration: UISlider!
    
    @IBOutlet weak var lblRampDuration: UILabel!
    
    @IBAction func sliderRampDurationValueChanged(_ sender: UISlider) {
        rampDuration = Double(sliderRampDuration.value)
        
        lblRampDuration.text = String(format: "%.2f", rampDuration)
    }
    
    @IBAction func btnResetToDefaults(_ sender: Any) {
        resetSettingsToDefault()
    }
    
    func resetSettingsToDefault() {
        transpositionValue = 0
        UserDefaults.standard.set(transpositionValue, forKey: "Transposition_Value_Index")
        segTransposition.selectedSegmentIndex = 0
        
        octaveModifierValue = 0
        UserDefaults.standard.set(octaveModifierValue, forKey: "Octave_Value")
        var octaveModifierValueString = String(Int(octaveModifierValue))
        lblOctaveModifier.text = "+\(octaveModifierValueString)"
    }

}
