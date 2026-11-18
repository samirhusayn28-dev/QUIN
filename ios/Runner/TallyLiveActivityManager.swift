import ActivityKit
import Flutter
import Foundation
import UIKit

/// Bridges Dart (`tally_counter/live_activity`) to ActivityKit.
///
/// Keeps one Live Activity per counter id so the lock screen shows the live
/// value. No-op on iOS < 16.1 or when Live Activities are unavailable.
@available(iOS 16.1, *)
final class TallyLiveActivityManager {
    static let shared = TallyLiveActivityManager()

    private var activities: [String: Activity<TallyActivityAttributes>] = [:]

    func register(with messenger: FlutterBinaryMessenger) {
        let channel = FlutterMethodChannel(
            name: "tally_counter/live_activity",
            binaryMessenger: messenger,
        )
        channel.setMethodCallHandler { [weak self] call, result in
            guard let self else {
                result(FlutterError(code: "unavailable", message: nil, details: nil))
                return
            }
            let args = call.arguments as? [String: Any] ?? [:]
            switch call.method {
            case "start":
                self.start(from: args)
                result(nil)
            case "update":
                self.update(from: args)
                result(nil)
            case "end":
                if let id = args["counterId"] as? String { self.end(counterId: id) }
                result(nil)
            default:
                result(FlutterMethodNotImplemented)
            }
        }
    }

    private func start(from args: [String: Any]) {
        guard ActivityAuthorizationInfo().areActivitiesEnabled else { return }
        let counterId = args["counterId"] as? String ?? ""
        let name = args["name"] as? String ?? "Counter"
        let total = args["total"] as? Int ?? 0
        let stroke = hex(args["strokeColor"] as? Int ?? 0x111111)
        let accent = hex(args["accentColor"] as? Int ?? 0xFFC400)

        // Reuse an existing activity if present.
        if let existing = activities[counterId] {
            Task { await existing.update(ActivityContent(
                state: .init(total: total),
                staleDate: nil,
            )) }
            return
        }

        do {
            let attributes = TallyActivityAttributes(
                counterId: counterId,
                counterName: name,
                strokeColor: stroke,
                accentColor: accent,
            )
            let activity = try Activity<TallyActivityAttributes>.request(
                attributes: attributes,
                content: ActivityContent(state: .init(total: total), staleDate: nil),
                pushType: nil,
            )
            activities[counterId] = activity
        } catch {
            // Live Activities unavailable — silently ignore.
        }
    }

    private func update(from args: [String: Any]) {
        let counterId = args["counterId"] as? String ?? ""
        let total = args["total"] as? Int ?? 0
        guard let activity = activities[counterId] else {
            start(from: args)
            return
        }
        Task { await activity.update(ActivityContent(state: .init(total: total), staleDate: nil)) }
    }

    private func end(counterId: String) {
        guard let activity = activities[counterId] else { return }
        activities[counterId] = nil
        Task { await activity.end(nil, dismissalPolicy: .immediate) }
    }

    private func hex(_ value: Int) -> String {
        String(format: "#%06X", value & 0xFFFFFF)
    }
}
