//
//  Extensions.swift
//  Prova2
//
//  Created by Marcello Catelli on 07/06/2017.
//  Copyright (c) 2017 Swift srl. All rights reserved.
//

import UIKit
import AVFoundation

extension Formatter {
    
    static let withSeparator: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.groupingSeparator = "."
        formatter.numberStyle = .decimal
        return formatter
    }()
    
}

extension Int {
    
    var formattedWithSeparator: String {
        return Formatter.withSeparator.string(for: self) ?? ""
    }

}

extension StringProtocol {

    var firstUppercased: String {
        guard let first = first else { return "" }
        return String(first).uppercased() + dropFirst()
    }

}

extension String {

    func toDate (format: String) -> Date? {
        return DateFormatter(format: format).date(from: self)
    }
    
}

// Date
let componentFlags : Set<Calendar.Component> = [Calendar.Component.year, Calendar.Component.month, Calendar.Component.day, Calendar.Component.weekdayOrdinal, Calendar.Component.hour,Calendar.Component.minute, Calendar.Component.second, Calendar.Component.weekday, Calendar.Component.weekdayOrdinal]

extension DateFormatter {
    convenience init (format: String) {
        self.init()
        dateFormat = format
        locale = Locale.current
    }
}

extension Date {

    func plusMinutes(_ m: Int) -> Date {
        return self.addComponentsToDate(seconds: 0, minutes: m, hours: 0, days: 0, weeks: 0, months: 0, years: 0)
    }

    private func addComponentsToDate(seconds sec: Int, minutes min: Int, hours hrs: Int, days d: Int, weeks wks: Int, months mts: Int, years yrs: Int) -> Date {
        var dc:DateComponents = DateComponents()
        dc.second = sec
        dc.minute = min
        dc.hour = hrs
        dc.day = d
        dc.weekOfYear = wks
        dc.month = mts
        dc.year = yrs
        return Calendar.current.date(byAdding: dc, to: self, wrappingComponents: false)!
    }

    static func secondsBetween(date1 d1:Date, date2 d2:Date) -> Int {
        let dc = Calendar.current.dateComponents(componentFlags, from: d1, to: d2)
        return dc.second!
    }

    static func minutesBetween(date1 d1: Date, date2 d2: Date) -> Int {
        let dc = Calendar.current.dateComponents(componentFlags, from: d1, to: d2)
        return dc.minute!
    }

    static func hoursBetween(date1 d1: Date, date2 d2: Date) -> Int {
        let dc = Calendar.current.dateComponents(componentFlags, from: d1, to: d2)
        return dc.hour!
    }

    var yesterday: Date {
        return Calendar.current.date(byAdding: .day, value: -1, to: noon)!
    }
    var noon: Date {
        return Calendar.current.date(bySettingHour: 12, minute: 0, second: 0, of: self)!
    }
    
    func isGreaterThan(_ date: Date) -> Bool {
        return (self.compare(date) == .orderedDescending)
    }

}
