import Cocoa
import Foundation
import Swifter

class Server {
    var server: HttpServer!
    var appDelegate: AppDelegate!
//    var activeWindowHelper = ActiveWindow()

    // constructor
    init(this: AppDelegate) {
        appDelegate = this
    }

    func startSwifterServer() {
        server = HttpServer()
        server["/"] = { request in
            .ok(.text("Hello, Swifter!"))
        }

        server["/quickie"] = { request in
            print("received request at /confirm_goal")

            var result = "Unknown action"
            NotificationManager.shared.menuTestScheduleNotification(timeInterval: 1) { userResponse in
                result = userResponse
            }
            NotificationManager.shared.semaphore.wait()

            return .ok(.text(result))
        }

        server["/confirm_goal"] = { request in
            var result = "Unknown action"
            if request.method == "POST" {
                guard let bodyData: Data? = Data(request.body) else {
                    return HttpResponse.badRequest(.text("Bad Request"))
                }

                do {
                    let json = try JSONSerialization.jsonObject(with: bodyData!, options: [])
                    print("Received JSON: \(json)")

                    guard let json = json as? [String: Any] else {
                        print("Error: JSON is not in the expected format")
                        return HttpResponse.badRequest(.text("Malformed JSON"))
                    }

                    if let currentGoals = json["currentGoals"] as? [String] {
                        // call app delegate to update the goals
                        self.appDelegate.updateExistingGoals(goals: currentGoals)
                    }

                    let semaphore = DispatchSemaphore(value: 0)

                    NotificationManager.shared.scheduleDaemonDrivenNotification(json: json, timeInterval: 1) { userResponse in
                        result = userResponse
                        semaphore.signal()
                    }

                    semaphore.wait()

                    // Return a response
                    let jsonResponse: [String: Any] = ["success": true, "selectedGoal": result]
                    let jsonData = try JSONSerialization.data(withJSONObject: jsonResponse, options: [])
                    return HttpResponse.ok(.json(jsonResponse))
                } catch {
                    print("Error parsing JSON: \(error)")
                    return HttpResponse.internalServerError
                }
            } else {
                return HttpResponse.badRequest(.text("Bad Request"))
            }
        }

        // Get /get_active_window
        server["/active_window"] = { request in
            sleep(2)
            if request.method == "GET" {
            print("received request at /get_active_window")
            let activeWindowNumber = 123
            let jsonResponse: [String: Any] = ["activeWindow": activeWindowNumber]
            return HttpResponse.ok(.json(jsonResponse))
            } else {
                return HttpResponse.badRequest(.text("Bad Request"))
            }
        }

        do {
            try server.start(37261)
            print("Server started and listening on port 37261")
        } catch {
            print("Server failed to start: \(error)")
        }
    }

}
