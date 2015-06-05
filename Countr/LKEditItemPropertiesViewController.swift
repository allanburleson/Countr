//
//  LKEditItemPropertiesViewController.swift
//  Countr
//
//  Created by Lukas Kollmer on 30/11/14.
//  Copyright (c) 2014 Lukas Kollmer. All rights reserved.
//

import Foundation
import UIKit


enum LKEditItemPropertiesViewControllerMode {
    case CreateNewEntry
    case EditExistingEntry
}

class LKEditItemPropertiesViewController: UITableViewController, UITextFieldDelegate {
    
    @IBOutlet private weak var doneBarButtonItem: UIBarButtonItem!
    
    @IBOutlet var allCells: [UITableViewCell]!
    @IBOutlet private weak var nameTextField: UITextField!
    
    @IBOutlet private weak var countdownModeSegmentedControl: UISegmentedControl!
    
    @IBOutlet private weak var datePicker: UIDatePicker!
    
    private lazy var notification: CWStatusBarNotification = {
        let _notification = CWStatusBarNotification()
        _notification.notificationAnimationInStyle = .Top
        _notification.notificationAnimationOutStyle = .Top
        _notification.notificationLabelTextColor = UIColor.whiteColor()
        _notification.notificationLabelBackgroundColor = UIColor.redColor()
        _notification.notificationStyle = .NavigationBarNotification
        
        _notification.notificationDidDisplayClosure = {
            //println("self.notification.notificationDidDisplayClosure")
            self.navigationItem.leftBarButtonItem?.enabled = false
            self.navigationItem.rightBarButtonItem?.enabled = false
        }
        _notification.notificationWillDismissClosure = {
            //println("self.notification.notificationWillDismissClosure")
            self.navigationItem.leftBarButtonItem?.enabled = true
            self.navigationItem.rightBarButtonItem?.enabled = true
        }
        
        return _notification

    }()
    
    lazy private var tracker = GAI.sharedInstance().defaultTracker
    
    var item: LKCountdownItem?
    
    var mode: LKEditItemPropertiesViewControllerMode = .CreateNewEntry

    var didFinishEditingHandler: (item: LKCountdownItem) -> () = {(item) in}
    

    
    
    override func loadView() {
        super.loadView()
        
        
        self.navigationController?.navigationBar.setDarkAttributes()
        
        //self.doneBarButtonItem.enabled = false
        
        self.nameTextField.delegate = self

        self.datePicker.datePickerMode = .Date
        
        
        self.tableView.backgroundColor = UIColor.backgroundColor()
        self.nameTextField.backgroundColor = UIColor.foregroundColor()
        
        for cell in allCells {
            cell.backgroundColor = UIColor.foregroundColor()
        }
        
        let textFieldFont = UIFont(name: "Avenir-Book", size: 16)!
        let placeholderString = NSLocalizedString("me.kollmer.countr.addItemView.itemTitlePlaceholderString", comment: "")
        self.nameTextField.attributedPlaceholder = NSAttributedString(string: placeholderString, attributes: [NSForegroundColorAttributeName : UIColor(rgba: "#D9D9D9"), NSFontAttributeName: textFieldFont])
        
        self.nameTextField.font = textFieldFont
        self.nameTextField.adjustsFontSizeToFitWidth = false
        self.nameTextField.minimumFontSize = 16
        
        // This works!
        /*
        The code below accesses the label used for displaying teh initial text in a UITextField and sets the font property to the same font used for actually editing the text
        
        Explanation: 
        A UITextField has multiple labels: One of them (An UITextFieldLabel *_displayLabel) is used for tisplaying text when editing is disabled. The UITextFieldLabel class inherits from UILabel.
        
        The first valueForKey loads the label used for displaying the text.
        The second ond (this time setValueForKey) is used to set the font attribute of the UILabel base class of the UITextFieldLabel
        
        NOTE: This works in iOS 8.3. MAY STOP WORKING IN THE FUTURE
        */
        self.nameTextField.valueForKey("_displayLabel")?.setValue(textFieldFont, forKey: "font")
        
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
        tracker.send(GAIDictionaryBuilder.createScreenView().build() as [NSObject : AnyObject])
        
        
        // Set the passed countdownItem (if mode is .Edit)
        if mode == .EditExistingEntry {
            if let item = self.item {
                self.nameTextField.text = item.title
                self.datePicker.datePickerMode = item.countdownMode
                self.datePicker.setDate(item.date, animated: false)
            }
        }

    }
    
    override func viewDidAppear(animated: Bool) {
        self.nameTextField.becomeFirstResponder()

        //self.datePicker.viewDidAppear()
        
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
            
            self.tracker.send(GAIDictionaryBuilder.createEventWithCategory(ui_action_key, action: button_press_key, label: cancel_button_key, value: nil).build() as [NSObject : AnyObject])
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
        if self.mode == .CreateNewEntry {
            let countdownManager = LKCountdownManager.sharedInstance
            
            
            let date = NSDate.dateFromDatePicker(self.datePicker)
            
            let item = LKCountdownItem(title: self.nameTextField.text, date: date, mode: self.datePicker.datePickerMode)
            
            countdownManager.saveNewCountdownItem(item, completionHandler: {
                self.dismissViewControllerAnimated(true, completion: nil)
            })
        }
        if self.mode == .EditExistingEntry {
            let editedItem = LKCountdownItem(
                title: self.nameTextField.text,
                date: self.datePicker.date,
                mode: self.datePicker.datePickerMode,
                id: NSUUID(UUIDString: self.item!.id)!)
            
            self.didFinishEditingHandler(item: editedItem)
            self.dismissViewControllerAnimated(true, completion: nil)
        }
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
            
            alertController.popoverPresentationController?.sourceView = self.view
            alertController.popoverPresentationController?.sourceRect = self.view.bounds
            alertController.popoverPresentationController?.permittedArrowDirections = .Down
            
            self.presentViewController(alertController, animated: true, completion: nil)
            //self.notification.displayNotificationWithMessage("The entered date is in the past", duration: 2) //TODO: Use an UIalertController, allowing teh user to continue
        }
    }
}


enum LKAddCountdownError {
    case NoTitleEntered
    case DateIsPast
}
