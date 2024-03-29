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
    @IBOutlet weak var countdownDateLabel: UILabel!
    @IBOutlet weak private var editButton: UIButton!
    @IBOutlet weak private var deleteButton: UIButton!
    private var shareButton: UIBarButtonItem!


    private lazy var tracker = GAI.sharedInstance().defaultTracker

    private var updateTimer: NSTimer!

    var countdownItem: LKCountdownItem!


    override func loadView() {
        super.loadView()


        self.navigationController?.navigationBar.setDarkAttributes()


        self.view.backgroundColor = UIColor.backgroundColor()

        self.countdownLabel.textColor = UIColor.whiteColor()
        self.countdownLabel.font = UIFont.boldSystemFontOfSize(50)
        self.countdownLabel.adjustsFontSizeToFitWidth = true



        self.countdownTitleLabel.textColor = UIColor.whiteColor()
        self.countdownTitleLabel.font = UIFont.systemFontOfSize(19)

        self.countdownDateLabel.textColor = UIColor.whiteColor()
        self.countdownDateLabel.font = UIFont.italicSystemFontOfSize(17)



        let doneBarButtonItem  = UIBarButtonItem(barButtonSystemItem: .Done, target: self, action: "done")
        self.shareButton = UIBarButtonItem(barButtonSystemItem: .Action, target: self, action: "share")
        self.shareButton.tintColor = UIColor.whiteColor()

        self.navigationItem.leftBarButtonItem = doneBarButtonItem
        self.navigationItem.rightBarButtonItem = self.shareButton

        // Set the font of the buttons
        let editButtonTitle = NSLocalizedString("me.kollmer.countr.itemDetailView.edit", comment: "")
        let deleteButtonTitle = NSLocalizedString("me.kollmer.countr.itemDetailView.delete", comment: "")
        let buttonTitles = [editButtonTitle, deleteButtonTitle]
        let buttons = [self.editButton!, self.deleteButton!]
        for button in buttons {
            let index = buttons.indexOf(button)!
            button.setAttributedTitle(NSAttributedString.attributedStringWithString(buttonTitles[index], font: UIFont.systemFontOfSize(15)), forState: .Normal)
        }


        if let countdownItem = self.countdownItem {
            self.countdownTitleLabel.text = countdownItem.title
            self.countdownDateLabel.text = countdownItem.date.descriptiveString
            update()

            self.updateTimer = NSTimer.scheduledTimerWithTimeInterval(0.5, target: self, selector: "update", userInfo: nil, repeats: true)
        }
    }



    func update() {
        self.countdownItem.updateTimeRemaining()

        self.countdownLabel.text = self.countdownItem.remaining.asString
    }


    func share() {
        let shareData = LKCountdownManager.sharedInstance.shareCountdownItem(self.countdownItem, sender: self.shareButton, presentingViewController: self)
    }


    @IBAction func editButtonTapped(sender: UIButton) {

        let editViewController: LKEditItemPropertiesViewController = self.storyboard?.instantiateViewControllerWithIdentifier("me.countr.editItemViewController") as! LKEditItemPropertiesViewController
        let navigationController = UINavigationController(rootViewController: editViewController)

        editViewController.mode = .EditExistingEntry
        editViewController.item = self.countdownItem

        editViewController.didFinishEditingHandler = { (item: LKCountdownItem) in
            let oldItem = self.countdownItem
            self.countdownItem = item

            self.countdownTitleLabel.text = self.countdownItem.title

            self.update()

            LKCountdownManager.sharedInstance.updateCountdownItem(oldItem, withCountdownItem: self.countdownItem)

        }


        editViewController.modalPresentationStyle = .FormSheet
        navigationController.modalPresentationStyle = .FormSheet

        self.showDetailViewController(navigationController, sender: self)

    }


    @IBAction func deleteButtonTapped(sender: UIButton) {
        let alertTitle = NSLocalizedString("me.kollmer.countr.deleteItemAlert.title", comment: "")
        let alertMessage: String = NSString(format: NSLocalizedString("me.kollmer.countr.deleteItemAlert.message", comment: ""), self.countdownItem.title) as String
        let alertDelete = NSLocalizedString("me.kollmer.countr.deleteItemAlert.delete", comment: "")
        let alertCancel = NSLocalizedString("me.kollmer.countr.deleteItemAlert.cancel", comment: "")
        let alertController = UIAlertController(title: alertTitle, message: alertMessage, preferredStyle: .Alert)
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
