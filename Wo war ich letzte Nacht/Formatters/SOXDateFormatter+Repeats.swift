//
//  SOXDateFormatter+Repeats.swift
//  Landrix Handwerk Mobile
//
//  Created by Peter Hauke on 22.02.21.
//  Copyright © 2021 Landrix Software GmbH & Co. KG. All rights reserved.
//

import Foundation


//MARK: - Extension - Repeats
extension SOXDateFormatter {
    
    class func repeatDates(forDate date: Date,
                           repeatCount: Int,
                           repeatOption: RepeatOption,
                           allowedWeekDays: Weekdays)
    -> [Date] {
        var repeatDates = [Date]()
        
        guard repeatCount > 0,
              repeatOption != .never,
              allowedWeekDays.isEmpty == false
        else { return repeatDates }
        
        var nextDate = date
        var repeatOptionDateComponents = repeatOption.dateComponents // delta of dates
        
        // Special treatment for daily: the repetition after the next repetition needs to be aware of a allowedWeekDays-jump
        if repeatOption == .daily {
            for _ in 1...repeatCount {
                nextDate = Calendar.autoupdatingCurrent.date(byAdding: repeatOptionDateComponents,
                                                             to: nextDate)!
                // Check for forbidden weekday
                while allowedWeekDays.forbidds(nextDate) {
                    nextDate = Calendar.autoupdatingCurrent.date(byAdding: repeatOptionDateComponents,
                                                                 to: nextDate)!
                }
                repeatDates.append(nextDate)
            }
            
        }
        else {
            let stepWidth = repeatOption.stepWidth
            let calendarComponent = repeatOption.calendarComponent
            
            for step in 1...repeatCount {
                let finalStepWidth = step * stepWidth
                repeatOptionDateComponents.setValue(finalStepWidth, for: calendarComponent)
                nextDate = Calendar.autoupdatingCurrent.date(byAdding: repeatOptionDateComponents,
                                                             to: date)!
                // Check for forbidden weekday
                while allowedWeekDays.forbidds(nextDate) {
                    nextDate = Calendar.autoupdatingCurrent.date(byAdding: .day,
                                                                 value: 1,
                                                                 to: nextDate)!
                }
                repeatDates.append(nextDate)
            }
        }

        return repeatDates
    }
    
    
    class func repeatCount(from fromDate: Date,
                           until toDate: Date,
                           repeatOption: RepeatOption,
                           allowedWeekDays: Weekdays)
    -> Int {
        var repeatCount: Int = 0
        
        if repeatOption == .never
            || allowedWeekDays == SOXDateFormatter.Weekdays.none
            || toDate.isBeforeDate(fromDate, orEqual: true, granularity: .day) {
            return repeatCount
        }
        
        let repeatOptionDateComponents = repeatOption.dateComponents // get delta of dates
        var nextDate = fromDate
        
        if repeatOption == .daily {
            while nextDate.isBeforeDate(toDate, granularity: .day)  {
                repeatCount += 1
                nextDate = Calendar.autoupdatingCurrent.date(byAdding: repeatOptionDateComponents, to: nextDate)!
                while allowedWeekDays.allows(nextDate) == false {
                    nextDate = Calendar.autoupdatingCurrent.date(byAdding: repeatOptionDateComponents, to: nextDate)!
                }
            }
            
        }
        else if repeatOption == .weekly || repeatOption == .biWeekly {
            while Calendar.autoupdatingCurrent.date(byAdding: repeatOptionDateComponents, to: nextDate)!
                    .isBeforeDate(toDate, orEqual: true, granularity: .day)  {
                repeatCount += 1
                nextDate = Calendar.autoupdatingCurrent.date(byAdding: repeatOptionDateComponents, to: nextDate)!
            }
        }
        else {
            while Calendar.autoupdatingCurrent.date(byAdding: repeatOptionDateComponents, to: nextDate)!
                    .isBeforeDate(toDate, orEqual: true, granularity: .day)  {
                nextDate = Calendar.autoupdatingCurrent.date(byAdding: repeatOptionDateComponents, to: nextDate)!
                repeatCount += 1
                
                let backup = nextDate
                while allowedWeekDays.allows(nextDate) == false {
                    nextDate = Calendar.autoupdatingCurrent.date(byAdding: .day, value: 1, to: nextDate)!
                }
                
                nextDate = backup
            }
        }
              
        return repeatCount
    }
    
}


