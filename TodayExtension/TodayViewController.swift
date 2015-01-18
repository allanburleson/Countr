//
//  TodayViewController.swift
//  TodayExtension
//
//  Created by Lukas Kollmer on 1/17/15.
//  Copyright (c) 2015 Lukas Kollmer. All rights reserved.
//

import UIKit
import CoreData
import NotificationCenter

class TodayViewController: UIViewController, NCWidgetProviding {
    
    let countdownManager = LKCountdownManager.sharedInstance
    
    var timer: NSTimer!
    
    var itemsCached: [LKCountdownItem] = []
    
    @IBOutlet var allLabels: [UILabel]!
    @IBOutlet var countdownRemainingLabels: [UILabel]!
    @IBOutlet var countdownTitleLabels: [UILabel]!
    
    @IBOutlet var itemOneLabels: [UILabel]!
    @IBOutlet var itemTwoLabels: [UILabel]!
    @IBOutlet var itemThreeLabels: [UILabel]!
    
    @IBOutlet weak var messageLabel: UILabel!
    
    override func loadView() {
        super.loadView()
        println("loadView")
        
        
        self.preferredContentSize = CGSizeMake(320, 246)
        
    }
        
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view from its nib.
        println("data loaded in extension: \(self.countdownManager.items())")
        println("number of items loaded in teh \(self.countdownManager.items().count)")
        
        for label in self.countdownRemainingLabels {
            label.font = UIFont(name: "Avenir-Book", size: 20)
        }
        
        for label in self.countdownTitleLabels {
            label.font = UIFont(name: "Avenir-Book", size: 17)
        }
        
        switch self.countdownManager.numberOfItems {
        case 0:
            for label in self.allLabels {
                label.hidden = true
                label.text = nil
                label.frame = CGRectZero
                self.preferredContentSize = CGSizeMake(0, 40)
            }
            break
        case 1:
            break
        case 2:
            break
        case 3:
            break
        default:
            // More than 3 items
            break
            
        }
        
        /*
        for label in self.countdownTitleLabels {
            let index = find(self.countdownTitleLabels, label)!
            self.countdownTitleLabels[index].text = self.countdownManager.items()[index].name
        }
*/
        
        self.itemsCached = self.countdownManager.items()
        
        
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        //startTimer()
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        stopTimer()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func widgetPerformUpdateWithCompletionHandler(completionHandler: ((NCUpdateResult) -> Void)!) {
        // Perform any setup necessary in order to update the view.

        // If an error is encountered, use NCUpdateResult.Failed
        // If there's no update required, use NCUpdateResult.NoData
        // If there's an update, use NCUpdateResult.NewData

        completionHandler(NCUpdateResult.NewData)
    }
    
    
    func startTimer() {
        self.timer = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: "update", userInfo: nil, repeats: true)
    }
    
    
    func stopTimer() {
        
    }
    
    func update() {
        for item in self.itemsCached {
            item.updateTimeRemaining()
        }
        
        for label in self.countdownRemainingLabels {
            let index = find(self.countdownRemainingLabels, label)!
            self.countdownTitleLabels[index].text = self.countdownManager.items()[index].remaining.asString
        }
    }
    
    
}
