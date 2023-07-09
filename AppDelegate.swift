import Cocoa
import Foundation
import SwiftUI
import UserNotifications
import Swifter
// import swifter server
// import notification manager




class AppDelegate: NSObject, NSApplicationDelegate, UNUserNotificationCenterDelegate {
    var window: NSWindow!
    var state: SelectExistingGoalState = SelectExistingGoalState()
    var server: Server!
    var windowController: MyWindowController! // Add this line
    let daemonIdentifier = "com.pipa.classificationapp"
    var statusMenu: NSMenuItem!
    private var statusItem: NSStatusItem!

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        server = Server(this: self)
        server.startSwifterServer()

        window = NSApplication.shared.windows.first { $0.isVisible }
        
        NotificationManager.shared.requestAuthorization()
        UNUserNotificationCenter.current().delegate = self

        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)

        if let button = statusItem.button {
            button.image = NSImage(systemSymbolName: "p.square", accessibilityDescription: "Pipa")
        }

        createMenu()
        
        let completionHandler: (String?, Bool) -> Void = { selectedGoal, shouldCloseWindow in
            if shouldCloseWindow {
              NSApplication.shared.keyWindow?.close()
            }
            if let selectedGoal = selectedGoal {
                print("Submitted goal: \(selectedGoal)")
                self.callHandler(replyText: selectedGoal)
            }
        }
        state.setCompletionHandler(completionHandler: completionHandler)

        // Create an instance of the custom NSWindowController
        windowController = MyWindowController(window: window)

        // Hide the window at launch
        window.orderOut(nil)
    }


    func createMenu() {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        if let button = statusItem.button {
            button.title = "Pipa"
            button.action = #selector(statusItemClicked)
        }
        let menu = NSMenu()


        statusMenu = NSMenuItem(title: "Status: Unknown", action: nil, keyEquivalent: "")
        menu.addItem(statusMenu)
        menu.addItem(NSMenuItem.separator())


        menu.addItem(NSMenuItem(title: "Start", action: #selector(startDaemon), keyEquivalent: ""))
        menu.addItem(NSMenuItem(title: "Stop", action: #selector(stopDaemon), keyEquivalent: ""))

        menu.addItem(NSMenuItem.separator())

        let one = NSMenuItem(title: "Test Ping", action: #selector(menuSendAlert), keyEquivalent: "1")
        menu.addItem(one)
        menu.addItem(NSMenuItem.separator())

        menu.addItem(NSMenuItem(title: "Quit Pipa", action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q"))

        statusItem.menu = menu

        DispatchQueue.main.async {
            Timer.scheduledTimer(timeInterval: 2, target: self, selector: #selector(self.updateStatusMenuItemTitle), userInfo: nil, repeats: true)
        }
    }



    @objc func startDaemon() {
        let task = Process()
        let outputPipe = Pipe()
        let errorPipe = Pipe()
        task.standardOutput = outputPipe
        task.standardError = errorPipe
        task.executableURL = URL(fileURLWithPath: "/bin/launchctl")
        let uid = getuid()
        // /bin/launchctl kickstart -k gui/501/com.pipa.classificationapp
        task.arguments = ["kickstart", "-k", "gui/\(uid)/\(daemonIdentifier)"]
        let command = "/bin/launchctl \(task.arguments!.joined(separator: " "))"
        print("Executing command:", command)
        do {
            try task.run()

            let outputData = outputPipe.fileHandleForReading.readDataToEndOfFile()
            if let outputString = String(data: outputData, encoding: .utf8), !outputString.isEmpty {
                print("Start Daemon Output:", outputString)
            }

            let errorData = errorPipe.fileHandleForReading.readDataToEndOfFile()
            if let errorString = String(data: errorData, encoding: .utf8), !errorString.isEmpty {
                print("Start Daemon Error:", errorString)
            }

            task.waitUntilExit()
        } catch {
            print("Error starting daemon:", error)
        }
    }

    @objc func stopDaemon() {
        let task = Process()
        let outputPipe = Pipe()
        let errorPipe = Pipe()
        task.standardOutput = outputPipe
        task.standardError = errorPipe
        task.executableURL = URL(fileURLWithPath: "/bin/launchctl")
        let uid = getuid()
        // launchctl kill 9 gui/$(id -u)/com.pipa.classificationapp

        task.arguments = ["kill", "9", "gui/\(uid)/\(daemonIdentifier)"]
        let command = "/bin/launchctl \(task.arguments!.joined(separator: " "))"
        print("Executing command:", command)
        do {
            try task.run()

            let outputData = outputPipe.fileHandleForReading.readDataToEndOfFile()
            if let outputString = String(data: outputData, encoding: .utf8), !outputString.isEmpty {
                print("Stop Daemon Output:", outputString)
            }

            let errorData = errorPipe.fileHandleForReading.readDataToEndOfFile()
            if let errorString = String(data: errorData, encoding: .utf8), !errorString.isEmpty {
                print("Stop Daemon Error:", errorString)
            }

            task.waitUntilExit()
        } catch {
            print("Error stopping daemon:", error)
        }
    }

// Update the awakeFromNib function
    override func awakeFromNib() {
        let item = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        if let button = item.button {
            button.title = "Daemon"
            button.action = #selector(statusItemClicked)
        }
        let menu = NSMenu()

        // Add status menu item
        statusMenu = NSMenuItem(title: "Status: Unknown", action: nil, keyEquivalent: "")
        menu.addItem(statusMenu)
        menu.addItem(NSMenuItem.separator())

        menu.addItem(withTitle: "Start Daemon", action: #selector(startDaemon), keyEquivalent: "")
        menu.addItem(withTitle: "Stop Daemon", action: #selector(stopDaemon), keyEquivalent: "")
        menu.addItem(NSMenuItem.separator())
        menu.addItem(withTitle: "Quit", action: #selector(NSApp.terminate(_:)), keyEquivalent: "")

        item.menu = menu

        // Schedule a timer to update the status menu item's title
        Timer.scheduledTimer(timeInterval: 2, target: self, selector: #selector(updateStatusMenuItemTitle), userInfo: nil, repeats: true)
    }

// Function to update the status menu item's title
    @objc func updateStatusMenuItemTitle() {
        let daemonStatus = getDaemonStatus()
        statusMenu.title = daemonStatus ? "Status: Running" : "Status: Stopped"
    }

    @objc func statusItemClicked(_ sender: NSMenuItem) {
        let event = NSApp.currentEvent!
        if event.modifierFlags.contains(.option) {
            // Show menu when the Option key is pressed
            statusItem.popUpMenu(statusItem.menu!)
        } else {
            // Check daemon status and update the status item's title
            updateStatusMenuItemTitle()
        }
    }

    @objc func menuSendAlert() {
        var result = ""
        NotificationManager.shared.menuTestScheduleNotification(timeInterval: 1) { userResponse in
            result = userResponse}
    }


    func getDaemonStatus() -> Bool {
        let task = Process()
        let outputPipe = Pipe()
        task.standardOutput = outputPipe
        task.executableURL = URL(fileURLWithPath: "/bin/launchctl")
        let uid = getuid()
        task.arguments = ["print", "gui/\(uid)/\(daemonIdentifier)"]
        do {
            try task.run()

            let outputData = outputPipe.fileHandleForReading.readDataToEndOfFile()
            if let outputString = String(data: outputData, encoding: .utf8) {
                return outputString.contains("state = running")
            }
        } catch {
            print("Error checking daemon status:", error)
        }
        return false
    }



    @objc func checkDaemonStatus() {
        let task = Process()
        let outputPipe = Pipe()
        task.standardOutput = outputPipe
        task.executableURL = URL(fileURLWithPath: "/bin/launchctl")
        let uid = getuid()
        task.arguments = ["print", "gui/\(uid)/\(daemonIdentifier)"]
        do {
            try task.run()

            let outputData = outputPipe.fileHandleForReading.readDataToEndOfFile()
            if let outputString = String(data: outputData, encoding: .utf8) {
                if outputString.contains("state = running") {
                    print("Daemon is running")
                } else {
                    print("Daemon is not running")
                }
            } else {
                print("Error getting daemon status")
            }

            task.waitUntilExit()
        } catch {
            print("Error checking daemon status:", error)
        }
    }




    func applicationWillTerminate(_ aNotification: Notification) {
    }

    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                didReceive response: UNNotificationResponse,
                                withCompletionHandler completionHandler: @escaping () -> Void) {

        var replyText = "Unknown action"
        let actionIdentifier = response.actionIdentifier

        switch actionIdentifier {


            case NotificationManager.NotificationType.newGoal.rawValue:
                let textResponse = response as! UNTextInputNotificationResponse
                replyText = textResponse.userText
                print("user started a new goal")
                callHandler(replyText: replyText)
                break

            case NotificationManager.NotificationType.sameGoal.rawValue:
                print("user selected on same goal")
                var replyText = ""
                let currentGoal = response.notification.request.content.userInfo["currentGoal"]
                if let currentGoal = currentGoal as? String {
                    replyText = currentGoal
                } else {
                    print("Error: currentGoal is nil")
                }
                // Handle the "yes" action
                var textResponse = ""
                if let textInputResponse = response as? UNTextInputNotificationResponse {
                    textResponse = textInputResponse.userText
                }

                callHandler(replyText: replyText)
                break

            case NotificationManager.NotificationType.existingGoal.rawValue:
                print("user selected existing goal")
                // Display the window on the screen
                windowController.unhideWindow()
                break

        default:
            windowController.unhideWindow()
            break
        }

        completionHandler()
    }

    func updateExistingGoals(goals: [String]) {
        state.updateGoals(goals: goals)
    }

    func callHandler(replyText: String) {
        // Call the completion handler from your NotificationManager instance
        NotificationManager.shared.completionHandler?(replyText)
        NotificationManager.shared.semaphore.signal()
        print("replyText: \(replyText)")
    }

    func getMainWindow() -> NSWindow? {
        NSApp.windows.first
    }

    class MyWindowController: NSWindowController {
        // Method to unhide the window
        func unhideWindow() {
            window?.makeKeyAndOrderFront(nil)
        }
    }

}
