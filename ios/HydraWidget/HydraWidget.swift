// WidgetKit source for the HYDRA home-screen widget.
//
// NOT part of the Xcode project yet: adding a Widget Extension target needs
// Xcode (File ▸ New ▸ Target ▸ Widget Extension, "HydraWidget"), then add this
// file to it, enable the App Group `group.com.hydra.hydra` on both Runner and
// the extension, and add the group to Runner.entitlements. See docs/RELEASE.md.
//
// The app publishes `percent`, `progress`, `next`, `symbol` via home_widget
// (UserDefaults in the App Group). Only a percentage and short labels are
// shared with the widget host.
import SwiftUI
import WidgetKit

struct HydraEntry: TimelineEntry {
    let date: Date
    let percent: Int
    let progress: String
    let next: String
    let symbol: String
}

struct HydraProvider: TimelineProvider {
    private let defaults = UserDefaults(suiteName: "group.com.hydra.hydra")

    private func current() -> HydraEntry {
        HydraEntry(
            date: Date(),
            percent: defaults?.integer(forKey: "percent") ?? 0,
            progress: defaults?.string(forKey: "progress") ?? "",
            next: defaults?.string(forKey: "next") ?? "",
            symbol: defaults?.string(forKey: "symbol") ?? ""
        )
    }

    func placeholder(in context: Context) -> HydraEntry {
        HydraEntry(date: Date(), percent: 42, progress: "", next: "", symbol: "✓")
    }

    func getSnapshot(in context: Context, completion: @escaping (HydraEntry) -> Void) {
        completion(current())
    }

    // Reload every 30 minutes so "next reminder" never goes stale; the app also
    // reloads the timeline on every change.
    func getTimeline(in context: Context, completion: @escaping (Timeline<HydraEntry>) -> Void) {
        let refresh = Calendar.current.date(byAdding: .minute, value: 30, to: Date()) ?? Date()
        completion(Timeline(entries: [current()], policy: .after(refresh)))
    }
}

struct HydraWidgetView: View {
    let entry: HydraEntry

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack(alignment: .firstTextBaseline) {
                Text("\(entry.percent)%").font(.system(size: 32, weight: .bold, design: .rounded))
                Text(entry.symbol).foregroundStyle(.secondary)
            }
            if !entry.progress.isEmpty {
                Text(entry.progress).font(.footnote).foregroundStyle(.secondary)
            }
            if !entry.next.isEmpty {
                Text("Next · \(entry.next)").font(.caption).foregroundStyle(.secondary)
            }
            Spacer()
            ProgressView(value: Double(min(entry.percent, 100)), total: 100)
        }
        .padding()
        .accessibilityElement(children: .combine)
    }
}

@main
struct HydraWidget: Widget {
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: "HydraWidget", provider: HydraProvider()) { entry in
            if #available(iOS 17.0, *) {
                HydraWidgetView(entry: entry).containerBackground(.fill.tertiary, for: .widget)
            } else {
                HydraWidgetView(entry: entry)
            }
        }
        .configurationDisplayName("HYDRA")
        .description("Progress and your next check-in.")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}
