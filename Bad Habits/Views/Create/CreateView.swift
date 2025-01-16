//
//  CreateView.swift
//  Bad Habits
//
//  Created by Mustafa Yusuf on 15/01/25.
//

import SwiftUI

struct CreateView: View {
    enum Item: Identifiable {
        case problem
        case badHabit(problem: Problem)
        
        var id: String {
            switch self {
                case .problem:
                    return "problem"
                case .badHabit(let problem):
                    return problem.id?.uuidString ?? "bad-habit"
            }
        }
    }
    
    let item: Item
    
    var body: some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: Spacing.large) {
                switch item {
                    case .problem:
                        ProblemView()
                    case .badHabit(let problem):
                        BadHabitView(problem: problem)
                }
            }
            .padding(Spacing.standard)
        }
    }
}
