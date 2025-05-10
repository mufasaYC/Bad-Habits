//
//  UpdateView+BadHabitView.swift
//  Bad Habits
//
//  Created by Mustafa Yusuf on 15/01/25.
//

import MYCloudKit
import SwiftUI

extension UpdateView {
    struct BadHabitView: View {
        
        @Environment(\.dismiss) private var dismiss
        @Environment(\.managedObjectContext) private var managedObjectContext
        @ObservedObject private var badHabit: BadHabit
        @State private var title: String
        
        init(badHabit: BadHabit) {
            self.badHabit = badHabit
            self._title = .init(wrappedValue: badHabit.title ?? "")
        }
        
        var body: some View {
            TextField("Bad \"\(badHabit.problem?.title ?? "")\" habit...", text: $title)
                .textFieldStyle(.roundedBorder)
            
            Button {
                badHabit.title = title
                
                AppState.shared.syncEngine.sync(badHabit)
                
                // add force unwrapping to Programming Problems
                try! managedObjectContext.save()
                
                dismiss()
            } label: {
                Text("Update")
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
