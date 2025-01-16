//
//  ContentView.swift
//  Bad Habits
//
//  Created by Mustafa Yusuf on 14/01/25.
//

import SwiftUI
import CoreData

struct HomeView: View {
    @FetchRequest(
        sortDescriptors: [
            NSSortDescriptor(keyPath: \Problem.title, ascending: true)
        ],
        animation: .default
    )
    private var problems: FetchedResults<Problem>
    @State private var appState: AppState = .shared
    
    var body: some View {
        ScrollView {
            LazyVStack(spacing: Spacing.large) {
                ForEach(problems) { problem in
                    ProblemSection(problem: problem)
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
                await SyncEngine.shared.fetchChanges(in: .private)
                await SyncEngine.shared.fetchChanges(in: .shared)
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
