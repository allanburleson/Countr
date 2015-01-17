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
    
    @IBOutlet weak var sendFeedbackCell: UITableViewCell!
    @IBOutlet weak var infoBarButtonItem: UIBarButtonItem!
    override func loadView() {
        super.loadView()
        
        if self.traitCollection.userInterfaceIdiom == .Pad {
            self.navigationItem.leftBarButtonItem = nil
        }
        
    }
    
    
    @IBAction func doneButtonClicked() {
        self.dismissViewControllerAnimated(true, completion: nil)
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
        if !MFMailComposeViewController.canSendMail() {
            println("No Mail accounts configured")
            let alertController = UIAlertController(title: "Error", message: "No Mail accounts configured", preferredStyle: .Alert)
            let dismissAction = UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.Default, handler: {(action) in
                alertController.dismissViewControllerAnimated(true, completion: nil)
            })
            alertController.addAction(dismissAction)
            self.presentViewController(alertController, animated: true, completion: nil)
            return
        }
        let mailComposer = MFMailComposeViewController()
        mailComposer.mailComposeDelegate = self
        mailComposer.setSubject("Countr Feedback")
        mailComposer.setToRecipients(["lukas@kollmer.me"])
        mailComposer.setMessageBody("", isHTML: false) //TODO: Add some default text?
        
    }
    
    func showWebsite() {
        let url = NSURL(string: "http://kollmer.me/countr")!
        UIApplication.sharedApplication().openURL(url)
    }
    
    func deleteAllData() {
        let alertController = UIAlertController(title: "¿¿Sure??", message: "Are you sure you want to delete all data in this application?", preferredStyle: .ActionSheet)
        let deleteAction = UIAlertAction(title: "Delete", style: .Destructive, handler: {(action) in
            println("delete")
        })
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel, handler: {(action) in
            println("cancel")
        })
        
        alertController.addAction(deleteAction)
        alertController.addAction(cancelAction)
        
        self.presentViewController(alertController, animated: true, completion: nil)
    }
    
    // MARK: MFMailViewController delegate
    
    func mailComposeController(controller: MFMailComposeViewController!, didFinishWithResult result: MFMailComposeResult, error: NSError!) {
        controller.dismissViewControllerAnimated(true, completion: nil)
    }
}