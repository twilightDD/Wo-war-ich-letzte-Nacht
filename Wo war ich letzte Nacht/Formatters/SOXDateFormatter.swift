//
//  SOXDateFormatter.swift
//  Landrix Handwerk Mobile
//
//  Created by Peter Hauke on 30.09.19.
//  Copyright © 2019 Landrix Software GmbH & Co. KG. All rights reserved.
//

import Foundation

//import SwiftDate

class SOXDateFormatter {
    
    //MARK: - Lets and Vars
    private static let shared = SOXDateFormatter ()
    
    /// Date with "1899-12-30T00:00:00.000+00:00"
    static var defaultPascalDate: Date {
        let defaultPascalDate = Date.init(timeIntervalSinceReferenceDate: -3187468800.0)
        return defaultPascalDate
    }
    
    
    //MARK: - 
    //MARK: - Dateformatters
    /// `dateStyle = .none | .timeStyle = .medium`
    lazy var hourMinutesSecondsFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale.current
        dateFormatter.dateStyle = .none
        dateFormatter.timeStyle = .medium
        
        return dateFormatter
    }()
    
    
    /// `dateStyle = .none | .timeStyle = .short`
    lazy var hourMinutesFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale.current
        dateFormatter.dateStyle = .none
        dateFormatter.timeStyle = .short
        
        return dateFormatter
    }()
    
    
    /// `dateStyle = .short | .timeStyle = .short`
    lazy var dayMonthYearHourMinutesFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale.current
        dateFormatter.dateStyle = .short
        dateFormatter.timeStyle = .short
        
        return dateFormatter
    }()
    
    /// `dateStyle = .short | .timeStyle = .none`
    lazy var dayMonthYearFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale.current
        dateFormatter.dateStyle = .short
        dateFormatter.timeStyle = .none
        
        return dateFormatter
    }()
    
    /// `dateFormat = "yyyy-MM-dd_HH-mm-ss"`
    lazy var yearMonthDayHourMinutesSecondsFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale.current
        dateFormatter.dateFormat = "yyyy-MM-dd_HH-mm-ss"
        return dateFormatter
    }()
    
    /// `dateFormat = "yyyy-MM-dd HH-mm-ss"`
    ///
    /// - Warning: timeZone = TimeZone(secondsFromGMT: 0)
    lazy var yearMonthDayHourMinutesSecondsFormatterWithoutDelimiter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = TimeZone(secondsFromGMT: 0)
        dateFormatter.dateFormat = "yyyy-MM-dd HH-mm-ss"
        return dateFormatter
    }()
    
    /// `dateFormat = "MMMM yyyy"`
    lazy var monthYearFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale.current
        dateFormatter.dateFormat = "MMMM yyyy"
        return dateFormatter
    }()
    
    /// `dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"`
    lazy var dateFromRFCFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale.autoupdatingCurrent
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        return dateFormatter
    }()
    
    /// `dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZZZZZ"`
    ///
    /// `timeZone = TimeZone.init(secondsFromGMT: 0)`
    ///
    ///  Result will contain Z
    lazy var dateFromRFCZFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale.autoupdatingCurrent
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZZZZZ"
        dateFormatter.timeZone = TimeZone.init(secondsFromGMT: 0) // Result will contain Z
        return dateFormatter
    }()

    
    //MARK: - DateComponentsFormatter
    private static var dateComponentsFormatter: DateComponentsFormatter = {
        let formatter = DateComponentsFormatter()
        formatter.unitsStyle = .full
        formatter.includesApproximationPhrase = false
        formatter.includesTimeRemainingPhrase = false
        formatter.zeroFormattingBehavior = .pad
        formatter.unitsStyle = .positional
//        formatter.allowsFractionalUnits = true
//        formatter.collapsesLargestUnit = true
        
        return formatter
    }()
    
    
    static func dateComponentsFormatter(withComponents components: [Calendar.Component] = [.hour, .minute, .second])
    -> DateComponentsFormatter {
        let formatter = dateComponentsFormatter
        
        var calendarUnits: NSCalendar.Unit = .init()
        components.forEach( { component in
            switch component {
                case .year:
                    calendarUnits.update(with: .year)
                case .month:
                    calendarUnits.update(with: .month)
                case .weekOfMonth:
                    calendarUnits.update(with: .weekOfMonth)
                case .day:
                    calendarUnits.update(with: .day)
                case .hour:
                    calendarUnits.update(with: .hour)
                case .minute:
                    calendarUnits.update(with: .minute)
                case .second:
                    calendarUnits.update(with: .second)
                default:
                    return
            }
        })
        
        formatter.allowedUnits = calendarUnits
        return formatter
    }
    
    
    //MARK: -
    //MARK: - Public Class Convenient Methods
    /// `dateStyle = .none | .timeStyle = .medium`
    class func currentHourMinutesSecondsString()
    -> String {
        let currentHourMinutesSeconds = shared.hourMinutesSecondsFormatter.string(from: Date())
        
        return currentHourMinutesSeconds
    }
    
    /// `dateFormat = "yyyy-MM-dd_HH-mm-ss"`
    class func currentYearMonthDayHourMinutesSecondsString()
    -> String {
        let currentYearMonthDayHourMinutesSeconds = shared.yearMonthDayHourMinutesSecondsFormatter.string(from: Date())
        return currentYearMonthDayHourMinutesSeconds
    }
    
    /// `dateFormat = "yyyy-MM-dd HH-mm-ss"`
    ///
    /// - Warning: timeZone = TimeZone(secondsFromGMT: 0)
    class func currentYearMonthDayHourMinutesSecondsWithoutDelimiterStringFor(date: Date)
    -> String {
        let yearMonthDayHourMinutesSecondsString = shared.yearMonthDayHourMinutesSecondsFormatterWithoutDelimiter.string(from: date)
        return yearMonthDayHourMinutesSecondsString
    }
    
    /// Default: `dateStyle = .short | .timeStyle = .none`
    class func dayMonthYearStringFor(date: Date, dateStyle:  DateFormatter.Style = .short)
    -> String {
        let formatter = shared.dayMonthYearFormatter
        formatter.dateStyle = dateStyle
        let dayMonthYear = formatter.string(from: date)
        return dayMonthYear
    }
    
    /// MMM/yyy
    class func monthYearStringFor(date: Date)
    -> String {
        let formatter = shared.monthYearFormatter
        let dayMonthYear = formatter.string(from: date)
        return dayMonthYear
    }
    
    /// dateStyle = .short | .timeStyle = .short`
    ///
    /// `relativeDate = true` returns "today" or "yesterday".
    class func dayMonthYearHourMinutesStringFor(date: Date, relativeDate: Bool = false)
    -> String {
        let formatter = shared.dayMonthYearHourMinutesFormatter
        formatter.doesRelativeDateFormatting = relativeDate
        let dayMonthYearHourMinutes = formatter.string(from: date)
        return dayMonthYearHourMinutes
    }
    
    // .timeStyle = .short
    class func hourMinutesStringFor(date: Date)
    -> String {
        let formatter = shared.hourMinutesFormatter
        let hourMinutes = formatter.string(from: date)
        return hourMinutes
    }
    
    
    class func stringFor(timeIntervall: TimeInterval,
                         withComponents components: [Calendar.Component])
    -> String {
        let dateComponentsFormatter = dateComponentsFormatter(withComponents: components)
        let durationString = dateComponentsFormatter.string(from: timeIntervall)
        return durationString ?? "-"
    }
    
}


