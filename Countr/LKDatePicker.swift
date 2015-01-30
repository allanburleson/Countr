//
//  LKDatePicker.swift
//  Countr
//
//  Created by Lukas Kollmer on 1/28/15.
//  Copyright (c) 2015 Lukas Kollmer. All rights reserved.
//

import UIKit


typealias LKDatePickerMode = UIDatePickerMode

class LKDatePicker: UIPickerView, UIPickerViewDataSource, UIPickerViewDelegate {

    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
    }
    */
    
    
    var pickerMode: LKDatePickerMode = .Date {
        didSet {
            self.reloadAllComponents()
            self.setSelectedRows()
        }
    }
    
    var date: NSDate {
        get {
            let dateComponents = NSDateComponents()
            dateComponents.day = self.selectedRowInComponent(1)+1
            dateComponents.month = self.selectedRowInComponent(0)+1
            dateComponents.year = self.selectedRowInComponent(2)
            dateComponents.hour = 0
            dateComponents.minute = 0
            dateComponents.second = 0
            dateComponents.nanosecond = 0
            println("date delivered to addVC: year: \(dateComponents.year) month: \(dateComponents.month) day: \(dateComponents.day)hour:  \(dateComponents.hour) minute: \(dateComponents.minute) second: \(dateComponents.second) ")
            println("current cal: \(NSCalendar.currentCalendar().timeZone.description)")
            return NSCalendar.currentCalendar().dateFromComponents(dateComponents)!
        }
        set {
            // TODO: Set the components automatically to the right rows, based on the date set
        }
    }
    
    private let pickerData = LKPickerData()
    override init() {
        super.init()
        
        commonInit()
    }

    required init(coder aDecoder: NSCoder) {
        //fatalError("init(coder:) has not been implemented")
        super.init(coder: aDecoder)
        
        commonInit()
    }

    func commonInit() {
        self.delegate = self
        self.dataSource = self
        
        setSelectedRows()
        
    }
    
    
    func setSelectedRows() {
        let dateComponents = NSCalendar.currentCalendar().components(NSCalendarUnit.CalendarUnitDay|NSCalendarUnit.CalendarUnitMonth|NSCalendarUnit.CalendarUnitYear|NSCalendarUnit.CalendarUnitHour|NSCalendarUnit.CalendarUnitMinute, fromDate: NSDate())
        
        if UIDevice.currentDevice().is12HourFormat && dateComponents.hour > 12 {
            dateComponents.hour -= 12 //T His code works fine
        }
        
        switch self.pickerMode {
        case .Date:
            self.selectRow(dateComponents.month-1, inComponent: 0, animated: false)
            self.selectRow(dateComponents.day-1, inComponent: 1, animated: false)
            self.selectRow(dateComponents.year, inComponent: 2, animated: false)
        case .DateAndTime:
            self.selectRow(500, inComponent: 0, animated: false)
            self.selectRow(dateComponents.hour-1, inComponent: 1, animated: false)
            self.selectRow(dateComponents.minute-1, inComponent: 2, animated: false)
            println("hour: \(dateComponents.hour)")
        default:
            break
        }

    }
    
    
    // MARK: UIPickerView DataSource & Delegate
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return self.pickerData.componentWithForMode(self.pickerMode).count // The numner of componentWidth information varies
    }
    
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        switch self.pickerMode {
        case .Date:
            switch component {
            case 0:
                return 12 // Month
            case 1:
                return 31 // Day
            case 2:
                return 3000 //Year
            default:
                return 0
            }
        case .DateAndTime:
            switch component {
            case 0:
                return 1001 // These are the days, the the following format: "[Mon] [Jan] [22]" // 1001 because 500 ((1000-1) /2) rows exist above and below the "Today" row
            case 1: // the hours
                if UIDevice.currentDevice().is12HourFormat {
                    return 12
                } else {
                    return 24
                }
            case 2:
                return 60 // The Minutes
            case 3:
                return 2 // AM/PM // TODO: ONLY on 12hr format devices (Check: UIDevice.currentDevice().is12HourFormat)
            default:
                return 0
            }
        default:
            return 0
        }
    }
    
    func pickerView(pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusingView view: UIView!) -> UIView {
        let label = UILabel()
        label.textColor = UIColor.whiteColor()
        label.textAlignment = .Center
        
        switch self.pickerMode {
        case .Date:
            switch component {
            case 0: // Months
                label.text = self.pickerData.months[row]
            case 1: // Dasy
                label.text = self.pickerData.days[row]
            case 2: //Years
                label.text = "\(String(row))"
            default:
                label.text = nil
            }
        case .DateAndTime:
            switch component {
            case 0:
                label.text = self.pickerData.descriptiveDates[row]
            case 1:
                label.text = self.pickerData.hours[row] // as the number of rows is automatically set to 24 if the device is using 24hr format, there is nothing special to do //TODO: Implement this
            case 2:
                label.text = self.pickerData.minutes[row]
            case 3:
                label.text = self.pickerData.amPm[row]
            default:
                break
            }
        default:
            break
        }
        
        return label
    }
    
    func pickerView(pickerView: UIPickerView, widthForComponent component: Int) -> CGFloat {
        return self.pickerData.componentWithForMode(self.pickerMode)[component]
    }
}


struct LKPickerData {
    let months = ["January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"]


    let days: [String] = {
        var _days: [String] = []
        for index in 1...31 {
            _days.append("\(index)")
        }

        return _days
    }()

    
    let hours: [String] = {
       var _hours: [String] = []
        for index in 1...24 {
            _hours.append("\(index)")
        }

        return _hours
    }()

    
    let minutes: [String] = {
        var _minutes: [String] = []
        for index in 1...60 {
            _minutes.append("\(index)")
        }
        
        return _minutes
    }()

    
    let amPm = ["AM", "PM"]
    
    let descriptiveDates: [String] = {
        var _descriptiveDates: [String] = []
        let _date = NSDate() // As creating the dates in the dateByAddingUnit function would either take a lot if time each time teh functions is loaded (>1000 x) it is created once and accessed over and over. Also, re-creating it over and over would produce a slightld different date each time
        let _calendar = NSCalendar.currentCalendar()
        
        for index in 1...10 {
            println("in loop #\(index)")
            let _date: NSDate = _calendar.dateByAddingUnit(.CalendarUnitDay, value: -index, toDate: _date, options: nil)!
            println("date: \(_date)")
            let _descriptiveDate = _date.descriptiveStringForDatePicker
            println("_descriptiveDate: \(_descriptiveDate)")
            _descriptiveDates.append(_descriptiveDate)
        }
        
        return _descriptiveDates
    }()
    
    private let dateComponentWidth: [CGFloat] = [150, 75, 75]
    private let dateAndTimeComponentWidth: [CGFloat] = [120, 60, 60, 60]
    
    func componentWithForMode(mode: LKDatePickerMode) -> [CGFloat] {
        switch mode {
        case .Date:
            return dateComponentWidth
        case .DateAndTime:
            return dateAndTimeComponentWidth
        default:
            return []
        }
    }
    
    
}
