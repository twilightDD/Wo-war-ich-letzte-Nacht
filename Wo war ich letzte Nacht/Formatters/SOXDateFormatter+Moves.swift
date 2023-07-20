//
//  SOXDateFormatter+Moves.swift
//  Landrix Handwerk Mobile
//
//  Created by Peter Hauke on 02.03.21.
//  Copyright © 2021 Landrix Software GmbH & Co. KG. All rights reserved.
//

import Foundation


//MARK: - Extension - Move Dates
extension Date {
    
    //MARK: - Public Class Methods
    /// Returns the `count` of skipped days while iteration from weekday of `fromDate` to weekday of `toDate`.
    /// Result is always positive.
    static func skippedDays(from fromDate: Date,
                            to toDate: Date,
                            allowedWeekdays: SOXDateFormatter.Weekdays)
    -> Int {
        var skippedDays = 0
        
        let changedDateComponents = Calendar.autoupdatingCurrent.dateComponents([.weekOfYear, .day],
                                                                                from: fromDate, to: toDate)
        // Ignore weeks; its not needed to count skipping days.
        if let days = changedDateComponents.day,
           days != 0 {
            let direction = days > 0 ? 1 : -1 // Future or Past
            var date = fromDate
            for _ in 0..<abs(days) {
                date = date.dateByAdding(direction, .day).date
                if allowedWeekdays.forbidds(date) {
                    skippedDays += 1
                }
            }
        }
        
        return skippedDays
    }
    
    
    //MARK: - Public Instance Methods
    /// Difference DateCompontens should contain [.weekOfYear, .day, .hour, .minute, .second]
    func moveBy(difference dateComponents: DateComponents,
                skippedDays: Int,
                allowedWeekdays: SOXDateFormatter.Weekdays)
    -> Date {
        var movedDate = self
        
        // Weeks
        movedDate = movedDate.dateByAdding(dateComponents.weekOfYear ?? 0, .weekOfYear).date
        
        // Days
        if let days = dateComponents.day,
           days != 0 {
            let direction = days > 0 ? 1 : -1 // Future or Past
            var movements = abs(days) - skippedDays
            while movements > 0 {
                movedDate = movedDate.dateByAdding(direction, .day).date
                while allowedWeekdays.forbidds(movedDate) {
                    movedDate = movedDate.dateByAdding(direction, .day).date
                }
                movements -= 1
            }
        }
        
        // Time
        movedDate = movedDate.dateByAdding(dateComponents.hour ?? 0, .hour).date
        movedDate = movedDate.dateByAdding(dateComponents.minute ?? 0, .minute).date
        movedDate = movedDate.dateByAdding(dateComponents.second ?? 0, .second).date
        while allowedWeekdays.forbidds(movedDate) {
            movedDate = movedDate.dateByAdding(1, .day).date // TODO: todo: correct direction
        }
        
        return movedDate
    }
    
}
