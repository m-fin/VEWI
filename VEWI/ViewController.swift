//
//  ViewController.swift
//  VEWI
//
//  The storyboard settings scene from the first versions of the app.
//  The playing screen opens SettingsViewController instead. This class stays
//  so the storyboard scene still loads, and it writes the same SaxSettings.
//

import UIKit

class ViewController: UITableViewController {
    @IBOutlet weak var segTransposition: UISegmentedControl!
    @IBOutlet weak var lblOctaveModifier: UILabel!
    @IBOutlet weak var stepperOctaveModifier: UIStepper!
    @IBOutlet weak var segWaveform: UISegmentedControl!
    @IBOutlet weak var sliderRampDuration: UISlider!
    @IBOutlet weak var lblRampDuration: UILabel!

    private var settings = SaxSettings.load()

    override func viewDidLoad() {
        super.viewDidLoad()
        settings = SaxSettings.load()
        segTransposition?.selectedSegmentIndex = settings.transposition.rawValue
        stepperOctaveModifier?.value = Double(settings.octaveShift)
        sliderRampDuration?.value = Float(settings.rampDuration)
        segWaveform?.selectedSegmentIndex = legacyWaveformIndex(settings.preset)
        showOctave()
        lblRampDuration?.text = String(format: "%.2f", settings.rampDuration)
    }

    @IBAction func segTranspositionValueChanged(_ sender: UISegmentedControl) {
        settings.transposition = Transposition(rawValue: sender.selectedSegmentIndex) ?? .eb
        persist()
    }

    @IBAction func stepperOctaveModifierValueChanged(_ sender: UIStepper) {
        settings.octaveShift = Int(sender.value)
        showOctave()
        persist()
    }

    @IBAction func segWaveformValueChanged(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 1: settings.preset = .saw
        case 2: settings.preset = .square
        case 3: settings.preset = .triangle
        default: settings.preset = .sine
        }
        persist()
    }

    @IBAction func sliderRampDurationValueChanged(_ sender: UISlider) {
        settings.rampDuration = Double(sender.value)
        lblRampDuration?.text = String(format: "%.2f", settings.rampDuration)
        persist()
    }

    @IBAction func btnResetToDefaults(_ sender: Any) {
        settings = SaxSettings()
        segTransposition?.selectedSegmentIndex = settings.transposition.rawValue
        stepperOctaveModifier?.value = 0
        sliderRampDuration?.value = Float(settings.rampDuration)
        segWaveform?.selectedSegmentIndex = 0
        showOctave()
        lblRampDuration?.text = String(format: "%.2f", settings.rampDuration)
        persist()
    }

    private func showOctave() {
        let octave = settings.octaveShift
        lblOctaveModifier?.text = octave > 0 ? "+\(octave)" : "\(octave)"
    }

    private func persist() {
        settings.save()
        NotificationCenter.default.post(name: SaxSettings.didChangeNotification, object: nil)
    }

    private func legacyWaveformIndex(_ preset: SoundPreset) -> Int {
        switch preset {
        case .saw: return 1
        case .square: return 2
        case .triangle: return 3
        case .sine, .warmReed, .brightLead, .subtone: return 0
        }
    }
}
