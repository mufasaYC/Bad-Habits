//
//  UpdateView+ProblemView.swift
//  Bad Habits
//
//  Created by Mustafa Yusuf on 15/01/25.
//

import MYCloudKit
import SwiftUI

extension UpdateView {
    struct ProblemView: View {
        
        @Environment(\.dismiss) private var dismiss
        @Environment(\.managedObjectContext) private var managedObjectContext
        @ObservedObject private var problem: Problem
        @State private var title: String
        
        init(problem: Problem) {
            self.problem = problem
            self._title = .init(wrappedValue: problem.title ?? "")
        }
        
        var body: some View {
            TextField("Be honest...", text: $title)
                .textFieldStyle(.roundedBorder)
            
            Button {
                problem.title = title
                
                AppState.shared.syncEngine.sync(problem)
                
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
