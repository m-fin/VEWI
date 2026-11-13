//
//  FingeringChartViewController.swift
//  VEWI
//
//  Fingering chart: every note the app plays and the keys to hold for it.
//  Shows what each written note sounds like in the current key setting.
//

import UIKit

class FingeringChartViewController: UITableViewController {

    private let sections: [(title: String, rows: [Fingering])] = [
        ("Low register", FingeringChart.low),
        ("Upper register", FingeringChart.high)
    ]

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
        return sections.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sections[section].rows.count
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sections[section].title
    }

    override func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        if section == 0 {
            return "Keys are counted 1\u{2013}5 from the bottom of each column. C4\u{2013}F\u{266F}4 use the right column and G4\u{2013}C\u{266F}5 the left; lift the other hand."
        }
        return "Upper notes add the 3rd key of the other column as the octave key."
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let f = sections[indexPath.section].rows[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "fingering") ?? UITableViewCell(style: .subtitle, reuseIdentifier: "fingering")
        var title = NoteDisplay.name(f.note)
        let sound = NoteDisplay.sounding(written: f.note, transposition: settings.transposition, octaveShift: settings.octaveShift)
        if sound != f.note {
            title += "  (sounds \(NoteDisplay.name(sound)))"
        }
        if let label = f.label {
            title += "  \u{2013} \(label)"
        }
        cell.textLabel?.text = title
        cell.textLabel?.font = UIFont.boldSystemFont(ofSize: 17)
        cell.detailTextLabel?.text = FingeringChart.keyText(f.keys)
        cell.detailTextLabel?.font = UIFont.monospacedDigitSystemFont(ofSize: 15, weight: .regular)
        return cell
    }
}
