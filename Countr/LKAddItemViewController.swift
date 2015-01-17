//
//  LKAddItemViewController.swift
//  Countr
//
//  Created by Lukas Kollmer on 30/11/14.
//  Copyright (c) 2014 Lukas Kollmer. All rights reserved.
//

import Foundation
import UIKit

class LKAddItemViewController: UITableViewController {
    
    
    @IBOutlet weak var nameTextField: UITextField!
    
    @IBOutlet weak var countdownModeSegmentedControl: UISegmentedControl!
    
    @IBOutlet weak var datePicker: UIDatePicker!
    
    
    
    override func loadView() {
        super.loadView()
    }
    
    override func viewDidAppear(animated: Bool) {
        self.nameTextField.becomeFirstResponder()
    }
    
    @IBAction func countdownModeChanged(sender: UISegmentedControl) {
        switch self.countdownModeSegmentedControl.selectedSegmentIndex {
        case 0:
            // Mode Day
            self.datePicker.datePickerMode = UIDatePickerMode.Date
            break
        case 1:
            // Mode Day & Time
            self.datePicker.datePickerMode = UIDatePickerMode.DateAndTime
            break
        case 2:
            // Mode Countdown
            self.datePicker.datePickerMode = UIDatePickerMode.CountDownTimer
            break
        default:
            break
        }
    }
    
    
    
    @IBAction func cancelButtonClicked(sender: UIBarButtonItem) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func doneButtonClicked(sender: UIBarButtonItem) {
        let countdownManager = LKCountdownManager.sharedInstance
        
        
        let item = LKCountdownItem(name: self.nameTextField.text, date: self.datePicker.date)
        countdownManager.saveNewCountdownItem(item,countdownMode: self.datePicker.datePickerMode, completionHandler: {
            self.dismissViewControllerAnimated(true, completion: nil)
        })
    }
}
