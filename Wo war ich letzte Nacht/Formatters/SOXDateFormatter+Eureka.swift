//
//  SOXDateFormatter+Eureka.swift
//  Landrix Handwerk Mobile
//
//  Created by Peter Hauke on 23.02.21.
//  Copyright © 2021 Landrix Software GmbH & Co. KG. All rights reserved.
//

import Foundation


extension SOXDateFormatter.Weekdays {
    
    static func setup(with eurekaWeekDays: Set<EurekaWeekDay>)
    -> SOXDateFormatter.Weekdays {
        var weekdays = SOXDateFormatter.Weekdays()
        
        if eurekaWeekDays.contains(.monday) { weekdays.insert(.monday) }
        if eurekaWeekDays.contains(.tuesday) { weekdays.insert(.tuesday) }
        if eurekaWeekDays.contains(.wednesday) { weekdays.insert(.wednesday) }
        if eurekaWeekDays.contains(.thursday) { weekdays.insert(.thursday) }
        if eurekaWeekDays.contains(.friday) { weekdays.insert(.friday) }
        if eurekaWeekDays.contains(.saturday) { weekdays.insert(.saturday) }
        if eurekaWeekDays.contains(.sunday) { weekdays.insert(.sunday) }
        
        return weekdays
    }
    
    
    //MARK: - Eureka WeekDay
    enum EurekaWeekDay {
        case monday, tuesday, wednesday, thursday, friday, saturday, sunday
    }
    
    func eurekaWeekDays()
    -> Set<EurekaWeekDay> {
        var eurekaWeekDays: Set<EurekaWeekDay> = []
        
        if self.contains(.monday) { eurekaWeekDays.update(with: .monday) }
        if self.contains(.tuesday) { eurekaWeekDays.update(with: .tuesday) }
        if self.contains(.wednesday) { eurekaWeekDays.update(with: .wednesday) }
        if self.contains(.thursday) { eurekaWeekDays.update(with: .thursday) }
        if self.contains(.friday) { eurekaWeekDays.update(with: .friday) }
        if self.contains(.saturday) { eurekaWeekDays.update(with: .saturday) }
        if self.contains(.sunday) { eurekaWeekDays.update(with: .sunday) }
        
        return eurekaWeekDays
    }
    
}

