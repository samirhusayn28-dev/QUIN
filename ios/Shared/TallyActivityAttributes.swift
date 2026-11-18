import ActivityKit
import Foundation

/// Shared between the Runner app and the TallyWidgetExtension target.
/// Add this file to **both** targets in Xcode.
@available(iOS 16.1, *)
public struct TallyActivityAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        public var total: Int
        public var updatedAt: Date

        public init(total: Int, updatedAt: Date = Date()) {
            self.total = total
            self.updatedAt = updatedAt
        }
    }

    public var counterId: String
    public var counterName: String
    public var strokeColor: String  // "#RRGGBB"
    public var accentColor: String  // "#RRGGBB"

    public init(counterId: String, counterName: String, strokeColor: String, accentColor: String) {
        self.counterId = counterId
        self.counterName = counterName
        self.strokeColor = strokeColor
        self.accentColor = accentColor
    }
}

/// Keys used in the shared App Group UserDefaults (mirrors `WidgetKeys` in Dart).
public enum TallySharedKeys {
    public static let appGroup = "group.com.tallycounter.tallyCounter"
    public static let counterIds = "tally_counter_ids"
    public static let notificationCounter = "tally_notification_counter"

    public static func name(_ id: String) -> String { "tally_counter_\(id)_name" }
    public static func total(_ id: String) -> String { "tally_counter_\(id)_total" }
    public static func style(_ id: String) -> String { "tally_counter_\(id)_style" }
    public static func stroke(_ id: String) -> String { "tally_counter_\(id)_stroke" }
    public static func accent(_ id: String) -> String { "tally_counter_\(id)_accent" }
}
