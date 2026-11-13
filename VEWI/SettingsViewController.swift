//
//  SettingsViewController.swift
//  VEWI
//
//  Settings screen built in code: transposition, octave shift, waveform,
//  volume, glide, and the fingering chart toggle. Every change is saved
//  right away and the playing screen picks it up.
//  Create with SettingsViewController(style: .grouped).
//

import UIKit

class SettingsViewController: UITableViewController {

    private var settings = SaxSettings.load()

    private let transpositionControl = UISegmentedControl(items: Transposition.allCases.map { $0.title })
    private let octaveStepper = UIStepper()
    private let waveformControl = UISegmentedControl(items: Waveform.allCases.map { $0.title })
    private let volumeSlider = UISlider()
    private let rampSlider = UISlider()
    private let chartSwitch = UISwitch()

    private enum Row {
        case transposition, octave, waveform, volume, ramp, chart, reset
    }

    private struct Section {
        let title: String?
        let footer: String?
        let rows: [Row]
    }

    private let sections: [Section] = [
        Section(title: "Pitch",
                footer: "Concert plays the written note. B\u{266D} sounds like a tenor or soprano sax, E\u{266D} like an alto.",
                rows: [.transposition, .octave]),
        Section(title: "Sound",
                footer: "Glide is how long the pitch takes to slide from one note to the next.",
                rows: [.waveform, .volume, .ramp]),
        Section(title: "Practice",
                footer: "Adds a Chart button to the playing screen.",
                rows: [.chart]),
        Section(title: nil, footer: nil, rows: [.reset])
    ]

    private var cells = [Row: UITableViewCell]()

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Settings"

        transpositionControl.addTarget(self, action: #selector(transpositionChanged(_:)), for: .valueChanged)

        octaveStepper.minimumValue = Double(SaxSettings.octaveRange.lowerBound)
        octaveStepper.maximumValue = Double(SaxSettings.octaveRange.upperBound)
        octaveStepper.stepValue = 1
        octaveStepper.addTarget(self, action: #selector(octaveChanged(_:)), for: .valueChanged)

        waveformControl.addTarget(self, action: #selector(waveformChanged(_:)), for: .valueChanged)

        volumeSlider.minimumValue = 0
        volumeSlider.maximumValue = 1
        volumeSlider.frame = CGRect(x: 0, y: 0, width: 160, height: 31)
        volumeSlider.addTarget(self, action: #selector(volumeChanged(_:)), for: .valueChanged)

        rampSlider.minimumValue = 0
        rampSlider.maximumValue = 1
        rampSlider.frame = CGRect(x: 0, y: 0, width: 160, height: 31)
        rampSlider.addTarget(self, action: #selector(rampChanged(_:)), for: .valueChanged)

        chartSwitch.addTarget(self, action: #selector(chartChanged(_:)), for: .valueChanged)

        buildCells()
        syncControls()
    }

    // MARK: - Cells

    private func buildCells() {
        func cell(_ text: String, accessory: UIView?) -> UITableViewCell {
            let c = UITableViewCell(style: .value1, reuseIdentifier: nil)
            c.textLabel?.text = text
            c.selectionStyle = .none
            if let a = accessory, a.frame.width == 0 { a.sizeToFit() } //sliders keep the width set above
            c.accessoryView = accessory
            return c
        }
        cells[.transposition] = cell("Key", accessory: transpositionControl)
        cells[.octave] = cell("Octave shift", accessory: octaveStepper)
        cells[.waveform] = cell("Wave", accessory: waveformControl)
        cells[.volume] = cell("Volume", accessory: volumeSlider)
        cells[.ramp] = cell("Glide", accessory: rampSlider)
        cells[.chart] = cell("Fingering chart", accessory: chartSwitch)

        let reset = UITableViewCell(style: .default, reuseIdentifier: nil)
        reset.textLabel?.text = "Reset to Defaults"
        reset.textLabel?.textAlignment = .center
        reset.textLabel?.textColor = .red
        cells[.reset] = reset
    }

    //Puts the current settings into the controls and the value labels
    private func syncControls() {
        transpositionControl.selectedSegmentIndex = settings.transposition.rawValue
        octaveStepper.value = Double(settings.octaveShift)
        waveformControl.selectedSegmentIndex = settings.waveform.rawValue
        volumeSlider.value = Float(settings.volume)
        rampSlider.value = Float(settings.rampDuration)
        chartSwitch.isOn = settings.showFingeringChart
        updateValueLabels()
    }

    private func updateValueLabels() {
        let o = settings.octaveShift
        cells[.octave]?.detailTextLabel?.text = o > 0 ? "+\(o)" : "\(o)"
        cells[.volume]?.detailTextLabel?.text = "\(Int((settings.volume * 100).rounded()))%"
        cells[.ramp]?.detailTextLabel?.text = String(format: "%.2f s", settings.rampDuration)
    }

    //Saves, applies to the globals the instrument plays with, and tells the playing screen
    private func persist() {
        settings.save()
        loadSavedSettings()
        NotificationCenter.default.post(name: SaxSettings.didChangeNotification, object: nil)
    }

    // MARK: - Actions

    @objc private func transpositionChanged(_ sender: UISegmentedControl) {
        settings.transposition = Transposition(rawValue: sender.selectedSegmentIndex) ?? .concert
        persist()
    }

    @objc private func octaveChanged(_ sender: UIStepper) {
        settings.octaveShift = Int(sender.value)
        updateValueLabels()
        persist()
    }

    @objc private func waveformChanged(_ sender: UISegmentedControl) {
        settings.waveform = Waveform(rawValue: sender.selectedSegmentIndex) ?? .sine
        persist()
    }

    @objc private func volumeChanged(_ sender: UISlider) {
        settings.volume = Double(sender.value)
        updateValueLabels()
        persist()
    }

    @objc private func rampChanged(_ sender: UISlider) {
        settings.rampDuration = Double(sender.value)
        updateValueLabels()
        persist()
    }

    @objc private func chartChanged(_ sender: UISwitch) {
        settings.showFingeringChart = sender.isOn
        persist()
    }

    // MARK: - Table

    override func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sections[section].rows.count
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sections[section].title
    }

    override func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        return sections[section].footer
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let row = sections[indexPath.section].rows[indexPath.row]
        return cells[row] ?? UITableViewCell()
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        guard sections[indexPath.section].rows[indexPath.row] == .reset else { return }
        settings = SaxSettings()
        syncControls()
        persist()
    }
}
