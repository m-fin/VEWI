//
//  FingeringChartViewController.swift
//  VEWI
//
//  Real alto saxophone fingerings from written B♭3 to F♯6, including alternates.
//  The sounding pitch follows the key chosen in Settings.
//

import UIKit

class FingeringChartViewController: UITableViewController {
    private var settings = SaxSettings.load()

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Fingering Chart"
        tableView.allowsSelection = false
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        settings = SaxSettings.load()
        tableView.reloadData()
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return FingeringChart.sections.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return FingeringChart.sections[section].rows.count
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return FingeringChart.sections[section].title
    }

    override func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        switch section {
        case 0:
            return "Bis B♭ is the main B♭. 1+1 is L1 with R1, and side B♭ is the Ta key. Fork F♯ is R2; the F♯ key is the chromatic one. G♯ lets go as soon as the right hand closes a lower note, so you can leave the pinky down."
        case 1:
            return "The octave key is the left thumb. It does not move the bell notes (B♭3–C♯4). Open C♯6 is the octave key alone."
        default:
            return "Palm keys are the left-hand palm. Front E (Tf) is the alternate E6. Half-palm F is palm D and E♭ over an F fingering. Blow to sound a note — open C♯ is no keys at all."
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let fingering = FingeringChart.sections[indexPath.section].rows[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "fingering") ?? UITableViewCell(style: .subtitle, reuseIdentifier: "fingering")
        var title = NoteDisplay.name(fingering.note)
        let sound = NoteDisplay.sounding(written: fingering.note, transposition: settings.transposition, octaveShift: settings.octaveShift)
        if sound != fingering.note {
            title += "  (sounds \(NoteDisplay.name(sound)))"
        }
        if let label = fingering.label {
            title += "  \u{2013} \(label)"
        }
        cell.textLabel?.text = title
        cell.textLabel?.font = .boldSystemFont(ofSize: 17)
        cell.detailTextLabel?.text = FingeringChart.keyText(fingering.keys)
        cell.detailTextLabel?.font = .monospacedDigitSystemFont(ofSize: 14, weight: .regular)
        cell.detailTextLabel?.numberOfLines = 0
        return cell
    }
}
