//
//  Date+Extension.swift
//  Bad Habits
//
//  Created by Mustafa Yusuf on 15/01/25.
//

import Foundation

extension Date {
    func startOfMonth() -> Date? {
        let calendar = Calendar.current
        return calendar.date(from: calendar.dateComponents([.year, .month], from: self))
    }
    
    func endOfMonth() -> Date? {
        let calendar = Calendar.current
        guard let startOfNextMonth = calendar.date(byAdding: .month, value: 1, to: self.startOfMonth()!) else {
            return nil
        }
        return calendar.date(byAdding: .day, value: -1, to: startOfNextMonth)
    }
}

extension Date {
    func monthTitle() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM"
        return formatter.string(from: self)
    }
}
