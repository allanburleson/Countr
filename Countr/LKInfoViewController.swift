//
//  LKInfoViewController.swift
//  Countr
//
//  Created by Lukas Kollmer on 1/17/15.
//  Copyright (c) 2015 Lukas Kollmer. All rights reserved.
//

import Foundation
import UIKit
import MessageUI
import Crashlytics

class LKInfoViewController: UITableViewController, MFMailComposeViewControllerDelegate {
    
    
    // UI
    @IBOutlet weak var versionTextLabel: UILabel!
    @IBOutlet weak var versionNumberLabel: UILabel!
    @IBOutlet weak var premiumFeaturesTextLabel: UILabel!
    @IBOutlet weak var unlockEverythingCell: UITableViewCell!
    
    @IBOutlet weak var sortByLabel: UILabel!
    @IBOutlet weak var sortBySegmentedControl: UISegmentedControl!
    
    @IBOutlet weak var appBadgeLabel: UILabel!
    @IBOutlet weak var appBadgeSwitch: UISwitch!
    
    private var sectionFooterDescriptionLabel: UILabel!
    
    
    @IBOutlet weak var sendFeedbackTextLabel: UILabel!
    
    @IBOutlet weak var supportTextLabel: UILabel!
    
    @IBOutlet weak var copyrightLabel: UILabel!
    @IBOutlet weak var deleteAllDataTextLabel: UILabel!
    @IBOutlet weak var sendFeedbackCell: UITableViewCell!
    @IBOutlet weak var infoBarButtonItem: UIBarButtonItem! //This is the done bar button in the upper left corner
    @IBOutlet weak var deleteAllDataLabel: UILabel!
    
    
    // Instance vars
    private lazy var tracker = GAI.sharedInstance().defaultTracker
    
    private let settingsManager = LKSettingsManager.sharedInstance
    