//MARK: - Extension - Rounded Dates Factory
extension SOXDateFormatter {
    
    class func roundToDateNearestOrAwayFromZero(precision: TimeInterval)
    -> Date {
        return round(precision: precision, rule: .toNearestOrAwayFromZero)
    }
    
    class func roundUp(date: Date, precision: TimeInterval)
    -> Date {
        return round(date: date, precision: precision, rule: .up)
    }
    
    class func roundToDateUp(precision: TimeInterval)
    -> Date {
        return round(precision: precision, rule: .up)
    }
    
    class func roundToDateDown(precision: TimeInterval)
    -> Date {
        return round(precision: precision, rule: .down)
    }
    
    private class func round(precision: TimeInterval, rule: FloatingPointRoundingRule)
    -> Date {
        let seconds = (Date.timeIntervalSinceReferenceDate / precision).rounded(rule) *  precision
        
        let roundedDate = Date(timeIntervalSinceReferenceDate: seconds)
        return roundedDate
    }
    
    private class func round(date: Date, precision: TimeInterval, rule: FloatingPointRoundingRule)
    -> Date {
        let seconds = (date.timeIntervalSinceReferenceDate / precision).rounded(rule) *  precision
        
        let roundedDate = Date(timeIntervalSinceReferenceDate: seconds)
        return roundedDate
    }
    
}


