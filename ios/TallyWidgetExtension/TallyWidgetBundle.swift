import SwiftUI
import WidgetKit

/// Entry point for the Tally widget extension: a Lock Screen widget and the
/// Live Activity UI.
@main
struct TallyWidgetBundle: WidgetBundle {
    var body: some Widget {
        TallyLockScreenWidget()
        if #available(iOS 16.1, *) {
            TallyLiveActivityWidget()
        }
    }
}
