//
//  Extensions.swift
//  Countr
//
//  Created by Lukas Kollmer on 1/30/15.
//  Copyright (c) 2015 Lukas Kollmer. All rights reserved.
//

import Foundation
import UIKit

let ui_action_key = "ui_action"
let select_collection_view_cell_key = "select_collection_view_cell"
let button_press_key = "button_press"
let add_new_item_button_key = "add_new_item_button"
let cancel_button_key = "cancel_button"
let done_button_key = "done_button"
let show_website_key = "show_website"
let write_email_key = "write_email"
let delete_all_data_button_key = "delete_all_date_button"

let countdown_manager_key = "countdown_manager"
let did_add_new_item_key = "did_add_new_item"
let did_delete_item_key = "did_delete_item"


public func nameOfClass(_class: AnyObject) -> String {
    return _stdlib_getDemangledTypeName(_class)
}

extension LKCountdownItem {
    var itemKind: String {
        get {
            return ""
        }
    }
}


extension UIApplication {
    var version: String {
        get {
            return NSBundle.mainBundle().infoDictionary?["CFBundleShortVersionString"] as String
        }
    }
}

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

    var dayInYear: Int {
        get {
            return NSCalendar.currentCalendar().ordinalityOfUnit(NSCalendarUnit.DayCalendarUnit, inUnit: NSCalendarUnit.YearCalendarUnit, forDate: self)
        }
    }

    var year: Int {
        get {
            return self.dateComponents.year

        }
    }
    var month: Int {
        get {
            return self.dateComponents.month
        }
    }
    var day: Int {
        get {
            return self.dateComponents.day
        }
    }




    private var dateComponents: NSDateComponents {
        get {
            let calendar = NSCalendar(calendarIdentifier: NSGregorianCalendar)
            let calendarUnits: NSCalendarUnit = (.YearCalendarUnit | .MonthCalendarUnit | .DayCalendarUnit | .HourCalendarUnit | .MinuteCalendarUnit | .SecondCalendarUnit)


            let dateComponents = calendar?.components( calendarUnits, fromDate: self)

            return dateComponents!
        }
    }

}