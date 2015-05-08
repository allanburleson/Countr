//
//  LKItemDetailViewController.swift
//  Countr
//
//  Created by Lukas Kollmer on 4/26/15.
//  Copyright (c) 2015 Lukas Kollmer. All rights reserved.
//

import Foundation
import UIKit

class LKItemDetailViewController: UIViewController {
    
    @IBOutlet weak private var countdownLabel: UILabel!
    @IBOutlet weak private var countdownTitleLabel: UILabel!
    @IBOutlet weak private var editButton: UIButton!
    @IBOutlet weak private var deleteButton: UIButton!
    
    
    private lazy var tracker = GAI.sharedInstance().defaultTracker
    
    private var updateTimer: NSTimer!
    
    var countdownItem: LKCountdownItem!
    
    
    override func loadView() {
        super.loadView()
        
        
        self.view.backgroundColor = UIColor.backgroundColor()
        self.countdownLabel.textColor = UIColor.whiteColor()
        self.countdownTitleLabel.textColor = UIColor.whiteColor()
        
        self.countdownLabel.font = UIFont(name: "Avenir-Heavy", size: 50)!
        self.countdownLabel.adjustsFontSizeToFitWidth = true
        
        let doneBarButtonItem  = UIBarButtonItem(barButtonSystemItem: .Done, target: self, action: "done")
        let shareBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Action, target: self, action: "share")
        shareBarButtonItem.tintColor = UIColor.whiteColor()
        
        self.navigationItem.leftBarButtonItem = doneBarButtonItem
        self.navigationItem.rightBarButtonItem = shareBarButtonItem
        
        // Set the font of the buttons
        let buttonTitles = ["Edit", "Delete"]
        let buttons = [self.editButton!, self.deleteButton!]
        for button in buttons {
            let index = find(buttons, button)!
            button.setAttributedTitle(NSAttributedString.attributedStringWithString(buttonTitles[index], font: UIFont(name: "Avenir", size: 15)!), forState: .Normal)
        }
        
        
        if let countdownItem = self.countdownItem {
            self.countdownTitleLabel.text = self.countdownItem.title
            update()
            self.updateTimer = NSTimer.scheduledTimerWithTimeInterval(0.5, target: self, selector: "update", userInfo: nil, repeats: true)
        }
    }
    
    
    
    func update() {
        self.countdownItem.updateTimeRemaining()
        
        self.countdownLabel.text = self.countdownItem.remaining.asString
    }
    
    
    func share() {
        let shareData = LKCountdownManager.sharedInstance.shareCountdownItem(self.countdownItem, sender: self)
    }
    
    
    @IBAction func editButtonTapped(sender: UIButton) {
        
        let editViewController: LKEditItemPropertiesViewController = self.storyboard?.instantiateViewControllerWithIdentifier("me.countr.editItemViewController") as! LKEditItemPropertiesViewController
        let navigationController = UINavigationController(rootViewController: editViewController)
        
        editViewController.mode = .EditExistingEntry
        editViewController.item = self.countdownItem
        
        editViewController.didFinishEditingHandler = { (item: LKCountdownItem) in
            let oldItem = self.countdownItem
            self.countdownItem = item
            
            LKCountdownManager.sharedInstance.updateCountdownItem(oldItem, withCountdownItem: self.countdownItem)
            
        }
        
        
        editViewController.modalPresentationStyle = .FormSheet
        navigationController.modalPresentationStyle = .FormSheet
        
        self.showDetailViewController(navigationController, sender: self)
        
    }
    
    
    @IBAction func deleteButtonTapped(sender: UIButton) {
        let alertTitle = NSLocalizedString("me.kollmer.countr.deleteItemAlert.title", comment: "")
        let alertMessage = NSString(format: NSLocalizedString("me.kollmer.countr.deleteItemAlert.message", comment: ""), self.countdownItem.title)
        let alertDelete = NSLocalizedString("me.kollmer.countr.deleteItemAlert.delete", comment: "")
        let alertCancel = NSLocalizedString("me.kollmer.countr.deleteItemAlert.cancel", comment: "")
        let alertController = LKAlertController.actionSheetWithTitle(alertTitle, message: alertMessage as String)
        alertController.popoverPresentationController?.sourceView = sender
        alertController.popoverPresentationController?.sourceRect = sender.bounds
        //println("cell.frame: \(cell.frame)")
        //println("alertController.popoverPresentationController?.sourceRect: \(alertController.popoverPresentationController?.sourceRect)")
        
        let cancelAction = UIAlertAction(title: alertCancel, style: .Cancel) { (action) in
            //println(action)
        }
        
        
        let deleteAction = UIAlertAction(title: alertDelete, style: .Destructive) { (action) in
            //println(action)
            LKCountdownManager.sharedInstance.deleteCountdownItem(self.countdownItem)
            NSNotificationCenter.defaultCenter().postNotificationName(didDeleteAnItemKey, object: nil)
            
            self.dismissViewControllerAnimated(true) {
                self.tracker.send(GAIDictionaryBuilder.createEventWithCategory(countdown_manager_key, action: did_delete_item_from_detail_view_controller_key, label: nil, value: nil).build() as [NSObject : AnyObject])
            }
        }
        
        alertController.addAction(cancelAction)
        alertController.addAction(deleteAction)
        
        self.presentViewController(alertController, animated: true, completion: nil)
    }
    
    
    func done() {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
}