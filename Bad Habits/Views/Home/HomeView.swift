//
//  ContentView.swift
//  Bad Habits
//
//  Created by Mustafa Yusuf on 14/01/25.
//

import CoreData
import MYCloudKit
import SwiftUI

struct HomeView: View {
    @FetchRequest(
        sortDescriptors: [
            NSSortDescriptor(keyPath: \Problem.title, ascending: true)
        ],
        animation: .default
    )
    private var problems: FetchedResults<Problem>
    @State private var appState: AppState = .shared
    
    @FetchRequest(
        sortDescriptors: [
            NSSortDescriptor(keyPath: \BadHabit.title, ascending: true)
        ],
        predicate: .init(format: "problem == %@", NSNull()),
        animation: .default
    )
    private var ungroupedBadHabits: FetchedResults<BadHabit>
    
    var body: some View {
        ScrollView {
            LazyVStack(spacing: Spacing.large) {
                ForEach(problems) { problem in
                    ProblemSection(problem: problem)
                }
                
                if !ungroupedBadHabits.isEmpty {
                    Divider()
                    ForEach(ungroupedBadHabits) { badHabit in
                        ProblemSection.BadHabitCard(badHabit)
                    }
                }
            }
            .padding(Spacing.standard)
        }
        .background(Color(UIColor.systemGroupedBackground).ignoresSafeArea())
        .safeAreaInset(edge: .bottom) {
            AddProblemCard()
                .padding(.vertical, Spacing.standard)
        }
        .sheet(item: $appState.sheet) { sheet in
            sheet.view
        }
        .task {
            Task {
                await AppState.shared.syncEngine.fetch()
            }
        }
    }
}

extension HomeView {
    struct AddProblemCard: View {
            
        var body: some View {
            Button {
                AppState.shared.sheet = .create(.problem)
            } label: {
                HStack {
                    Image(systemName: "plus")
                        .foregroundStyle(.accent)
                        .imageScale(.large)
                    Text("New Problem")
                        .foregroundStyle(Color(.label))
                }
                .font(.callout)
                .padding(.vertical, Spacing.medium)
                .padding(.horizontal, Spacing.standard)
                .background(.regularMaterial)
                .clipShape(Capsule())
                .contentShape(Rectangle())
            }
        }
    }
}