//MARK: - Extension - Weekdays
extension SOXDateFormatter {
    
    struct Weekdays: OptionSet {
    
        let rawValue: Int32
        
        static let monday    = Weekdays(rawValue: 1 << 0)
        static let tuesday   = Weekdays(rawValue: 1 << 1)
        static let wednesday = Weekdays(rawValue: 1 << 2)
        static let thursday  = Weekdays(rawValue: 1 << 3)
        static let friday    = Weekdays(rawValue: 1 << 4)
        static let saturday  = Weekdays(rawValue: 1 << 5)
        static let sunday    = Weekdays(rawValue: 1 << 6)
        
        static let weekdays: Weekdays = [
            .monday, .tuesday, .wednesday, .thursday, .friday]
        static let weekend: Weekdays = [
            .saturday, .sunday]
        static let all: Weekdays = [
            .monday, .tuesday, .wednesday, .thursday, .friday,
            .saturday, .sunday]
        static let none: Weekdays = []
        
        //MARK: Convenient getters
        var containsWeekend: Bool {
            let containsWeekend = contains(.saturday) || contains(.sunday)
            return containsWeekend
        }
        
        var skipsWeekend: Bool  {
            let skipsWeekend = !containsWeekend
            return skipsWeekend
        }
        
        var forbiddenWeekdays: Weekdays {
            let forbiddenWeekdays = Weekdays.all.subtracting(self)
            return forbiddenWeekdays
        }
        
        
        //MARK: - Creation Methods
        static func forDate(_ date: Date)
        -> Weekdays {
            let foundation_weekDay = Calendar.autoupdatingCurrent.component(.weekday, from: date) // 1...7
            switch foundation_weekDay {
                case 2: return .monday
                case 3: return .tuesday
                case 4: return .wednesday
                case 5: return .thursday
                case 6: return .friday
                case 7: return .saturday
                case 1: return .sunday
                default: fatalError("Not defined.")
            }
        }
        
        
        
        static func skippedCount(from fromDate: Date,
                                 to toDate: Date,
                                 allowedWeekdays: Weekdays)
        -> Int {
            var skippedCount = 0
            
            let changedDateComponents = Calendar.autoupdatingCurrent.dateComponents([.weekOfYear, .day],
                                                                                    from: fromDate, to: toDate)
            if let days = changedDateComponents.day,
               days != 0 {
                let direction = days > 0 ? 1 : -1
                var date = fromDate
                for _ in 0..<abs(days) {
                    date = date.dateByAdding(direction, .day).date
                    if allowedWeekdays.forbidds(date) {
                        skippedCount = skippedCount + 1
                    }
                }
            }
            
            return skippedCount
        }
        
        
        //MARK: Localisation
        func localized()
        -> String {
            switch self {
                case .monday: return "Montag"
                case .tuesday: return "Dienstag"
                case .wednesday: return "Mittwoch"
                case .thursday: return "Donnerstag"
                case .friday: return "Freitag"
                case .saturday: return "Sonnabend"
                case .sunday: return "Sonntag"
                    
                case .weekdays: return "Wochentage"
                case .weekend: return "Wochenende"
                case .all: return "Alle Tage"
                default:
                    return "Einige Tage."
            }
        }
        
        
        func localizedShort()
        -> String {
            switch self {
                case .monday: return "Mo"
                case .tuesday: return "Di"
                case .wednesday: return "Mi"
                case .thursday: return "Do"
                case .friday: return "Fr"
                case .saturday: return "Sa"
                case .sunday: return "So"
                    
                case .weekdays: return "Mo-Fr"
                case .weekend: return "Sa/So"
                case .all: return "Alle"
                default:
                    return "Einige Tage."
            }
        }
        

