//
//  NewBadHabitView.swift
//  Bad Habits
//
//  Created by Mustafa Yusuf on 15/01/25.
//

import MYCloudKit
import SwiftUI

extension CreateView {
    struct BadHabitView: View {
        
        @Environment(\.dismiss) private var dismiss
        @Environment(\.managedObjectContext) private var managedObjectContext
        let problem: Problem
        @State private var title: String = ""
        
        init(problem: Problem) {
            self.problem = problem
        }
        
        var body: some View {
            TextField("Bad \"\(problem.title ?? "")\" habit...", text: $title)
                .textFieldStyle(.roundedBorder)
            
            Button {
                let badHabit = BadHabit(context: managedObjectContext)
                badHabit.id = UUID()
                badHabit.title = title
                badHabit.problem = problem
                
                AppState.shared.syncEngine.sync(badHabit)
                
                // add force unwrapping to Programming Problems
                try! managedObjectContext.save()
                
                dismiss()
            } label: {
                Text("Add Bad Habit")
                    .font(.headline)
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .contentShape(Rectangle())
                    .background(Color.accentColor)
                    .clipShape(.rect(cornerRadius: CornerRadius.standard))
            }
        }
    }
}
