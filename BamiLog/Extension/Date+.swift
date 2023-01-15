//
//  Date+.swift
//  BamiLog
//
//  Created by hyunho lee on 2023/01/15.
//

import Foundation

extension Date {
    
    func getAllDates()->[Date] {
        
        let calendar = Calendar.current
        let startDate = calendar.date(from: Calendar.current.dateComponents([.year,.month], from: self))!
        let range = calendar.range(of: .day, in: .month, for: startDate)!
        
        return range.compactMap { day -> Date in
            return calendar.date(byAdding: .day, value: day - 1, to: startDate)!
        }
    }
}

struct DateValue: Identifiable {
    var id = UUID().uuidString
    var day: Int
    var date: Date
}

struct Task: Identifiable, Codable {
    var id = UUID().uuidString
    var title: String
    var time: Date = Date()
}

struct TaskMetaData: Identifiable, Codable {
    var id = UUID().uuidString
    var task: [Task]
    var taskDate: Date
}
