import ActivityKit
import SwiftUI
import WidgetKit

/// Live Activity UI — shown on the Lock Screen and in the Dynamic Island for a
/// counter with the "Live count on lock screen" setting enabled.
@available(iOS 16.1, *)
struct TallyLiveActivityWidget: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: TallyActivityAttributes.self) { context in
            // Lock Screen / banner presentation.
            HStack(spacing: 14) {
                VStack(alignment: .leading, spacing: 2) {
                    Text(context.attributes.counterName.uppercased())
                        .font(.system(size: 12, weight: .heavy, design: .monospaced))
                        .foregroundStyle(Color(hex: context.attributes.strokeColor))
                    Text("\(context.state.total)")
                        .font(.system(size: 34, weight: .heavy, design: .monospaced))
                        .foregroundStyle(Color(hex: context.attributes.strokeColor))
                }
                Spacer()
                TallyMarks(count: context.state.total,
                           color: Color(hex: context.attributes.strokeColor))
                    .frame(width: 90, height: 32)
            }
            .padding()
            .activityBackgroundTint(Color(hex: "#FAF7F0"))
            .activitySystemActionForegroundColor(Color(hex: "#111111"))
        } dynamicIsland: { context in
            DynamicIsland {
                DynamicIslandExpandedRegion(.leading) {
                    Text("\(context.state.total)")
                        .font(.system(size: 28, weight: .heavy, design: .monospaced))
                }
                DynamicIslandExpandedRegion(.trailing) {
                    TallyMarks(count: context.state.total,
                               color: Color(hex: context.attributes.strokeColor))
                        .frame(width: 70, height: 24)
                }
                DynamicIslandExpandedRegion(.bottom) {
                    Text(context.attributes.counterName)
                        .font(.system(size: 12, weight: .semibold, design: .monospaced))
                }
            } compactLeading: {
                Text("\(context.state.total)")
                    .font(.system(size: 14, weight: .heavy, design: .monospaced))
            } compactTrailing: {
                Image(systemName: "plus.circle.fill")
                    .foregroundStyle(Color(hex: context.attributes.accentColor))
            } minimal: {
                Text("\(context.state.total)")
                    .font(.system(size: 14, weight: .heavy, design: .monospaced))
            }
        }
    }
}