//MARK: - Extension - Day Math
extension SOXDateFormatter {
    class func isDateInToday(_ date: Date)
    -> Bool {
        let isDateInToday = Calendar.current.isDateInToday(date)
        return isDateInToday
    }
    
    
    class func startOfToday()
    -> Date {
        let startOfToday = startOfDay(date: Date())
        return startOfToday
    }
    
    
    class func startOfDay(date: Date)
    -> Date {
        let startOfDay = Calendar.autoupdatingCurrent.startOfDay(for: date)
        return startOfDay
    }
    
    
    class func endOfToday()
    -> Date {
        let endOfToday = endOfDay(date: Date())
        return endOfToday
    }
    
    
    class func endOfDay(date: Date)
    -> Date {
        
        var components = DateComponents()
        components.day = 1
        components.second = -1
        let startOfDate = startOfDay(date: date)
        
        guard let endOfDate = Calendar.autoupdatingCurrent.date(byAdding: components,
                                                                to: startOfDate) else {
            fatalError() }
        return endOfDate
    }
    
    
    static func isDate(date: Date, inRangeOfDates dates: [Date])
    -> Bool? {
        let sortedDates = dates.sorted()
        guard let firstDate = sortedDates.first,
              let lastDate = sortedDates.last else {
                  return nil }
        
        let dayBefore = firstDate.dateByAdding(-1, .day)
        let dayAfter = lastDate.dateByAdding(1, .day)
        let isInRange = date.isInRange(date: dayBefore.date,
                                       and: dayAfter.date,
                                       orEqual: true,
                                       granularity: .day)
        
        return isInRange
    }
    
}


//MARK: - Extension - First/Last Day of Month
extension SOXDateFormatter {
    
    static func dateComponents(of date: Date)
    -> DateComponents {
        let dateComponents = Calendar.autoupdatingCurrent.dateComponents([.year, .month, .day, .hour, .minute, .second],
                                                                         from: date)
        return dateComponents
    }
    
    
    static func dateComponentsYMD(of date: Date)
    -> DateComponents {
        let dateComponents = Calendar.autoupdatingCurrent.dateComponents([.year, .month, .day],
                                                                         from: date)
        return dateComponents
    }
    
    
    static func dateComponentsHourMinuteSecond(of date: Date)
    -> DateComponents {
        let dateComponents = Calendar.autoupdatingCurrent.dateComponents([.hour, .minute, .second],
                                                                         from: date)
        return dateComponents
    }
    
    static func dateComponentsDifferences(referenceDate: Date, compareDate: Date)
    -> DateComponents {
        let referenceDateComponents = Calendar.autoupdatingCurrent.dateComponents([.year, .month, .day, .hour, .minute, .second],
                                                                                  from: referenceDate)
        let compareDateComponents = Calendar.autoupdatingCurrent.dateComponents([.year, .month, .day, .hour, .minute, .second],
                                                                                from: compareDate)
        var dateComponentsDifferences = DateComponents()
        dateComponentsDifferences.year = referenceDateComponents.year! - compareDateComponents.year!
        dateComponentsDifferences.month = referenceDateComponents.month! - compareDateComponents.month!
        dateComponentsDifferences.day = referenceDateComponents.day! - compareDateComponents.day!
        dateComponentsDifferences.hour = referenceDateComponents.hour! - compareDateComponents.hour!
        dateComponentsDifferences.minute = referenceDateComponents.minute! - compareDateComponents.minute!
        dateComponentsDifferences.second = referenceDateComponents.second! - compareDateComponents.second!
        
        // debug:
        print("referenceDateComponents: \(referenceDateComponents)")
        print("compareDateComponents: \(compareDateComponents)")
        print("dateComponentsDifferences: \(dateComponentsDifferences)")
        return dateComponentsDifferences
    }
    
    
    static func firstDayOfMonth(for date: Date)
    -> Date? {
        var components = dateComponentsYMD(of: date)
        components.day = 1
        let firstDayOfMonth = Calendar.autoupdatingCurrent.date(from: components)
        return firstDayOfMonth
    }
    
