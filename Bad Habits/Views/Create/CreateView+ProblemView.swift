//
//  AddProblemView.swift
//  Bad Habits
//
//  Created by Mustafa Yusuf on 15/01/25.
//

import SwiftUI

extension CreateView {
    struct ProblemView: View {
        
        @Environment(\.dismiss) private var dismiss
        @Environment(\.managedObjectContext) private var managedObjectContext
        @State private var title: String = ""
        
        var body: some View {
            TextField("Be honest...", text: $title)
                .textFieldStyle(.roundedBorder)
            
            Button {
                let problem = Problem(context: managedObjectContext)
                problem.id = UUID()
                problem.title = title
                
                SyncEngine.shared.syncObject(problem)
                
                // add force unwrapping to Programming Problems
                try! managedObjectContext.save()
                
                dismiss()
            } label: {
                Text("Add to the list of problems")
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
