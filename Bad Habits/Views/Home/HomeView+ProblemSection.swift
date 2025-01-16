//
//  ProblemSection.swift
//  Bad Habits
//
//  Created by Mustafa Yusuf on 15/01/25.
//

import SwiftUI

extension HomeView {
    struct ProblemSection: View {
        @Environment(\.managedObjectContext) private var managedObjectContext
        @ObservedObject private var problem: Problem
        @FetchRequest private var badHabits: FetchedResults<BadHabit>
        
        init(problem: Problem) {
            self.problem = problem
            self._badHabits = .init(
                fetchRequest: BadHabit.fetchRequest(for: problem),
                animation: .smooth
            )
        }
        
        var body: some View {
            VStack(alignment: .leading, spacing: Spacing.medium) {
                HStack(spacing: .zero) {
                    Text(.init(problem.title ?? ""))
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .multilineTextAlignment(.leading)
                    
                    Menu {
                        Button("Edit", systemImage: "pencil") {
                            AppState.shared.sheet = .update(.problem(problem))
                        }
                        
                        Button("Add a bad habit", systemImage: "plus") {
                            AppState.shared.sheet = .create(.badHabit(problem: problem))
                        }
                        
                        Button("Delete Problem (Liar)", systemImage: "trash", role: .destructive) {
                            SyncEngine.shared.deleteZone(problem)
                            managedObjectContext.delete(problem)
                            try! managedObjectContext.save()
                        }
                    } label: {
                        Image(systemName: "ellipsis")
                            .padding(Spacing.standard)
                            .contentShape(Rectangle())
                    }
                }
                
                LazyVStack(alignment: .leading, spacing: Spacing.standard) {
                    ForEach(badHabits) { badHabit in
                        BadHabitCard(badHabit)
                    }
                    if badHabits.isEmpty {
                        AddBadHabitCard(problem: problem)
                    }
                }
            }
        }
    }
}

extension HomeView.ProblemSection {
    struct BadHabitCard: View {
        struct Month: Identifiable, Hashable {
            let startDate: Date
            let endDate: Date
            let days: [Date]
            let blankDaysBeforeStart: Int
            
            var id: Date { startDate }
        }

        @Environment(\.managedObjectContext) private var managedObjectContext
        @ObservedObject private var badHabit: BadHabit
        @FetchRequest private var oopsies: FetchedResults<Oopsie>
        
        @State private var months: [Month] = []
        
        private let rows: [GridItem] = [GridItem].init(
            repeating: .init(.flexible(), spacing: 2, alignment: .leading),
            count: 7
        )
        
        init(_ badHabit: BadHabit) {
            self.badHabit = badHabit
            self._oopsies = .init(
                fetchRequest: Oopsie.fetchRequest(for: badHabit),
                animation: .smooth
            )
        }
        
        var body: some View {
            VStack(alignment: .leading) {
                Text(.init(badHabit.title ?? ""))
                    .font(.headline)
                    .padding(.trailing, Spacing.standard)
                
                HStack(spacing: .zero) {
                    VStack(alignment: .leading, spacing: .zero) {
                        TitleView(title: "D")
                            .hidden()
                        ForEach(Calendar.autoupdatingCurrent.shortWeekdaySymbols, id: \.self) { weekday in
                            Text(weekday)
                                .font(.caption)
                                .foregroundStyle(Color(.tertiaryLabel))
                                .padding(.vertical, 4)
                        }
                    }
                    
                    ScrollView(.horizontal) {
                        HStack(spacing: Spacing.standard) {
                            ForEach(months) { month in
                                VStack(alignment: .trailing, spacing: .zero) {
                                    TitleView(title: month.startDate.monthTitle())
                                    LazyHGrid(
                                        rows: rows,
                                        alignment: .center,
                                        spacing: 2
                                    ) {
                                        if month.blankDaysBeforeStart > 0 {
                                            ForEach(1...month.blankDaysBeforeStart, id: \.self) { _ in
                                                BlankDayCard()
                                            }
                                        }
                                        ForEach(month.days, id: \.self) { day in
                                            DayView(badHabit: badHabit, day: day)
                                        }
                                    }
                                    .frame(maxHeight: .infinity)
                                }
                            }
                        }
                        .padding(.horizontal, Spacing.standard)
                    }
                    .mask {
                        LinearGradient(
                            stops: [
                                .init(color: .clear, location: 0.01),
                                .init(color: .white, location: 0.02),
                                .init(color: .white, location: 0.95),
                                .init(color: .clear, location: 1),
                            ],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    }
                    .scrollIndicators(.hidden)
                }
            }
            .padding([.vertical, .leading], Spacing.standard)
            .background(Color(UIColor.secondarySystemGroupedBackground))
            .clipShape(.rect(cornerRadius: CornerRadius.standard))
            .task {
                months = getLast11Months(from: .now)
            }
            .contextMenu {
                Button("Edit", systemImage: "pencil") {
                    AppState.shared.sheet = .update(.badHabit(badHabit))
                }
                
                Button("Delete Bad Habit 😂", systemImage: "trash", role: .destructive) {
                    SyncEngine.shared.deleteObject(badHabit)
                    
                    managedObjectContext.delete(badHabit)
                    try! managedObjectContext.save()
                }
            }
        }
        
        func getLast11Months(from date: Date) -> [Month] {
            var months: [Month] = []
            let calendar = Calendar.autoupdatingCurrent
            
            for offset in (0...10) {
                guard let monthStartDate = calendar.date(byAdding: .month, value: -offset, to: date)?.startOfMonth(),
                      let monthEndDate = calendar.date(byAdding: .month, value: -offset, to: date)?.endOfMonth() else {
                    continue
                }
                
                // Calculate days in the month
                var days: [Date] = []
                var currentDate = monthStartDate
                
                while currentDate <= monthEndDate {
                    days.append(currentDate)
                    guard let nextDate = calendar.date(byAdding: .day, value: 1, to: currentDate) else {
                        break
                    }
                    currentDate = nextDate
                }
                
                days = days
                    .filter { $0 <= date }
                    .reversed()
                
                // Calculate blank days before the first day of the month
                guard let firstDate = days.first else {
                    continue
                }
                let weekdayOfFirstDay = calendar.component(.weekday, from: firstDate)
                let blankDays = weekdayOfFirstDay - calendar.firstWeekday
                
                months.append(
                    .init(
                        startDate: monthStartDate,
                        endDate: monthEndDate,
                        days: days,
                        blankDaysBeforeStart: blankDays >= 0 ? blankDays : 7 + blankDays
                    )
                )
            }
            
            return months
        }
        
        struct TitleView: View {
            let title: String
            var body: some View {
                Text(title)
                    .font(.footnote)
            }
        }
    }
}

extension HomeView.ProblemSection {
    struct AddBadHabitCard: View {
        @ObservedObject var problem: Problem
        