    static func lastDayOfMonth(for date: Date)
    -> Date? {
        var components = dateComponentsYMD(of: date)
        components.month! += 1
        components.day = 0
        let lastDayOfMonth = Calendar.autoupdatingCurrent.date(from: components)
        return lastDayOfMonth
    }
    
    
    /// Result has same time information as given date.
    static func firstDayOfWeek(for date: Date)
    -> Date {
        let weekDayOfDate = date.weekday
        let weekDayDiff = 1 - weekDayOfDate
        let componentsDiff = DateComponents.init(calendar: Calendar.autoupdatingCurrent,
                                                 day: weekDayDiff)
        
        guard let firstDayOfWeek = Calendar.autoupdatingCurrent.date(byAdding: componentsDiff,
                                                                     to: date) else {
            fatalError() }
        
        return firstDayOfWeek
    }
    
    
    /// Result has same time information as given date.
    static func lastDayOfWeek(for date: Date)
    -> Date {
        let weekDayOfDate = date.weekday
        let weekDayDiff = 7 - weekDayOfDate
        let componentsDiff = DateComponents.init(calendar: Calendar.autoupdatingCurrent,
                                                 day: weekDayDiff)
        
        guard let lastDayOfWeek = Calendar.autoupdatingCurrent.date(byAdding: componentsDiff,
                                                                    to: date) else {
            fatalError() }
        
        return lastDayOfWeek
    }
    
    /*
     static func weeksOfMonth(for date: Date)
     -> Int {
     let firstOfMonth = firstDayOfMonth(for: date)!
     let lastOfMonth = lastDayOfMonth(for: date)!
     
     let weekOfFirstOfMonth = Calendar.autoupdatingCurrent.component(.weekOfYear, from: firstOfMonth)
     let weekOfLastOfMonth = Calendar.autoupdatingCurrent.component(.weekOfYear, from: lastOfMonth)
     let weeksOfMonth = weekOfLastOfMonth - weekOfFirstOfMonth
     
     return weeksOfMonth
     }
     */
    
}


//MARK: - Extension - String-Date Conversions
extension SOXDateFormatter {
    
    /// Creates a date from given date string.
    /// - Parameter string: Date string "yyyy-MM-dd'T'HH:mm:ss.SSSZ" or "yyyy-MM-dd'T'HH:mm:ssZ"
    /// - Parameter pascalDateIfFailure: if string could not be interpreted as valid date, return default pascal date instead.
    class func dateFromRFC(string: String?,
                           pascalDateIfFailure: Bool? = false)
    -> Date? {
        if let string = string,
           let dateFromRFC = shared.dateFromRFCFormatter.date(from: string) {
            return dateFromRFC
        }
        
        if pascalDateIfFailure == true {
            return SOXDateFormatter.defaultPascalDate
        }
        
        return nil
    }
    
    
    /// Creates a `rfc string` from given `date`.
    ///
    /// - Example result: 2021-01-27T20:37:34.550+0100
    ///
    /// - See also: `class func **rfcZ**DateStringFromDate()
    ///
    /// - Parameter date: The date.
    /// - Returns: The string or `nil` if `date` is insufficient or `nil`.
    class func rfcDateStringFromDate(_ date: Date?)
    -> String? {
        guard let date = date else {
            return nil }
        
        let rfcDateString: String? = shared.dateFromRFCFormatter.string(from: date)
        return rfcDateString
    }
    
    
    /// Creates a `rfc string` from given `date`.
    ///
    /// - Example result: 2021-01-17T17:31:06.945Z
    ///
    /// - See also: `class func **rfc**DateStringFromDate()
    ///
    /// - Parameter date: The date.
    /// - Returns: The string or `nil` if `date` is insufficient or `nil`.
    class func rfcZDateStringFromDate(_ date: Date?)
    -> String? {
        guard let date = date else {
            return nil }
        
        let rfcDateString = shared.dateFromRFCZFormatter.string(from: date)
        return rfcDateString
    }
    
    
    class func weekdayWithDateString(forDate date: Date)
    -> String {
        let weekday = SOXDateFormatter.Weekdays.forDate(date)
        let weekdayString = weekday.localizedShort()
        let dateString = SOXDateFormatter.dayMonthYearStringFor(date: date)
        let weekdayWithDateString = "\(weekdayString) - \(dateString)"
        return weekdayWithDateString
    }
    
    
    class func weekdayWithDateAndTimeString(forDate date: Date)
    -> String {
        let weekday = SOXDateFormatter.Weekdays.forDate(date)
        let weekdayString = weekday.localizedShort()
        let dateAndTimeString = SOXDateFormatter.dayMonthYearHourMinutesStringFor(date: date)
        let weekdayWithDateAndTimeString = "\(weekdayString) \(dateAndTimeString)"
        return weekdayWithDateAndTimeString
    }
    
}


//MARK: -
//MARK: - Extension - Date
extension Date {
    
    func startOfDay()
    -> Date {
        // let startOfDay = dateAtStartOf(.day) // uses Region is Region.UTC
  
        let selfInRegion = DateInRegion(self, region: Region.local)
        let startOfDay = selfInRegion.dateAtStartOf(.day).date
        return startOfDay
    }
    
