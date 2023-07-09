import SwiftUI

struct SelectExistingGoalView: View {
    @State private var selectedGoalIndex: Int? = nil
    @State private var showAddGoalWindow = false
    @ObservedObject var state: SelectExistingGoalState

    init(state: SelectExistingGoalState) {
        self.state = state
    }

    var body: some View {
        VStack {
            HStack {
                Text("Select an existing goal").font(.headline)
                Spacer()
            }
            List(selection: $selectedGoalIndex) {
                ForEach(0..<state.goals.count, id: \.self) { index in
                    Text(state.goals[index]).tag(index)
                }
//                .onAppear {
//                    if state.goals.count == 1 {
//                        selectedGoalIndex = 0
//                    }
//                }
            }
            .frame(minHeight: 0, maxHeight: .infinity).listStyle(PlainListStyle())

            HStack {
                Button(action: {
                    showAddGoalWindow.toggle()
                }) {
                    Text("Add New Goal")
                }
                .sheet(isPresented: $showAddGoalWindow) {
                    NewGoalEntryWindowView { newGoal in
                        if let newGoal = newGoal {
                            // Check if the new goal is already in the list
                            if let existingIndex = state.goals.firstIndex(of: newGoal) {
                                // Select the existing goal
                                selectedGoalIndex = existingIndex
                            } else {
                                // Add the new goal and select it
                                state.goals.append(newGoal)
                                selectedGoalIndex = state.goals.count - 1
                            }
                        }
                        showAddGoalWindow = false
                    }
                }

                Spacer()

                Button(action: {
                    if let selectedIndex = selectedGoalIndex {
                        let selectedGoal = state.goals[selectedIndex]
                        state.completionHandler(selectedGoal, true) // Close the window
                    } else {
                        state.completionHandler(nil, false) // Keep the window open
                    }
                }) {
                    Text("Submit")
                }
                .buttonStyle(DefaultButtonStyle())
                .disabled(selectedGoalIndex == nil)
            }
            .padding(.top, 10)
        }
        .padding()
        .frame(minWidth: 250, minHeight: 500)
    }
}

struct NewGoalEntryWindowView: View {
    @State private var newGoal = ""
    let completionHandler: (String?) -> Void

    var body: some View {
        VStack {
            Text("Enter a new goal").font(.headline)
            TextField("New goal", text: $newGoal)
                .textFieldStyle(RoundedBorderTextFieldStyle())
            HStack {
                Spacer()
                Button(action: {
                    completionHandler(newGoal.isEmpty ? nil : newGoal)
                }) {
                    Text("Submit")
                }
                .buttonStyle(DefaultButtonStyle())
                .disabled(newGoal.isEmpty)
            }
        }
        .padding()
        .frame(minWidth: 250, minHeight: 120)
    }
}
//
//struct ContentView_Previews: PreviewProvider {
//    static var previews: some View {
//        SelectExistingGoalView()
//    }
//}

