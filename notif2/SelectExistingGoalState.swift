//
// Created by Kojo Gambrah on 4/5/23.
//

import Foundation
import Combine

class SelectExistingGoalState: ObservableObject {
    @Published var goals: [String] = []
    var completionHandler: (String?, Bool) -> Void = { _, _ in }

//    init(completionHandler: @escaping (String?, Bool) -> Void) {
//        self.completionHandler = completionHandler
//    }

    func updateGoals(goals: [String]) {
        self.goals = goals
    }

    func setCompletionHandler(completionHandler: @escaping (String?, Bool) -> Void) {
        self.completionHandler = completionHandler // shouldCloseWindow?
    }
}