    func endOfDay()
    -> Date {
        // let endOfDay = dateAtEndOf(.day) // uses Region is Region.UTC
        let selfInRegion = DateInRegion(self, region: Region.local)
        let endOfDay = selfInRegion.dateAtEndOf(.day).date
        return endOfDay
    }
    
    func weekday()
    -> SOXDateFormatter.Weekdays {
        let weekday = SOXDateFormatter.Weekdays.forDate(self)
        return weekday
    }
    
    
    /// positive if self is before compareDate and
    /// negative if self is after compareDate
    func weekdayDifference(to compareDate: Date)
    -> Int {
        // The weekday units of Foundation are the numbers 1-N (where for the Gregorian calendar N=7 and 1 is Sunday).
        // mo = 2, tu = 3, wed = 4, th = 5, fr = 6, sat = 7, sun = 1
        let selfWeekday = weekday
        let compareWeekday = compareDate.weekday
        var diff = compareWeekday - selfWeekday
        if  self.isAfterDate(compareDate, granularity: .day) {
            diff = diff * -1
        }
        
        return diff
    }
    
    
    func relativeDifference(in component: Calendar.Component, from other: Date)
    -> Int? {
        let dateComponents = calendar.dateComponents([component], from: self, to: other)
        let relativeDifference = dateComponents.value(for: component)
        return relativeDifference
    }
    
    
    
    /// Creates an updated date with **time components** from `self` and all other components from `dateSource`.
    ///
    /// Components taken from self: `[.hour, .minute, .second, .nanosecond]`
    ///
    /// - Warning: It seem that `.calendar` and `.timeZone` aren't transfered.
    /// - Parameter dateSource: The date which all other components are taken from.
    /// - Returns: The updated `date` or `nil`.
    func updateDate(dateSource: Date)
    -> Date? {
        let selfDateComponents = dateComponents
        let dateSourceComponents = dateSource.dateComponents
        
        var updatedDateComponents: [Calendar.Component : Int] = [:]
        DateComponents.allComponentsSet.forEach( { component in
            switch component {
                case .hour:
                    updatedDateComponents.updateValue(selfDateComponents.hour!, forKey: .hour)
                case .minute:
                    updatedDateComponents.updateValue(selfDateComponents.minute!, forKey: .minute)
                case .second:
                    updatedDateComponents.updateValue(selfDateComponents.second!, forKey: .second)
                case .nanosecond:
                    updatedDateComponents.updateValue(selfDateComponents.nanosecond!, forKey: .nanosecond)
                default:
                    guard let componentValue = dateSourceComponents[component] else {
//                        print("no value for \(component)")
                        return
                    }
                    updatedDateComponents.updateValue(componentValue, forKey: component)
            }
        })
      
        let updatedDate = Date().dateBySet(updatedDateComponents)
        return updatedDate
    }
    
    
    
    /// Creates a new `date` with given `values` for given `dateComponents`.
    /// - Parameter dateComponents: The `dateComponents` and `values`.
    /// - Returns: The new date.
    func updateDate(dateComponents: [Calendar.Component : Int])
    -> Date {
        guard let updatedDate = self.dateBySet(dateComponents) else {
            fatalError("\(#function) - \(dateComponents)") }
        return updatedDate
    }
    
    
    /// Sets `.second` and `.nanosecond` to 0
    /// - Returns: A new `date` object with seconds and nanoseconds 0.
    func zeroSeconds()
    -> Date {
        let newDate = updateDate(dateComponents: [.second : 0,
                                                  .nanosecond : 0])
        return newDate
    }
    
    
    /// Calculates time duration to given `otherDate`.
    ///
    /// `self` - `otherDate` = time duration
    ///
    /// - Parameters:
    ///   - components: Components for String result.
    ///   - otherDate: The other date.
    ///
    /// - Allowed components:
    ///
    /// - Returns: A duration string or "-" if something went wrong or no `components` where given.
//    func duration(in components: [Calendar.Component],
//                  from otherDate: Date)
//    -> String {
//        guard components.isNotEmpty else {
//            return "-"}
//        
//        let dateComponentsFormatter = SOXDateFormatter.dateComponentsFormatter(withComponents: components)
//        
//        // Get DateComponents
//        let dateComponents = calendar.dateComponents(Set.init(components),
//                                                     from: self, to: otherDate)
//        
//        // Create duration string
//        let durationString = dateComponentsFormatter.string(from: dateComponents)
//        return durationString ?? "-"
//    }
    
}
