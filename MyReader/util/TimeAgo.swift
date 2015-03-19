//
//  TimeAgo.swift
//  WeTalk
//
//  Created by GoldRatio on 12/2/14.
//  Copyright (c) 2014 GoldRatio. All rights reserved.
//

import Foundation

extension NSDate
{
    func detailDateTimeUntilNow() -> String {
        var now = NSDate()
        let calendar = NSCalendar.currentCalendar()
        let zone = NSTimeZone.systemTimeZone()
        let interval = zone.secondsFromGMTForDate(now)
        now = now.dateByAddingTimeInterval(NSTimeInterval(interval))
        let startDay = calendar.ordinalityOfUnit(NSCalendarUnit.CalendarUnitDay, inUnit:NSCalendarUnit.CalendarUnitEra, forDate: self)
        let endDay = calendar.ordinalityOfUnit(NSCalendarUnit.CalendarUnitDay, inUnit:NSCalendarUnit.CalendarUnitEra, forDate: now)
        
        
        var format:String? = nil;
        
        let diffDays = endDay - startDay
        if (diffDays == 0) {
            let hourComponent = calendar.components(NSCalendarUnit.CalendarUnitHour, fromDate:self)
            if (hourComponent.hour < 12) {
                format = "上午HH:mm"
            }
            else if (hourComponent.hour >= 12 ) {
                format = "下午 HH:mm"
            }
        }
        else if (diffDays == 1) {
            format = "昨天 HH:mm"
        }
        else if (diffDays <= 7) {
            format = "EEE HH:mm"
        }
        else {
            format = "MM-dd HH:MI"
        }
        
        let dateFormat = NSDateFormatter()
        dateFormat.timeZone = NSTimeZone(name: "GMT+8")
        dateFormat.dateFormat = format
        return dateFormat.stringFromDate(self)
    }
}