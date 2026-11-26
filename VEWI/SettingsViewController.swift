//
//  SettingsViewController.swift
//  VEWI
//
//  Key, sound, breath, and what the playing screen shows. Saved immediately.
//

import UIKit

class SettingsViewController: UITableViewController {
    private var settings = SaxSettings.load()

    private let transpositionControl = UISegmentedControl(items: Transposition.allCases.map { $0.title })
    private let octaveStepper = UIStepper()
    private let volumeSlider = UISlider()
    private let rampSlider = UISlider()
    private let vibratoSwitch = UISwitch()
    private let chartSwitch = UISwitch()
    private let noteNameSwitch = UISwitch()
    private let hintSwitch = UISwitch()

    private enum Row: Hashable {
        case transposition, octave
        case preset(SoundPreset), volume, ramp, vibrato
        case breath(BreathMode)
        case noteName, hint, chart
        case reset
    }

    private struct Section {
        let title: String?
        let footer: String?
        let rows: [Row]
    }

    private var sections: [Section] {
        return [
            Section(title: "Pitch",
                    footer: "E♭ is alto: written A sounds concert C. B♭ is tenor or soprano. Concert plays the written pitch. The octave shift moves that sounding pitch.",
                    rows: [.transposition, .octave]),
            Section(title: "Sound",
                    footer: "Glide is how long the pitch takes to slide from one note to the next. Vibrato comes in a little after the note speaks.",
                    rows: SoundPreset.allCases.map { Row.preset($0) } + [.volume, .ramp, .vibrato]),
            Section(title: "Breath",
                    footer: settings.breathMode.detail + " Open C♯ is every key up, so the note stops when the breath stops.",
                    rows: BreathMode.allCases.map { Row.breath($0) }),
            Section(title: "Practice",
                    footer: "Hint draws the fingering on the playing screen. Chart adds a button that opens this chart while you play.",
                    rows: [.noteName, .hint, .chart]),
            Section(title: nil, footer: nil, rows: [.reset])
        ]
    }

    private var cells: [Row: UITableViewCell] = [:]

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Settings"

