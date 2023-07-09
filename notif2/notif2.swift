import SwiftUI

@main
struct notif2App: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        WindowGroup {
            SelectExistingGoalView(state: appDelegate.state)
        }
    }
}
