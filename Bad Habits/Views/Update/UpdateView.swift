//
//  UpdateView.swift
//  Bad Habits
//
//  Created by Mustafa Yusuf on 15/01/25.
//

import SwiftUI

struct UpdateView: View {
    enum Item: Identifiable {
        case problem(Problem)
        case badHabit(BadHabit)
        
        var id: String {
            switch self {
                case .problem(let problem):
                    return problem.id?.uuidString ?? "problem"
                case .badHabit(let badHabit):
                    return badHabit.id?.uuidString ?? "bad-habit"
            }
        }
    }
    
    let item: Item
    
    var body: some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: Spacing.large) {
                switch item {
                    case .problem(let problem):
                        ProblemView(problem: problem)
                    case .badHabit(let badHabit):
                        BadHabitView(badHabit: badHabit)
                }
            }
            .padding(Spacing.standard)
        }
    }
}
