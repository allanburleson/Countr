//
//  LKCountdown+Sharing.swift
//  Countr
//
//  Created by Lukas Kollmer on 6/2/15.
//  Copyright (c) 2015 Lukas Kollmer. All rights reserved.
//

import Foundation
import UIKit
import EventKit
import EventKitUI


extension LKCountdownManager {
    /*
    Share a countdownItem
    
    :param: item The LKCountdownItem to be shared
    :param: sender The ViewController to present the share sheet from. If this parameter is nil, the sender has to present the share sheet
    */
    func shareCountdownItem(item: LKCountdownItem, sender: AnyObject?, presentingViewController: UIViewController?) -> (shareURL: NSURL, shareHTMLBody: String) {
        // Create the share string
        let _example_string = "countr://add?title=Hello%20World&date=1430491533.436371&mode=dateAndTime"
        
        let encodedTitle: String = item.title.stringByAddingPercentEscapesUsingEncoding(NSUTF8StringEncoding)!
        let dateInterval: String = String(stringInterpolationSegment: item.date.timeIntervalSince1970)
        let countdownMode: String = item.countdownMode.toString()
        let urlString: String = "countr://add?title=" + encodedTitle + "&date=" + dateInterval + "&mode=" + countdownMode
        
        let title = item.title
        let text = LKCountdownSharingActivityAddToCalendarTimeRemaininigTextItemProvider(placeholderItem: item.shareDescription)
        let date = LKCountdownSharingActivityAddToCalendarDateItemProvider(placeholderItem: item.date)
        let url = NSURL(string: urlString)!
        
        let addToCalendarActivity = LKCountdownSharingActivityAddToCalendar()
        
        if let _ = sender, _ = presentingViewController {
            
            var sourceView: UIView!
            var sourceRect: CGRect!
            
            if sender is UIButton {
                sourceView = sender as! UIButton
                sourceRect = (sender as! UIButton).bounds
            }
            
            if sender is UIBarButtonItem {
                sourceView = (sender as! UIBarButtonItem).valueForKey("_view") as! UIView
                sourceRect = ((sender as! UIBarButtonItem).valueForKey("_view") as! UIView).bounds
            }
            
            if sender is LKItemCell {
                sourceView = sender as! LKItemCell
                sourceRect = (sender as! LKItemCell).bounds
            }
            
            
            let activityViewController = UIActivityViewController(activityItems: [title, text, date, url], applicationActivities: [addToCalendarActivity])
            activityViewController.popoverPresentationController?.sourceView = sourceView
            activityViewController.popoverPresentationController?.sourceRect = sourceRect
            
            presentingViewController!.presentViewController(activityViewController, animated: true, completion: nil)
        }
        
        
        return (url, "html share body")
        
    }

}

// MARK: Sharing Activities

internal let LKActivityTypeAddToCalendar = "me.kollmer.countr.share.customActivities.addToCalendar"

class LKCountdownSharingActivityAddToCalendarTimeRemaininigTextItemProvider: UIActivityItemProvider {
    
    override func item() -> AnyObject! {
        println("item::timeremainingi")
        if activityType != LKActivityTypeAddToCalendar {
            return placeholderItem
        } else {
            return nil
        }
    }
}

class LKCountdownSharingActivityAddToCalendarDateItemProvider: UIActivityItemProvider {
    
    override func item() -> AnyObject! {
        println("item::date")
        if activityType == LKActivityTypeAddToCalendar {
            return placeholderItem
        } else {
            return nil
        }
    }
}

class LKCountdownSharingActivityAddToCalendar: UIActivity, EKEventEditViewDelegate {
    
    var activityItems: [AnyObject] = []
    
    override func activityType() -> String? {
        return LKActivityTypeAddToCalendar
    }
    
    override func activityTitle() -> String? {
        let title = NSLocalizedString("me.kollmer.countr.shareItemShareSheet.addToCalendarActivity.title", comment: "")
        return "Add to Calendar"
    }
    
    override func activityImage() -> UIImage? {
        // TODO: Add a real image
        return nil
    }
    
    override func canPerformWithActivityItems(activityItems: [AnyObject]) -> Bool {
        println("canPerform::activityItems: \(activityItems)")
        return true
    }
    
    
    override func prepareWithActivityItems(activityItems: [AnyObject]) {
        println("prepare::activityItems: \(activityItems)")
        self.activityItems = activityItems
    }
    
    override func activityViewController() -> UIViewController? {
        
        
        // TODO: Instead of actually showing a calendar vc, just add the event and shiow a confirmation notification
        println("activityViewController")
        
        var title: String!
        var date: NSDate!
        var url: NSURL!
        
        for item in self.activityItems {
            if item is String {
                title = item as! String
            }
            
            if item is NSDate {
                date = item as! NSDate
            }
            
            if item is NSURL {
                url = item as! NSURL
            }
        }
        
        println("performActivity::title: \(title)")
        println("performActivity::date: \(date)")
        println("performActivity::url: \(url)")
        
        
        // Create the event
        let eventStore = EKEventStore()
        
        if EKEventStore.authorizationStatusForEntityType(EKEntityTypeEvent) == .NotDetermined {
            eventStore.requestAccessToEntityType(EKEntityTypeEvent, completion: { (accessGranted: Bool, error: NSError!) -> Void in
                if error != nil {
                    println("Error requesting access to celandar. \(error) \(error.localizedDescription)")
                }
                
                println("celandar access granted: \(accessGranted)")
            })
        }
        
        if EKEventStore.authorizationStatusForEntityType(EKEntityTypeEvent) != .Authorized {
            let alertController = LKAlertController.alertViewWithTitle("Error", message: "You need to allow Countr to access your calendar in order to save items") // TODO: Edit the message
            let grantAccessAction = UIAlertAction(title: "Grant Access", style: .Default, handler: { (action: UIAlertAction!) -> Void in
                let settingsURL = NSURL(string: UIApplicationOpenSettingsURLString)!
                
                UIApplication.sharedApplication().openURL(settingsURL)
            })
            let cancelAction = UIAlertAction(title: "Dismiss", style: .Cancel, handler: { (action: UIAlertAction!) -> Void in
                alertController.dismissViewControllerAnimated(true, completion: nil)
            })
            alertController.addAction(cancelAction)
            alertController.addAction(grantAccessAction)
            
            return alertController
            
        }
        
        let event = EKEvent(eventStore: eventStore)
        event.title = title
        
        
        // Check if the item is allDay
        let urlParser = LKURLParser(URL: url)
        let mode: LKCountdownMode = LKCountdownMode(string: urlParser.valueForVariable("mode"))
        if mode == .Date {
            event.allDay = true
            event.startDate = date
            event.endDate = date
        } else { // Ebent is NOT allDay
            event.allDay = false
            event.startDate = date
            event.endDate = date.dateByAddingMinutes(60) // TODO: Change default duration???
        }
        
        event.URL = url // TODO: Would it be better to set the url in the notes section with some text (Saved with Countr. Tap [this link](countr://add...) to add the item to countr)
        
        
        
        // Create the event edit viewController
        
        let eventEditViewController = EKEventEditViewController()
        eventEditViewController.event = event
        eventEditViewController.eventStore = eventStore
        eventEditViewController.editViewDelegate = self
        
        println("will return")
        return eventEditViewController
    }
    
    
    // EventEditViewController delegate
    
    func eventEditViewController(controller: EKEventEditViewController!, didCompleteWithAction action: EKEventEditViewAction) {
        println("didcompleteaction")
        controller.dismissViewControllerAnimated(true, completion: nil)
    }
}