    lazy var notification: CWStatusBarNotification = {
        let _notification = CWStatusBarNotification()
        _notification.notificationLabelBackgroundColor = UIColor.redColor()
        _notification.notificationLabelTextColor = UIColor.blackColor()
        _notification.notificationStyle = .NavigationBarNotification //.StatusBarNotification
        _notification.notificationAnimationInStyle = .Top
        _notification.notificationAnimationOutStyle = .Top
        _notification.notificationDidDisplayClosure = {
            self.infoBarButtonItem.enabled = false
        }
        _notification.notificationWillDismissClosure = {
            self.infoBarButtonItem.enabled = true
        }
        
        return _notification
        
        }()

    
    
    
    override func loadView() {
        super.loadView()
        
        
        self.navigationController?.navigationBar.setDarkAttributes()
        
        self.title = NSLocalizedString("me.kollmer.countr.infoView.title", comment: "")
        
        self.tableView.backgroundColor = UIColor.backgroundColor()
        
        // Section 0 - About/Info
        self.versionNumberLabel.text = UIApplication.sharedApplication().version
        self.versionTextLabel.text = NSLocalizedString("me.kollmer.countr.infoView.versionTextLabel", comment: "")
        self.premiumFeaturesTextLabel.text = NSLocalizedString("me.kollmer.countr.infoView.unlockEverything", comment: "")
        
        // Section 1 - Settings
        self.sortByLabel.text = NSLocalizedString("me.kollmer.countr.infoView.sortingStyleText", comment: "")
        self.appBadgeLabel.text = NSLocalizedString("me.kollmer.countr.infoView.appBadgeText", comment: "")
        let segmentedControlTitles = [
            NSLocalizedString("me.kollmer.countr.infoView.sortingStyleText.Title", comment: ""),
            NSLocalizedString("me.kollmer.countr.infoView.sortingStyleText.Date", comment: "")
        ]
        self.sortBySegmentedControl.setTitle(segmentedControlTitles[0], forSegmentAtIndex: 0)
        self.sortBySegmentedControl.setTitle(segmentedControlTitles[1], forSegmentAtIndex: 1)
        
        // Section 2 – Feedback
        self.sendFeedbackTextLabel.text = NSLocalizedString("me.kollmer.countr.infoView.feedbackLabel", comment: "")
        //self.supportTextLabel.text = NSLocalizedString("me.kollmer.countr.infoView.supportLabel", comment: "")
        
        // Section 3 - Delete All Data
        self.deleteAllDataTextLabel.text = NSLocalizedString("me.kollmer.countr.infoView.deleteAllDataLabel", comment: "")
        
        // Section 4 - Copyright
        self.copyrightLabel.text = NSLocalizedString("me.kollmer.countr.infoView.copyrightLabel", comment: "")
        
        // Google Analytics
        tracker.set(kGAIScreenName, value: "Info")
        tracker.send(GAIDictionaryBuilder.createScreenView().build() as [NSObject : AnyObject])
        
        if LKPurchaseManager.didPurchase {
            unlockEverythingCell.accessoryType = .Checkmark
        }
        
        
        // Settings
        self.sortBySegmentedControl.selectedSegmentIndex = settingsManager.sortingStyle.toIndex()
        self.appBadgeSwitch.on = settingsManager.appBadgeEnabled
        

        
    }
    
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        if let indexPath = self.tableView.indexPathForSelectedRow() {
            self.tableView.deselectRowAtIndexPath(indexPath, animated: true)
        }
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        self.notification.dismissNotification()
        
    }
    
    
    // MARK: UI Actions
    
    @IBAction func doneButtonClicked() {
        self.dismissViewControllerAnimated(true, completion: {
            self.tracker.send(GAIDictionaryBuilder.createEventWithCategory(ui_action_key, action: button_press_key, label: done_button_key, value: nil).build() as [NSObject : AnyObject])
        })
    }
    
    @IBAction func sortBySegmentedControlChanged(sender: UISegmentedControl) {
        println("sortBySegmentedControlChanged")
        self.settingsManager.setSortingStyle(LKSortingStyle(index: self.sortBySegmentedControl.selectedSegmentIndex))
    }
    
    @IBAction func appBadgeSwitchChanged(sender: UISwitch) {
        println("appBadgeSwitchChanged")
        self.settingsManager.setAppBadgeOn(self.appBadgeSwitch.on)
        if !self.appBadgeSwitch.on {
            UIApplication.sharedApplication().applicationIconBadgeNumber = 0
        } else {
            UIApplication.sharedApplication().applicationIconBadgeNumber = LKCountdownManager.sharedInstance.itemsDueToday().count
        }
    }
    
    
    // TableView

    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return [nil, NSLocalizedString("me.kollmer.countr.infoView.settingsSectionHeader", comment: "") as String?, nil, nil, nil][section]
    }
    
    override func tableView(tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        return [nil, NSLocalizedString("me.kollmer.countr.infoView.appBadgeExplanationFooter", comment: "") as String?, nil, nil, nil][section]
    }
    
    override func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let label = UILabel()
        label.frame = CGRectMake(16, 13, 320, 17)
        label.font = UIFont.boldSystemFontOfSize(14)
        label.textColor = UIColor.whiteColor()
        
        label.text = self.tableView(tableView, titleForHeaderInSection: section)?.uppercaseString
        
        let headerView = UIView()
        headerView.addSubview(label)
        
        return headerView
    }
    
    
    override func tableView(tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        println("tableView.viewForFooterInSection: \(section)")
        let label = UILabel()
        let labelWidth: CGFloat = self.tableView.frame.width - 21 // 21 = 16 (the x inset) + 5 (keep some free space at the right screen bezel)
        label.frame = CGRectMake(16, 8, labelWidth, 40)
        label.font = UIFont.systemFontOfSize(14)
        label.textColor = UIColor.whiteColor()
        label.numberOfLines = 0
        
        label.text = self.tableView(tableView, titleForFooterInSection: section)
        
        let footerView = UIView()
        footerView.addSubview(label)
        
        return footerView
    }
    
    override func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if section == 1 {
            return 55
        } else {
            return UITableViewAutomaticDimension
        }
    }

    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        if !(indexPath.section == 0 && indexPath.row == 1) {
            tableView.deselectRowAtIndexPath(indexPath, animated: true)
        }
        
        if indexPath.section == 2 {
            switch indexPath.row {
            case 0:
                // Send Feedback
                sendFeedback()
                break
            case 1:
                // Support (-> Website)
                //showWebsite()
                break
            default:
                break
            }
        }
        
        if indexPath.section == 3 {
            // Delete all Data
            deleteAllData()
        }
    }
    
    
    func sendFeedback() {
        //println("sendFeedback")
        tracker.send(GAIDictionaryBuilder.createEventWithCategory(ui_action_key, action: button_press_key, label: write_email_key, value: nil).build() as [NSObject : AnyObject])
        
        if MFMailComposeViewController.canSendMail() {

            let mailComposer = MFMailComposeViewController()
            mailComposer.mailComposeDelegate = self
            mailComposer.setSubject("Countr Feedback")
            mailComposer.setToRecipients(["Lukas Kollmer <lukas@kollmer.me>"])
            mailComposer.setMessageBody("", isHTML: false) //TODO: Add some default text?
            mailComposer.mailComposeDelegate = self
            self.presentViewController(mailComposer, animated: true, completion: nil)
        } else {
            /*
            //println("No Mail accounts configured")
            //let alertController = UIAlertController(title: "Error", message: "No Mail accounts configured", preferredStyle: .Alert)
            let alertController = LKAlertController.alertViewWithTitle("Error", message: "No Mail accounts configured")
            let dismissAction = UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.Cancel, handler: {(action) in
                alertController.dismissViewControllerAnimated(true, completion: nil)
            })
            alertController.addAction(dismissAction)
            self.presentViewController(alertController, animated: true, completion: nil)
            */
            
            let notificationTitle = NSLocalizedString("me.kollmer.countr.infoView.noMailConfigured.notification.message", comment: "")
            self.notification.displayNotificationWithMessage(notificationTitle, duration: 1.5)

        }
    }
    
    /*
    func showWebsite() {
        let url = NSURL(string: "http://kollmer.me/countr")!
        
        webViewController.URL = url
        
        self.webViewControllerNavigationController = UINavigationController(rootViewController: webViewController)
        webViewControllerNavigationController.modalPresentationStyle = .OverFullScreen
        webViewControllerNavigationController.modalPresentationStyle = .OverFullScreen
        
        
        
        let doneButton = UIBarButtonItem(barButtonSystemItem: .Done, target: self, action: Selector("doneButtonPressed:"))
        
        webViewController.navigationItem.leftBarButtonItem = doneButton

        self.showDetailViewController(webViewControllerNavigationController, sender: self)
        
        tracker.send(GAIDictionaryBuilder.createEventWithCategory(ui_action_key, action: button_press_key, label: show_website_key, value: nil).build())


    }
    */
    
    func doneButtonPressed(sender: AnyObject) {
        //println("\(sender)")
        let barButton: UIBarButtonItem = sender as! UIBarButtonItem
        
        //self.webViewController.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func deleteAllData() {
        let alertTitle = NSLocalizedString("me.kollmer.countr.infoView.deleteAllItems.alert.title", comment: "")
        let alertMessage = NSLocalizedString("me.kollmer.countr.infoView.deleteAllItems.alert.message", comment: "")
        let alertButtonDeleteTitle = NSLocalizedString("me.kollmer.countr.infoView.deleteAllItems.alert.deleteButton.title", comment: "")
        let alertButtonCancelTitle = NSLocalizedString("me.kollmer.countr.infoView.deleteAllItems.alert.cancelButton.title", comment: "")


        //let attributedTitle: NSAttributedString = NSAttributedString(string: alertTitle, attributes: [NSFontAttributeName: UIFont(name: "Avenir-Heavy", size: 14)!, NSForegroundColorAttributeName: UIColor.grayColor()])
        //let attributedMessage: NSAttributedString = NSAttributedString(string: alertMessage, attributes: [NSFontAttributeName: UIFont(name: "Avenir-Roman", size: 14)!, NSForegroundColorAttributeName: UIColor.grayColor()])


        let alertController = LKAlertController.actionSheetWithTitle(alertTitle, message: alertMessage)

        let deleteAction = UIAlertAction(title: alertButtonDeleteTitle, style: .Destructive, handler: {(action) in
            //println("delete")
            let countdownManager = LKCountdownManager.sharedInstance
            let numberOfItemsBeforeDeletion = countdownManager.numberOfItems
            countdownManager.deleteAllItems { (success: Bool) in
                if success {
                    var notificationMassage: String
                    if numberOfItemsBeforeDeletion == 1 {
                        notificationMassage = NSString(format: NSLocalizedString("me.kollmer.countr.infoView.deleteAllItems.notification.message.singleItem", comment: ""), numberOfItemsBeforeDeletion) as String
                    } else {
                        notificationMassage = NSString(format: NSLocalizedString("me.kollmer.countr.infoView.deleteAllItems.notification.message.multipleItems", comment: ""), numberOfItemsBeforeDeletion) as String
                    }
                    self.notification.displayNotificationWithMessage(notificationMassage, duration: 1.5)
                    NSNotificationCenter.defaultCenter().postNotificationName(didDeleteAllItemsKey, object: nil)
                    self.tracker.send(GAIDictionaryBuilder.createEventWithCategory(ui_action_key, action: button_press_key, label: delete_all_data_button_key, value: true).build() as [NSObject : AnyObject])
                }
            }
        })

        let cancelAction = UIAlertAction(title: alertButtonCancelTitle, style: .Cancel) { (action) -> Void in
            self.tracker.send(GAIDictionaryBuilder.createEventWithCategory(ui_action_key, action: button_press_key, label: delete_all_data_button_key, value: false).build() as [NSObject : AnyObject])
        }
        
        alertController.addAction(deleteAction)
        alertController.addAction(cancelAction)
        
        alertController.popoverPresentationController?.sourceView = self.deleteAllDataLabel
        
        self.presentViewController(alertController, animated: true, completion: {
            //self.tracker.send(GAIDictionaryBuilder.createEventWithCategory(ui_action_key, action: button_press_key, label: delete_all_data_button_key, value: nil).build())
        })
    }
    
    // MARK: MFMailViewController delegate
    
    func mailComposeController(controller: MFMailComposeViewController!, didFinishWithResult result: MFMailComposeResult, error: NSError!) {
        controller.dismissViewControllerAnimated(true, completion: nil)
        //println("mailComposeController didFinishWithResult: \(result)")

        switch result.value {
            case MFMailComposeResultCancelled.value:
                //println("MFMailComposeResultCancelled")
                break
            case MFMailComposeResultSaved.value:
                //println("MFMailComposeResultSaved")
                break
            case MFMailComposeResultSent.value:
                //println("MFMailComposeResultSent")
                break
            case MFMailComposeResultFailed.value:
                //println("MFMailComposeResultFailed")
                break
        default:
        break
        }
    }
    
    
}