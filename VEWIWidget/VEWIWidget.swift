//
//  VEWIWidget.swift
//  VEWIWidget
//
//  Home Screen and Lock Screen fingering of the day, and a tap that opens VEWI.
//

import WidgetKit
import SwiftUI

struct DailyEntry: TimelineEntry {
    let date: Date
    let fingering: Fingering
}

struct Provider: TimelineProvider {
    func placeholder(in context: Context) -> DailyEntry {
        return DailyEntry(date: Date(), fingering: Provider.sample)
    }

    func getSnapshot(in context: Context, completion: @escaping (DailyEntry) -> Void) {
        completion(DailyEntry(date: Date(), fingering: DailyFingering.fingering(on: Date())))
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<DailyEntry>) -> Void) {
        let now = Date()
        let entry = DailyEntry(date: now, fingering: DailyFingering.fingering(on: now))
        let next = Calendar.current.date(byAdding: .hour, value: 1, to: now) ?? now.addingTimeInterval(3600)
        completion(Timeline(entries: [entry], policy: .after(next)))
    }

    private static var sample: Fingering {
        return FingeringChart.daily.first { $0.note == 2 } ?? FingeringChart.daily[0]
    }
}

struct FingeringWidgetView: View {
    var entry: DailyEntry
    @Environment(\.widgetFamily) private var family

    private var note: String { NoteDisplay.name(entry.fingering.note) }
    private var keys: String { FingeringChart.keyText(entry.fingering.keys) }

    var body: some View {
        content
            .widgetURL(URL(string: "vewi://play"))
            .vewiWidgetBackground()
    }

    @ViewBuilder private var content: some View {
        switch family {
        case .accessoryInline:
            Text("\(note)  \(keys)")
        case .accessoryCircular:
            Text(note)
                .font(.headline)
        case .accessoryRectangular:
            VStack(alignment: .leading, spacing: 2) {
                Text(note).font(.headline)
                Text(keys).font(.caption2).lineLimit(2)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        case .systemMedium:
            HStack(alignment: .center, spacing: 16) {
                Text(note)
                    .font(.system(size: 42, weight: .bold))
                    .minimumScaleFactor(0.5)
                    .lineLimit(1)
                VStack(alignment: .leading, spacing: 4) {
                    Text("Fingering of the Day")
                        .font(.headline)
                    Text(keys)
                        .font(.system(.body, design: .monospaced))
                        .lineLimit(3)
                    Text("Alto sax · tap to play")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                Spacer(minLength: 0)
            }
            .padding(4)
        default:
            VStack(alignment: .leading, spacing: 6) {
                Text("Alto sax")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Text(note)
                    .font(.system(size: 36, weight: .bold))
                    .minimumScaleFactor(0.5)
                    .lineLimit(1)
                Text(keys)
                    .font(.system(.caption, design: .monospaced))
                    .lineLimit(3)
                Spacer(minLength: 0)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
            .padding(4)
        }
    }
}

@main
struct VEWIWidget: Widget {
    let kind = "com.matthewfinley.VEWI.fingeringOfTheDay"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            FingeringWidgetView(entry: entry)
        }
        .configurationDisplayName("Fingering of the Day")
        .description("A real alto saxophone fingering. Tap to open VEWI.")
        .supportedFamilies([.systemSmall, .systemMedium, .accessoryInline, .accessoryCircular, .accessoryRectangular])
    }
}

private extension View {
    @ViewBuilder func vewiWidgetBackground() -> some View {
        if #available(iOS 17.0, *) {
            containerBackground(for: .widget) {
                Color(red: 0.07, green: 0.08, blue: 0.11)
            }
        } else {
            background(Color(red: 0.07, green: 0.08, blue: 0.11))
        }
    }
}
