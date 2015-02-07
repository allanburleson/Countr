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

class LKInfoViewController: UITableViewController, MFMailComposeViewControllerDelegate {
    
    // Google analytics
    lazy var tracker = GAI.sharedInstance().defaultTracker
    
    @IBOutlet weak var versionTextLabel: UILabel!
    @IBOutlet weak var versionNumberLabel: UILabel!
    @IBOutlet weak var premiumFeaturesTextLabel: UILabel!
    
    @IBOutlet weak var sendFeedbackTextLabel: UILabel!
    
    @IBOutlet weak var supportTextLabel: UILabel!
    
    @IBOutlet weak var copyrightLabel: UILabel!
    @IBOutlet weak var deleteAllDataTextLabel: UILabel!
    @IBOutlet weak var sendFeedbackCell: UITableViewCell!
    @IBOutlet weak var infoBarButtonItem: UIBarButtonItem! //TODO: What is this?
    @IBOutlet weak var deleteAllDataLabel: UILabel!
    
    let webViewController = PBWebViewController()
    var webViewControllerNavigationController: UINavigationController!
    
    
    override func loadView() {
        super.loadView()
        
        self.tableView.backgroundColor = UIColor.backgroundColor()
        
        self.versionNumberLabel.text = UIApplication.sharedApplication().version
        self.versionTextLabel.text = NSLocalizedString("me.kollmer.countr.infoView.versionTextLabel", comment: "")
        self.premiumFeaturesTextLabel.text = NSLocalizedString("me.kollmer.countr.infoView.unlockEverything", comment: "")
        self.sendFeedbackTextLabel.text = NSLocalizedString("me.kollmer.countr.infoView.feedbackLabel", comment: "")
        self.supportTextLabel.text = NSLocalizedString("me.kollmer.countr.infoView.supportLabel", comment: "")
        self.deleteAllDataTextLabel.text = NSLocalizedString("me.kollmer.countr.infoView.deleteAllDataLabel", comment: "")
        self.copyrightLabel.text = NSLocalizedString("me.kollmer.countr.infoView.copyrightLabel", comment: "")
        
        // Google Analytics
        tracker.set(kGAIScreenName, value: "Info")
        tracker.send(GAIDictionaryBuilder.createScreenView().build())

        
    }
    
    
    
    @IBAction func doneButtonClicked() {
        self.dismissViewControllerAnimated(true, completion: {
            self.tracker.send(GAIDictionaryBuilder.createEventWithCategory(ui_action_key, action: button_press_key, label: done_button_key, value: nil).build())
        })
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        if indexPath.section == 1 {
            switch indexPath.row {
            case 0:
                // Send Feedback
                sendFeedback()
                break
            case 1:
                // Support (-> Website)
                showWebsite()
                break
            default:
                break
            }
        }
        
        if indexPath.section == 2 {
            // Delete all Data
            deleteAllData()
        }
    }
    
    
    func sendFeedback() {
        //println("sendFeedback")
        tracker.send(GAIDictionaryBuilder.createEventWithCategory(ui_action_key, action: button_press_key, label: write_email_key, value: nil).build())
        
        if MFMailComposeViewController.canSendMail() {

            let mailComposer = MFMailComposeViewController()
            mailComposer.mailComposeDelegate = self
            mailComposer.setSubject("Countr Feedback")
            mailComposer.setToRecipients(["lukas@kollmer.me"])
            mailComposer.setMessageBody("", isHTML: false) //TODO: Add some default text?
            mailComposer.mailComposeDelegate = self
            self.presentViewController(mailComposer, animated: true, completion: nil)
        } else {
            //println("No Mail accounts configured")
            let alertController = UIAlertController(title: "Error", message: "No Mail accounts configured", preferredStyle: .Alert)
            let dismissAction = UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.Default, handler: {(action) in
                alertController.dismissViewControllerAnimated(true, completion: nil)
            })
            alertController.addAction(dismissAction)
            self.presentViewController(alertController, animated: true, completion: nil)

        }
    }
    
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
    
    func doneButtonPressed(sender: AnyObject) {
        //println("\(sender)")
        let barButton: UIBarButtonItem = sender as UIBarButtonItem
        
        self.webViewController.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func deleteAllData() {
        let alertTitle = NSLocalizedString("me.kollmer.countr.infoView.deleteAlert.title", comment: "")
        let alertMessage = NSLocalizedString("me.kollmer.countr.infoView.deleteAlert.message", comment: "")
        let alertButtonDeleteTitle = NSLocalizedString("me.kollmer.countr.infoView.deleteAlert.deleteButton.title", comment: "")
        let alertButtonCancelTitle = NSLocalizedString("me.kollmer.countr.infoView.deleteAlert.cancelButton.title", comment: "")
        let alertController = UIAlertController(title: alertTitle, message: alertMessage, preferredStyle: .ActionSheet)
        let deleteAction = UIAlertAction(title: alertButtonDeleteTitle, style: .Destructive, handler: {(action) in
            //println("delete")
            let countdownManager = LKCountdownManager.sharedInstance
            countdownManager.deleteAllItems({
                NSNotificationCenter.defaultCenter().postNotificationName(didDeleteAllItemsKey, object: nil)
                self.tracker.send(GAIDictionaryBuilder.createEventWithCategory(ui_action_key, action: button_press_key, label: delete_all_data_button_key, value: true).build())
            })
        })
        
        let cancelAction = UIAlertAction(title: alertButtonCancelTitle, style: .Cancel, handler: {(action) in
            //println("cancel")
            
            self.tracker.send(GAIDictionaryBuilder.createEventWithCategory(ui_action_key, action: button_press_key, label: delete_all_data_button_key, value: false).build())
        })
        
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