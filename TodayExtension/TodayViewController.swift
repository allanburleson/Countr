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
    
    //let countdownManager = LKCountdownManager.sharedInstance
    let extensionDataManager = LKSharedExtensionDataManager()
    
    var timer: NSTimer?
    
    var itemsCached: [LKCountdownItem] = []
    
    @IBOutlet var gestureRecognizer: [UITapGestureRecognizer]!
    @IBOutlet var backgroundViews: [UIView]!
    @IBOutlet var allLabels: [UILabel]!
    @IBOutlet var countdownRemainingLabels: [UILabel]!
    @IBOutlet var countdownTitleLabels: [UILabel]!
    
    @IBOutlet var itemOneLabels: [UILabel]!
    @IBOutlet var itemTwoLabels: [UILabel]!
    @IBOutlet var itemThreeLabels: [UILabel]!
    @IBOutlet var itemTwoLayoutConstraints: [NSLayoutConstraint]!
    @IBOutlet var itemThreeLayoutConstraints: [NSLayoutConstraint]!
    
    @IBOutlet weak var messageLabel: UILabel!
    
    override func loadView() {
        super.loadView()
        //println("loadView")
        
        for view in self.backgroundViews {
            view.hidden = true
            view.frame = CGRectZero
            view.removeFromSuperview()
        }
        
        self.messageLabel.font = UIFont.systemFontOfSize(17)
        self.messageLabel.text = NSLocalizedString("me.kollmer.countr.todayExtension.emptyTableMessage", comment: "")
        
        for label in allLabels {
            label.text = ""
        }
        
        self.itemsCached = self.extensionDataManager.loadCountdownItemsForExtensionWithType(.TodayExtension)
        
        if !self.itemsCached.isEmpty {
            startTimer()
        }
        
    }
        
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view from its nib.
        
        
        /*
        for label in self.countdownTitleLabels {
            let index = find(self.countdownTitleLabels, label)!
            self.countdownTitleLabels[index].text = self.countdownManager.items()[index].name
        }
        
        // TODO: [MAYBE] Create a second timer which checks for new/deletd content every 10-20 seconds
*/
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        //println("viewDidAppear")
        self.view.updateConstraints()
        
        //println("data loaded in extension: \(self.countdownManager.items())")
        //println("number of items loaded in teh \(self.countdownManager.items().count)")
        
        configureViewForCountdownItems()
        
        //let _tempTimer = NSTimer.scheduledTimerWithTimeInterval(5, target: self, selector: "log_view", userInfo: nil, repeats: false)
    }
    
    func log_view() {
        //println("\n\n\n")
        //println("------Section 1------")
        //println("**countdownLabel** \nText: \(self.countdownRemainingLabels[0].text), \nframe: \(self.countdownRemainingLabels[0].frame), \nhidden: \(self.countdownRemainingLabels[0].hidden), \nlayoutConstraints: \(self.countdownRemainingLabels[0].constraints())")
        //println("\n")
        //println("**titleLabel** \nText: \(self.countdownTitleLabels[0].text), \nframe: \(self.countdownTitleLabels[0].frame), \nhidden: \(self.countdownTitleLabels[0].hidden), \nlayoutConstraints: \(self.countdownTitleLabels[0].constraints())")
        //println("\n\n")
        //println("------Section 2------")
        //println("**countdownLabel** \nText: \(self.countdownRemainingLabels[1].text), \nframe: \(self.countdownRemainingLabels[1].frame), \nhidden: \(self.countdownRemainingLabels[1].hidden), \nlayoutConstraints: \(self.countdownRemainingLabels[1].constraints())")
        //println("\n")
        //println("**titleLabel** \nText: \(self.countdownTitleLabels[1].text), \nframe: \(self.countdownTitleLabels[1].frame), \nhidden: \(self.countdownTitleLabels[1].hidden), \nlayoutConstraints: \(self.countdownTitleLabels[1].constraints())")
        //println("\n\n")
        //println("------Section 3------")
        //println("**countdownLabel** \nText: \(self.countdownRemainingLabels[2].text), \nframe: \(self.countdownRemainingLabels[2].frame), \nhidden: \(self.countdownRemainingLabels[2].hidden), \nlayoutConstraints: \(self.countdownRemainingLabels[2].constraints())")
        //println("\n")
        //println("**titleLabel** \nText: \(self.countdownTitleLabels[2].text), \nframe: \(self.countdownTitleLabels[2].frame), \nhidden: \(self.countdownTitleLabels[2].hidden), \nlayoutConstraints: \(self.countdownTitleLabels[2].constraints())")
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
    
    func configureViewForCountdownItems() {
        //println("data loaded in extension: \(self.countdownManager.items())")
        //println("number of items loaded in teh \(self.countdownManager.items().count)")
        
        //for view in self.backgroundViews {
        //    view.alpha = 0.00000001
        //}
        
        for label in self.countdownRemainingLabels {
            label.font = UIFont.systemFontOfSize(20)
        }
        
        for label in self.countdownTitleLabels {
            label.font = UIFont.systemFontOfSize(17)
        }
        self.messageLabel.hidden = true
        
        switch self.itemsCached.count {
        case 0:
            for label in self.allLabels {
                label.hidden = true
                label.text = nil
                label.frame = CGRectZero
            }
            
            for view in self.backgroundViews {
                view.hidden = true
                view.frame = CGRectZero
                view.removeFromSuperview()
            }
            self.messageLabel.hidden = false
            
            self.preferredContentSize = CGSizeMake(0, 82)
            break
        case 1:
            
            for label in self.itemTwoLabels {
                label.hidden = true
                label.text = nil
                label.frame = CGRectZero
            }
            
            for label in self.itemThreeLabels {
                label.hidden = true
                label.text = nil
                label.frame = CGRectZero
            }
            
            for constraint in self.itemTwoLayoutConstraints {
                constraint.constant = 0
            }
            
            for constraint in self.itemThreeLayoutConstraints {
                constraint.constant = 0
            }
            
            self.preferredContentSize = CGSizeMake(0, 82)
            break
        case 2:
            for label in self.itemThreeLabels {
                label.hidden = true
                label.text = nil
                label.frame = CGRectZero
            }
            for constraint in self.itemThreeLayoutConstraints {
                constraint.constant = 0
            }
            
            self.preferredContentSize = CGSizeMake(0, 164)
            break
        case 3:
            break
        default:
            // More than 3 items
            break
            
        }
        
        // Set the titles
        for item in self.itemsCached {
            let index = find(self.itemsCached, item)!
            self.countdownTitleLabels[index].text = item.title
        }
        
        self.updateViewConstraints()

    }
    
    
    
    func startTimer() {
        self.timer = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: "update", userInfo: nil, repeats: true)
    }
    
    
    func stopTimer() {
        self.timer?.invalidate()
        self.timer = nil
    }
    
    func update() {
        for item in self.itemsCached {
            //println("in the loop")
            item.updateTimeRemaining()
            let index = find(self.itemsCached, item)!
            self.countdownRemainingLabels[index].text = item.remaining.asString
        }
        

        
    }
    
    /*
    // MARK: UI Interaction
    @IBAction func didTapGestureRecognizer(sender: UITapGestureRecognizer) {
        switch sender {
        case self.gestureRecognizer[0]:
            //println("did tap the first view")
            break
        case self.gestureRecognizer[1]:
            //println("did tap the second view")
            break
        case self.gestureRecognizer[2]:
            //println("did tap the third view")
            break
        default:
            break
        }
    }
*/
    
    func widgetMarginInsetsForProposedMarginInsets(defaultMarginInsets: UIEdgeInsets) -> UIEdgeInsets {
        //println("default edge insets: top: \(defaultMarginInsets.top), left: \(defaultMarginInsets.left), bottom: \(defaultMarginInsets.bottom), right: \(defaultMarginInsets.right)")
        return UIEdgeInsetsMake(0, 47, 0, 0)
    }
    
    
}
