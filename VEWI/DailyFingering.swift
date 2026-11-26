//
//  DailyFingering.swift
//  VEWI
//
//  Shared by the app and the widget. The day is counted in UTC so both
//  processes show the same fingering without an App Group.
//

import Foundation

enum DailyFingering {
    static func utcCalendar() -> Calendar {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(secondsFromGMT: 0) ?? TimeZone(identifier: "UTC")!
        return calendar
    }

    static func fingering(on date: Date, from chart: [Fingering] = FingeringChart.daily) -> Fingering {
        precondition(!chart.isEmpty, "daily fingering chart is empty")
        let calendar = utcCalendar()
        let epoch = calendar.date(from: DateComponents(year: 2020, month: 1, day: 1)) ?? date
        let day = calendar.dateComponents([.day], from: epoch, to: calendar.startOfDay(for: date)).day ?? 0
        let count = chart.count
        let index = ((day % count) + count) % count
        return chart[index]
    }
}

/// Last note the player sounded, for a widget that can read the App Group.
/// Without the group entitlement this stays inside the app and the widget
/// falls back to the fingering of the day.
enum SharedPractice {
    static let appGroup = "group.com.matthewfinley.VEWI"
    static let lastNoteKey = "Last_Written_Note"

    static var store: UserDefaults {
        return UserDefaults(suiteName: appGroup) ?? .standard
    }

    static func saveLastWrittenNote(_ note: Int?) {
        let defaults = UserDefaults(suiteName: appGroup)
        guard let defaults else { return }
        if let note {
            defaults.set(note, forKey: lastNoteKey)
        } else {
            defaults.removeObject(forKey: lastNoteKey)
        }
    }

    static func lastWrittenNote() -> Int? {
        guard let defaults = UserDefaults(suiteName: appGroup) else { return nil }
        guard defaults.object(forKey: lastNoteKey) != nil else { return nil }
        return defaults.integer(forKey: lastNoteKey)
    }
}