        var body: some View {
            Button {
                AppState.shared.sheet = .create(.badHabit(problem: problem))
            } label: {
                HStack {
                    Image(systemName: "plus.circle.fill")
                        .foregroundStyle(Color(.secondaryLabel))
                    
                    Text("Add a bad \"\(problem.title ?? "")\" habit")
                        .font(.subheadline)
                        .foregroundStyle(Color(.label))
                        .multilineTextAlignment(.leading)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                .padding(Spacing.standard)
                .background(Color(UIColor.secondarySystemGroupedBackground))
                .clipShape(.rect(cornerRadius: CornerRadius.standard))
            }
        }
    }
}

extension HomeView.ProblemSection.BadHabitCard {
    struct DayView: View {
        @Environment(\.managedObjectContext) private var managedObjectContext
        @ObservedObject private var badHabit: BadHabit
        @FetchRequest private var oopsies: FetchedResults<Oopsie>
        
        let day: Date
        let dayOfMonth: Int
        
        var backgroundColor: Color {
            oopsies.isEmpty ? Color(.tertiarySystemGroupedBackground) : Color.accentColor
        }
        
        var foregroundColor: Color {
            oopsies.isEmpty ? Color(.secondaryLabel) : .white
        }
        
        init(badHabit: BadHabit, day: Date) {
            self.day = day
            let calendar = Calendar.autoupdatingCurrent
            let startDate = calendar.startOfDay(for: day)
            let endDate = startDate.addingTimeInterval(86399)
            self.badHabit = badHabit
            self.dayOfMonth = calendar.component(.day, from: startDate)
            self._oopsies = .init(
                fetchRequest: Oopsie.fetchRequest(
                    for: badHabit,
                    startDate: startDate,
                    endDate: endDate
                ),
                animation: .smooth
            )
        }
        
        var body: some View {
            Button {
                guard oopsies.isEmpty else {
                    oopsies.forEach { oopsie in
                        SyncEngine.shared.deleteObject(oopsie)
                        managedObjectContext.delete(oopsie)
                    }
                    return
                }
                let oopsie = Oopsie(context: managedObjectContext)
                oopsie.id = UUID()
                oopsie.timestamp = day
                oopsie.badHabit = badHabit
                
                SyncEngine.shared.syncObject(oopsie)
                
                try! managedObjectContext.save()
            } label: {
                RoundedRectangle(cornerRadius: 4)
                    .aspectRatio(1, contentMode: .fit)
                    .foregroundStyle(backgroundColor)
                    .overlay {
                        Text("\(dayOfMonth)")
                            .font(.caption)
                            .foregroundStyle(foregroundColor)
                    }
            }
        }
    }
}

extension HomeView.ProblemSection.BadHabitCard {
    struct BlankDayCard: View {
        var body: some View {
            Rectangle()
                .foregroundStyle(.clear)
                .aspectRatio(1, contentMode: .fit)
        }
    }
}
