//: Playground - noun: a place where people can play

import UIKit

// NSDate_descriptive String

let dateComponents = NSDateComponents()
dateComponents.year = 2015
dateComponents.month = 6
dateComponents.day = 8
dateComponents.hour = 19
dateComponents.minute = 0
dateComponents.second = 0

let date = NSCalendar.currentCalendar().dateFromComponents(dateComponents)

let descriptiveStringFull: String = NSDateFormatter.localizedStringFromDate(date!, dateStyle: NSDateFormatterStyle.FullStyle, timeStyle: NSDateFormatterStyle.FullStyle)

let descriptiveStringLong: String = NSDateFormatter.localizedStringFromDate(date!, dateStyle: NSDateFormatterStyle.LongStyle, timeStyle: NSDateFormatterStyle.LongStyle)

let descriptiveStringMedum: String = NSDateFormatter.localizedStringFromDate(date!, dateStyle: NSDateFormatterStyle.MediumStyle, timeStyle: NSDateFormatterStyle.MediumStyle)

let descriptiveStringShort: String = NSDateFormatter.localizedStringFromDate(date!, dateStyle: NSDateFormatterStyle.ShortStyle, timeStyle: NSDateFormatterStyle.ShortStyle)

let descriptiveStringNo: String = NSDateFormatter.localizedStringFromDate(date!, dateStyle: NSDateFormatterStyle.NoStyle, timeStyle: NSDateFormatterStyle.NoStyle)