//
//  LKAddItemViewController.swift
//  Countr
//
//  Created by Lukas Kollmer on 30/11/14.
//  Copyright (c) 2014 Lukas Kollmer. All rights reserved.
//

import Foundation
import UIKit

class LKAddItemViewController: UITableViewController, UITextFieldDelegate {
    
    @IBOutlet weak var doneBarButtonItem: UIBarButtonItem!
    
    @IBOutlet weak var nameTextField: UITextField!
    
    @IBOutlet weak var countdownModeSegmentedControl: UISegmentedControl!
    
    @IBOutlet weak var datePicker: UIDatePicker!
    
    let notification = CWStatusBarNotification()
    
    lazy var tracker = GAI.sharedInstance().defaultTracker
    
    
    
    override func loadView() {
        super.loadView()
        
        //self.doneBarButtonItem.enabled = false
        
        self.nameTextField.delegate = self

        self.datePicker.datePickerMode = .Date
        
        
        self.tableView.backgroundColor = UIColor.backgroundColor()
        self.nameTextField.backgroundColor = UIColor.foregroundColor()
        
        let placeholderString = NSLocalizedString("me.kollmer.countr.addItemView.itemTitlePlaceholderString", comment: "")
        self.nameTextField.attributedPlaceholder = NSAttributedString(string: placeholderString, attributes: [NSForegroundColorAttributeName : UIColor(rgba: "#D9D9D9"), NSFontAttributeName: UIFont(name: "Avenir-Book", size: 15)!])
        
        self.countdownModeSegmentedControl.setTitle(NSLocalizedString("me.kollmer.countr.addItem.segmentedControl.titleAtIndex.0", comment: ""), forSegmentAtIndex: 0)
        self.countdownModeSegmentedControl.setTitle(NSLocalizedString("me.kollmer.countr.addItem.segmentedControl.titleAtIndex.1", comment: ""), forSegmentAtIndex: 1)

        NSNotificationCenter.defaultCenter().addObserver(self, selector: "textFieldTextChanged", name: UITextFieldTextDidChangeNotification, object: self.nameTextField)
        
        // TODO in future versions: Add a clear button to the TextField (the system ylear button is disabled because it is only available in black and would be invisible)
        /*
        let clearButton: UIButton = UIButton.buttonWithType(UIButtonType.Custom) as UIButton
        let image = UIImage(named: "UITextField_ClearButton_White.png") //TODO: Create an image
        clearButton.frame = CGRectMake(0, 0, 15, 15) // The apple button is 19x19
        clearButton.setImage(image, forState: .Normal)
        clearButton.setImage(image, forState: .Highlighted)
        self.nameTextField.rightView = clearButton
        self.nameTextField.rightViewMode = .WhileEditing
        */
        
        /*
        let appleClearButton: UIButton = self.nameTextField.valueForKey("_clearButton") as UIButton
        //println("appleClearButton: \(appleClearButton)")
        //println("appleClearButton.image: \(appleClearButton.imageView?.image)")
        */
        
        // Google Analytics
        tracker.set(kGAIScreenName, value: "AddItem")
        tracker.send(GAIDictionaryBuilder.createScreenView().build())

    }
    
    override func viewDidAppear(animated: Bool) {
        self.nameTextField.becomeFirstResponder()

        //self.datePicker.viewDidAppear()
        
        self.notification.notificationAnimationInStyle = .Top
        self.notification.notificationAnimationOutStyle = .Top
        self.notification.notificationLabelTextColor = UIColor.whiteColor()
        self.notification.notificationLabelBackgroundColor = UIColor.redColor()
        self.notification.notificationStyle = .NavigationBarNotification
        
        self.notification.notificationDidDisplayClosure = {
            println("self.notification.notificationDidDisplayClosure")
            self.navigationItem.leftBarButtonItem?.enabled = false
            self.navigationItem.rightBarButtonItem?.enabled = false
        }
        self.notification.notificationWillDismissClosure = {
            println("self.notification.notificationWillDismissClosure")
            self.navigationItem.leftBarButtonItem?.enabled = true
            self.navigationItem.rightBarButtonItem?.enabled = true
        }
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
            /* Disabled because there is not enough spage on screen for a 3rd segment
        case 2:
            // Mode Countdown
            self.datePicker.datePickerMode = UIDatePickerMode.CountDownTimer
            break
            */
        default:
            break
        }
    }
    
    
    func textFieldTextChanged() {
        //self.doneBarButtonItem.enabled = !self.nameTextField.text.isEmpty
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        
        return true
    }
    
    @IBAction func cancelButtonClicked(sender: UIBarButtonItem) {
        self.dismissViewControllerAnimated(true, completion: {
            
            self.tracker.send(GAIDictionaryBuilder.createEventWithCategory(ui_action_key, action: button_press_key, label: cancel_button_key, value: nil).build())
        })
    }
    
    @IBAction func doneButtonClicked(sender: UIBarButtonItem) {
        
        if self.nameTextField.text.isEmpty {
            self.showNotificationForError(.NoTitleEntered)
            return
        }
        
        if self.datePicker.date.isPast {
            self.showNotificationForError(.DateIsPast)
            return
        }
        
        saveItem()
    }
    
    func saveItem() {
        let countdownManager = LKCountdownManager.sharedInstance
        
        
        let item = LKCountdownItem(title: self.nameTextField.text, date: self.datePicker.date, mode: self.datePicker.datePickerMode)
        countdownManager.saveNewCountdownItem(item,countdownMode: self.datePicker.datePickerMode, completionHandler: {
            self.dismissViewControllerAnimated(true, completion: nil)
        })
    }
    
    
    func showNotificationForError(error: LKAddCountdownError) {
        switch error {
        case .NoTitleEntered:
            self.notification.displayNotificationWithMessage(NSLocalizedString("me.kollmer.countr.addItem.noTitleAlert.message", comment: ""), duration: 1.5)
        case .DateIsPast:
            let alertController = LKAlertController.actionSheetWithTitle(NSLocalizedString("me.kollmer.countr.addItem.dateInPastAlert.title", comment: ""), message: NSLocalizedString("me.kollmer.countr.addItem.dateInPastAlert.message", comment: ""))
            let cancelAction = UIAlertAction(title: NSLocalizedString("me.kollmer.countr.addItem.dateInPastAlert.continue", comment: ""), style: .Destructive) {(action) in
                alertController.dismissViewControllerAnimated(true, completion: nil)
                self.saveItem()
            }
            
            let continueAction = UIAlertAction(title: NSLocalizedString("me.kollmer.countr.addItem.dateInPastAlert.cancel", comment: ""), style: .Default) {(action) in
                alertController.dismissViewControllerAnimated(true, completion: nil)
            }

            alertController.addAction(cancelAction)
            alertController.addAction(continueAction)
            
            self.presentViewController(alertController, animated: true, completion: nil)
            //self.notification.displayNotificationWithMessage("The entered date is in the past", duration: 2) //TODO: Use an UIalertController, allowing teh user to continue
        }
    }
}


enum LKAddCountdownError {
    case NoTitleEntered
    case DateIsPast
}
