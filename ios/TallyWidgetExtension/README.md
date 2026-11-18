# iOS: add the Tally widget extension

The Dart bridge and all Swift sources are already in the repo. Xcode targets
cannot be created from the command line, so finish these steps once in Xcode:

1. Open `ios/Runner.xcworkspace` in Xcode.
2. **File ▸ New ▸ Target… ▸ Widget Extension**.
   - Product name: `TallyWidgetExtension`
   - Bundle id: `com.tallycounter.tallyCounter.TallyWidgetExtension`
   - Uncheck "Include Configuration Intent".
3. Delete the files Xcode generated for the new target, then add these instead
   (already present in `ios/TallyWidgetExtension/`):
   - `TallyWidgetBundle.swift`
   - `TallyLockScreenWidget.swift`
   - `TallyLiveActivityWidget.swift`
   - `Info.plist` (set as the target's Info.plist in Build Settings)
4. Add `ios/Shared/TallyActivityAttributes.swift` to **both** the
   `Runner` and `TallyWidgetExtension` targets
   (File Inspector ▸ Target Membership ▸ check both).
5. Select the `TallyWidgetExtension` target ▸ Signing & Capabilities ▸
   **+ Capability ▸ App Groups** and add `group.com.tallycounter.tallyCounter`.
   Add the same App Group to the `Runner` target (its
   `Runner/Runner.entitlements` already declares it).
6. Build and run. The Lock Screen widget appears under "Tally", and enabling
   **Settings ▸ Lock Screen & Widgets** starts a Live Activity.

Both targets must use the same App Group id as
`TallySharedKeys.appGroup` and `HomeWidget.setAppGroupId(...)` in
`lib/main.dart`.
