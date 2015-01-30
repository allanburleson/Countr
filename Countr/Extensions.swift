//
//  Extensions.swift
//  Countr
//
//  Created by Lukas Kollmer on 1/30/15.
//  Copyright (c) 2015 Lukas Kollmer. All rights reserved.
//

import Foundation
import UIKit

extension UIDevice {
    var is12HourFormat: Bool { // This shit works
        get {
            let formatStringForHours: NSString = NSDateFormatter.dateFormatFromTemplate("j", options: 0, locale: NSLocale.currentLocale())!
            let formatStringForHoursAsNSString: NSString = NSString(string: formatStringForHours)
            let containsA: NSRange = formatStringForHoursAsNSString.rangeOfString("a")
            let has12HourFormat = containsA.location != NSNotFound
            return has12HourFormat
        }
    }
}



extension NSDate {
    var descriptiveStringForDatePicker: String {
        get {
            var fullDateString :String
            var dayString: String
            var monthString: String
            var dayNumberString: String
            let formatter = NSDateFormatter()
            
            
            formatter.dateFormat = "EE" // "Fri"
            dayString = formatter.stringFromDate(self)
            
            formatter.dateFormat = "MMM" // "Jan"
            monthString = formatter.stringFromDate(self)
            
            formatter.dateFormat = "d"
            dayNumberString = formatter.stringFromDate(self)
            
            fullDateString = "\(dayString) \(monthString) \(dayNumberString)"
            return fullDateString
        }
    }
}