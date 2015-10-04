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


/**
This is a class extension because the LKCountdown base class is also avalable on other project targets (Widget, Watch, etc.)
*/
extension LKCountdownManager {

    /**
    Share a countdownItem

    - parameter item: The LKCountdownItem to be shared
    - parameter sender: The ViewController to present the share sheet from. If this parameter is nil, the sender has to present the share sheet
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


            // NOTE: Teh custom sharing extension
            let activityViewController = UIActivityViewController(activityItems: [title, text, date, url], applicationActivities: [/*addToCalendarActivity*/])
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
        print("item::timeremainingi")
        if activityType != LKActivityTypeAddToCalendar {
            return placeholderItem
        } else {
            return nil
        }
    }
}

class LKCountdownSharingActivityAddToCalendarDateItemProvider: UIActivityItemProvider {

    override func item() -> AnyObject! {
        print("item::date")
        if activityType == LKActivityTypeAddToCalendar {
            return placeholderItem
        } else {
            return nil
        }
    }
}

class LKCountdownSharingActivityAddToCalendar: UIActivity {

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
        print("canPerform::activityItems: \(activityItems)")
        return true
    }


    override func prepareWithActivityItems(activityItems: [AnyObject]) {
        print("prepare::activityItems: \(activityItems)")
        self.activityItems = activityItems
    }

    override func performActivity() {
        let eventStore = EKEventStore()
        eventStore.requestAccessToEntityType(EKEntityType.Event, completion: { (granted: Bool, error: NSError!) -> Void in
            if !granted {
                print("no access to cal!!!!!!") // TODO: Show error/notification
                //let topViewController = (UIApplication.sharedApplication().keyWindow!.rootViewController as! UINavigationController).topViewController
                let topmostViewController = UIViewController.topmost()
                let alertContoller = UIAlertController(title: "Error", message: "You need to allow Countr to access your calendar. You can change this in settings", preferredStyle: .Alert)

                let openSettingsAction = UIAlertAction(title: "Settings", style: .Default) { (action) in
                    UIApplication.sharedApplication().openURL(NSURL(string: UIApplicationOpenSettingsURLString)!)
                }

                let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel) { (action) in
                    alertContoller.dismissViewControllerAnimated(true, completion: nil)
                }

                alertContoller.addActions([openSettingsAction, cancelAction])

                topmostViewController.presentViewController(alertContoller, animated: true, completion: nil)
                print("topViewController: \(topmostViewController)")
            }

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

            print("performActivity::title: \(title)")
            print("performActivity::date: \(date)")
            print("performActivity::url: \(url)")

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

            var error: NSErrorPointer = nil
            do {
                try eventStore.saveEvent(event, span: EKSpanThisEvent, commit: true)
            } catch var error1 as NSError {
                error.memory = error1
            } catch {
                fatalError()
            }

            if (error != nil) {
                print("error saving the event: \(error)")
            }
        })
    }

}