        //MARK: Check Methods
        func allows(_ date: Date)
        -> Bool {
            let weekDay = SOXDateFormatter.Weekdays.forDate(date)
            let allows = contains(weekDay)
            return allows
        }
    
        
        func forbidds(_ date: Date)
        -> Bool {
            let forbidd = !allows(date)
            return forbidd
        }
        
        
       //MARK: Manipulating Methods
        mutating func allowWeekday(_ weekday: Weekdays) {
            update(with: weekday)
        }
        
        mutating func forbidWeekday(_ weekday: Weekdays) {
            subtract(weekday)
        }
        
        
        mutating func allowWeekend() {
            update(with: Weekdays.weekend)
        }
        
        mutating func forbidWeekend() {
            subtract(Weekdays.weekend)
        }
        
        
        func weekday(forDate date: Date)
        -> Weekdays {
            let weekday = Weekdays.forDate(date)
            return weekday
        }
        
        var sortOrder: Int {
            switch self {
                case .monday:
                    return 0
                case .tuesday:
                    return 1
                case .wednesday:
                    return 2
                case .thursday:
                    return 3
                case .friday:
                    return 4
                case .saturday:
                    return 5
                case .sunday:
                    return 6
                default:
                    fatalError()
            }
        }
    }
    
    

}


//MARK: -
//MARK: - ENUM - RepeatOption
enum RepeatOption: String, CaseIterable {
    
    //MARK: Cases
    case never = "Niemals"
    case daily = "Täglich"
    case weekly = "Wöchentlich"
    case biWeekly = "Alle 14 Tage"
    case monthly = "Monatlich"
    case quarterly = "Quartalsweise"
    case yearly = "Jährlich"
    
    
    //MARK: Computed properties
    var dateComponents: DateComponents {
        let value = self.stepWidth
        let calendarComponent = self.calendarComponent
        
        var dateComponents = DateComponents()
        dateComponents.setValue(value, for: calendarComponent)
        return dateComponents
    }
    
    
    var stepWidth: Int {
        switch self {
            case .never:
                return 0
            case .daily:
                return 1
            case .weekly:
                return 1
            case .biWeekly:
                return 2
            case .monthly:
                return 1
            case .quarterly:
                return 3
            case .yearly:
                return 1
        }
    }
    
   
    var calendarComponent: Calendar.Component {
        switch self {
            case .never:
                return Calendar.Component.calendar
            case .daily:
                return .day
            case .weekly:
                return .weekOfMonth
            case .biWeekly:
                return .weekOfMonth
            case .monthly:
                return .month
            case .quarterly:
                return .month
            case .yearly:
                return .year
        }
    }
    
    
    
    // MARK: - Private Methods
    private var sortOrder: Int {
        switch self {
            case .never:
                return 0
            case .daily:
                return 10
            case .weekly:
                return 20
            case .biWeekly:
                return 30
            case .monthly:
                return 40
            case .quarterly:
                return 50
            case .yearly:
                return 60
        }
    }
    
    
    //MARK: - Compare Overrides
    static func ==(lhs: RepeatOption, rhs: RepeatOption)
    -> Bool {
        return lhs.sortOrder == rhs.sortOrder
    }
    
    static func !=(lhs: RepeatOption, rhs: RepeatOption)
    -> Bool {
        return lhs.sortOrder != rhs.sortOrder
    }
    
    static func <(lhs: RepeatOption, rhs: RepeatOption)
    -> Bool {
        return lhs.sortOrder < rhs.sortOrder
    }
    
    static func >(lhs: RepeatOption, rhs: RepeatOption)
    -> Bool {
        return lhs.sortOrder > rhs.sortOrder
    }

}
