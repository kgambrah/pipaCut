import Foundation
import UserNotifications


class NotificationManager {
    static let shared = NotificationManager()
    
    private var socketTask: URLSessionWebSocketTask?
    private let connectionRetryDelay: TimeInterval = 5
    var completionHandler: ((_ result: String) -> Void)? //(String?) -> Void
    let semaphore = DispatchSemaphore(value: 0)


    func requestAuthorization() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound]) { granted, error in
            if granted {
                self.setupNotificationCategory()
            } else {
                print("Authorization failed: \(String(describing: error))")
            }
        }
    }
    
    private func setupNotificationCategory() {
        let yesAction = UNTextInputNotificationAction(identifier: NotificationType.newGoal.rawValue, title: "No", options: [], textInputButtonTitle: "Submit", textInputPlaceholder: "Enter your new goal")
        let noAction = UNNotificationAction(identifier: NotificationType.sameGoal.rawValue, title: "Yes", options: [])
        let skipAction = UNNotificationAction(identifier: NotificationType.existingGoal.rawValue, title: "Existing", options: [])
        
        let category = UNNotificationCategory(identifier: "PIPA_CONFIRMATION_ALERT",
                                              actions: [yesAction, noAction, skipAction],
                                              intentIdentifiers: [],
                                              options: [])

        UNUserNotificationCenter.current().setNotificationCategories([category])
    }

    
    func menuTestScheduleNotification(timeInterval: TimeInterval, completionHandler: @escaping (String) -> Void) {

        self.completionHandler = completionHandler
        let content = UNMutableNotificationContent()
        content.title = "Pipa - Check-in"
        content.body = "Are you working on a new goal?"
        content.sound = UNNotificationSound.default
        content.categoryIdentifier = "PIPA_CONFIRMATION_ALERT"

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: timeInterval, repeats: false)

        let identifier = "LocalNotification"
        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)

        let center = UNUserNotificationCenter.current()
        center.add(request) { error in
            if let error = error {
                print("Error scheduling notification: \(error)")
            }
        }
    }

    func scheduleDaemonDrivenNotification(json: [String: Any], timeInterval: TimeInterval, httpRequestCompletionHandler: @escaping (String) -> Void) {
        completionHandler = httpRequestCompletionHandler
        let content = UNMutableNotificationContent()

        // Retrieve text values from JSON object
        let title = json["title"] as? String ?? "Pipa - Check-in"
        let body = json["body"] as? String ?? "Are you working on a new goal?"
        let currentGoal = json["currentGoal"] as? String ?? ""

        content.title = title
        content.body = body
        content.sound = UNNotificationSound.default
        content.userInfo = ["currentGoal": currentGoal]
        content.interruptionLevel = .critical
        content.relevanceScore = 1.0
        content.threadIdentifier = "pipa"

        if !(currentGoal == nil || currentGoal == "") {
            content.categoryIdentifier = "PIPA_CONFIRMATION_ALERT"
        }

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: timeInterval, repeats: false)

        let identifier = "LocalNotification"
        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: nil)

        let center = UNUserNotificationCenter.current()
        center.add(request) { error in
            if let error = error {
                print("Error scheduling notification: \(error)")
            }
        }
    }


    // enums for the different types of notifications
    enum NotificationType : String {
        case sameGoal = "sameGoal"
        case newGoal = "newGoal"
        case existingGoal = "existingGoal"
    }

}
