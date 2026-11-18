import SwiftUI
import WidgetKit

/// Lock Screen widget showing the selected counter's live total, rendered in a
/// neo-brutalist style. Reads from the shared App Group.
struct TallyLockScreenWidget: Widget {
    let kind = "TallyLockScreen"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: TallyLockScreenProvider()) { entry in
            TallyLockScreenView(entry: entry)
                .containerBackground(for: .widget) { Color(hex: entry.surface) }
        }
        .configurationDisplayName("Tally")
        .description("Live count on your Lock Screen.")
        .supportedFamilies([.accessoryCircular, .accessoryRectangular, .accessoryInline])
    }
}

struct TallyEntry: TimelineEntry {
    let date: Date
    let name: String
    let total: Int
    let stroke: Color
    let accent: Color
    let surface: Color
}

struct TallyLockScreenProvider: TimelineProvider {
    func placeholder(in context: Context) -> TallyEntry {
        TallyEntry(date: Date(), name: "Pushups", total: 42,
                   stroke: Color(hex: "#111111"), accent: Color(hex: "#FFC400"),
                   surface: Color(hex: "#FAF7F0"))
    }

    func getSnapshot(in context: Context, completion: @escaping (TallyEntry) -> Void) {
        completion(currentEntry())
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<TallyEntry>) -> Void) {
        let entry = currentEntry()
        // The app reloads timelines on every change; refresh hourly as a safety net.
        let next = Calendar.current.date(byAdding: .hour, value: 1, to: Date()) ?? Date()
        completion(Timeline(entries: [entry], policy: .after(next)))
    }

    private func currentEntry() -> TallyEntry {
        let defaults = UserDefaults(suiteName: TallySharedKeys.appGroup)
        let ids = (defaults?.string(forKey: TallySharedKeys.counterIds) ?? "")
            .split(separator: ",").map(String.init)
        let selected = defaults?.string(forKey: TallySharedKeys.notificationCounter) ?? ids.first
        guard let id = selected else {
            return TallyEntry(date: Date(), name: "No counter", total: 0,
                              stroke: Color(hex: "#111111"), accent: Color(hex: "#FFC400"),
                              surface: Color(hex: "#FAF7F0"))
        }
        let name = defaults?.string(forKey: TallySharedKeys.name(id)) ?? "Counter"
        let total = defaults?.integer(forKey: TallySharedKeys.total(id)) ?? 0
        let stroke = defaults?.integer(forKey: TallySharedKeys.stroke(id)) ?? 0x111111
        let accent = defaults?.integer(forKey: TallySharedKeys.accent(id)) ?? 0xFFC400
        return TallyEntry(date: Date(), name: name, total: total,
                          stroke: Color(rgb: stroke), accent: Color(rgb: accent),
                          surface: Color(hex: "#FAF7F0"))
    }
}

struct TallyLockScreenView: View {
    @Environment(\.widgetFamily) private var family
    let entry: TallyEntry

    var body: some View {
        switch family {
        case .accessoryCircular:
            ZStack {
                AccessoryWidgetBackground()
                TallyMarks(count: entry.total, color: entry.stroke)
                    .padding(6)
            }
        case .accessoryRectangular:
            VStack(alignment: .leading, spacing: 2) {
                Text(entry.name.uppercased())
                    .font(.system(size: 11, weight: .heavy, design: .monospaced))
                    .foregroundStyle(entry.stroke)
                HStack(spacing: 8) {
                    Text("\(entry.total)")
                        .font(.system(size: 26, weight: .heavy, design: .monospaced))
                    TallyMarks(count: entry.total, color: entry.stroke)
                        .frame(height: 20)
                }
            }
        default:
            Text("\(entry.name) \(entry.total)")
        }
    }
}

/// Compact 5-bar tally drawing.
struct TallyMarks: View {
    let count: Int
    let color: Color

    var body: some View {
        GeometryReader { geo in
            let marks = ((count % 5) + 5) % 5
            Canvas { context, size in
                let stroke = max(2, size.height * 0.12)
                let gap = size.width / 5
                for i in 0..<marks {
                    var path = Path()
                    let x = gap * CGFloat(i) + gap * 0.5
                    path.move(to: CGPoint(x: x, y: size.height * 0.85))
                    path.addLine(to: CGPoint(x: x, y: size.height * 0.15))
                    context.stroke(path, with: .color(color),
                                   style: StrokeStyle(lineWidth: stroke, lineCap: .round))
                }
                if marks == 5 {
                    var diag = Path()
                    diag.move(to: CGPoint(x: gap * 0.1, y: size.height * 0.85))
                    diag.addLine(to: CGPoint(x: gap * 4.9, y: size.height * 0.15))
                    context.stroke(diag, with: .color(color),
                                   style: StrokeStyle(lineWidth: stroke, lineCap: .round))
                }
            }
        }
    }
}

extension Color {
    init(rgb: Int) {
        self.init(
            red: Double((rgb >> 16) & 0xFF) / 255.0,
            green: Double((rgb >> 8) & 0xFF) / 255.0,
            blue: Double(rgb & 0xFF) / 255.0
        )
    }

    init(hex: String) {
        let cleaned = hex.hasPrefix("#") ? String(hex.dropFirst()) : hex
        let value = Int(cleaned, radix: 16) ?? 0x111111
        self.init(rgb: value)
    }
}