        transpositionControl.addTarget(self, action: #selector(transpositionChanged(_:)), for: .valueChanged)
        transpositionControl.frame = CGRect(x: 0, y: 0, width: 200, height: 32)

        octaveStepper.minimumValue = Double(SaxSettings.octaveRange.lowerBound)
        octaveStepper.maximumValue = Double(SaxSettings.octaveRange.upperBound)
        octaveStepper.stepValue = 1
        octaveStepper.addTarget(self, action: #selector(octaveChanged(_:)), for: .valueChanged)

        volumeSlider.minimumValue = 0
        volumeSlider.maximumValue = 1
        volumeSlider.frame = CGRect(x: 0, y: 0, width: 150, height: 31)
        volumeSlider.addTarget(self, action: #selector(volumeChanged(_:)), for: .valueChanged)

        rampSlider.minimumValue = 0
        rampSlider.maximumValue = 1
        rampSlider.frame = CGRect(x: 0, y: 0, width: 150, height: 31)
        rampSlider.addTarget(self, action: #selector(rampChanged(_:)), for: .valueChanged)

        vibratoSwitch.addTarget(self, action: #selector(vibratoChanged(_:)), for: .valueChanged)
        chartSwitch.addTarget(self, action: #selector(chartChanged(_:)), for: .valueChanged)
        noteNameSwitch.addTarget(self, action: #selector(noteNameChanged(_:)), for: .valueChanged)
        hintSwitch.addTarget(self, action: #selector(hintChanged(_:)), for: .valueChanged)

        buildCells()
        syncControls()
    }

    private func buildCells() {
        func cell(_ text: String, accessory: UIView?) -> UITableViewCell {
            let row = UITableViewCell(style: .value1, reuseIdentifier: nil)
            row.textLabel?.text = text
            row.selectionStyle = .none
            row.accessoryView = accessory
            return row
        }
        cells[.transposition] = cell("Key", accessory: transpositionControl)
        cells[.octave] = cell("Octave shift", accessory: octaveStepper)
        cells[.volume] = cell("Volume", accessory: volumeSlider)
        cells[.ramp] = cell("Glide", accessory: rampSlider)
        cells[.vibrato] = cell("Vibrato", accessory: vibratoSwitch)
        cells[.noteName] = cell("Note name", accessory: noteNameSwitch)
        cells[.hint] = cell("Fingering hint", accessory: hintSwitch)
        cells[.chart] = cell("Chart button", accessory: chartSwitch)
        for preset in SoundPreset.allCases {
            let row = UITableViewCell(style: .subtitle, reuseIdentifier: nil)
            row.textLabel?.text = preset.title
            row.detailTextLabel?.text = preset.detail
            cells[.preset(preset)] = row
        }
        for mode in BreathMode.allCases {
            let row = UITableViewCell(style: .default, reuseIdentifier: nil)
            row.textLabel?.text = mode.title
            cells[.breath(mode)] = row
        }
        let reset = UITableViewCell(style: .default, reuseIdentifier: nil)
        reset.textLabel?.text = "Reset to Defaults"
        reset.textLabel?.textAlignment = .center
        reset.textLabel?.textColor = .systemRed
        cells[.reset] = reset
    }

    private func syncControls() {
        transpositionControl.selectedSegmentIndex = settings.transposition.rawValue
        octaveStepper.value = Double(settings.octaveShift)
        volumeSlider.value = Float(settings.volume)
        rampSlider.value = Float(settings.rampDuration)
        vibratoSwitch.isOn = settings.vibrato
        chartSwitch.isOn = settings.showFingeringChart
        noteNameSwitch.isOn = settings.showNoteName
        hintSwitch.isOn = settings.showFingeringHint
        updateValueLabels()
        tableView.reloadData()
    }

    private func updateValueLabels() {
        let octave = settings.octaveShift
        cells[.octave]?.detailTextLabel?.text = octave > 0 ? "+\(octave)" : "\(octave)"
        cells[.volume]?.detailTextLabel?.text = "\(Int((settings.volume * 100).rounded()))%"
        cells[.ramp]?.detailTextLabel?.text = String(format: "%.2f s", settings.rampDuration)
    }

    private func persist() {
        settings.save()
        NotificationCenter.default.post(name: SaxSettings.didChangeNotification, object: nil)
    }

    @objc private func transpositionChanged(_ sender: UISegmentedControl) {
        settings.transposition = Transposition(rawValue: sender.selectedSegmentIndex) ?? .eb
        persist()
    }

    @objc private func octaveChanged(_ sender: UIStepper) {
        settings.octaveShift = Int(sender.value)
        updateValueLabels()
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

    @objc private func vibratoChanged(_ sender: UISwitch) {
        settings.vibrato = sender.isOn
        persist()
    }

    @objc private func chartChanged(_ sender: UISwitch) {
        settings.showFingeringChart = sender.isOn
        persist()
    }

    @objc private func noteNameChanged(_ sender: UISwitch) {
        settings.showNoteName = sender.isOn
        persist()
    }

    @objc private func hintChanged(_ sender: UISwitch) {
        settings.showFingeringHint = sender.isOn
        persist()
    }

    override func numberOfSections(in tableView: UITableView) -> Int { return sections.count }

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
        let cell = cells[row] ?? UITableViewCell()
        switch row {
        case .preset(let preset):
            cell.accessoryType = settings.preset == preset ? .checkmark : .none
        case .breath(let mode):
            cell.accessoryType = settings.breathMode == mode ? .checkmark : .none
        default:
            break
        }
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        switch sections[indexPath.section].rows[indexPath.row] {
        case .preset(let preset):
            settings.preset = preset
            persist()
            tableView.reloadData()
        case .breath(let mode):
            settings.breathMode = mode
            persist()
            tableView.reloadData()
        case .reset:
            settings = SaxSettings()
            syncControls()
            persist()
        default:
            break
        }
    }
}
