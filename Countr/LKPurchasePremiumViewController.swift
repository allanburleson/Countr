//
//  LKPurchasePremiumViewController.swift
//  Countr
//
//  Created by Lukas Kollmer on 2/1/15.
//  Copyright (c) 2015 Lukas Kollmer. All rights reserved.
//

import Foundation
import UIKit


enum LKPurchaseViewControllerSender {
    case InfoViewController
    case PurchaseCell
}

class LKPurchasePremiumViewController: UIViewController {
    
    @IBOutlet weak var buyButton: LKRoundBorderedButton!
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descriptionTextView: UITextView!
    
    let store = LKPurchaseManager()
    
    lazy var tracker = GAI.sharedInstance().defaultTracker
    
    var sender: LKPurchaseViewControllerSender! {
        didSet {
            if self.sender == .PurchaseCell {
                let cancelButton = UIBarButtonItem(barButtonSystemItem: .Cancel, target: self, action: Selector("cancelButtonPressed"))
                self.navigationItem.leftBarButtonItem = cancelButton
            }
        }
    }
    
    
    
    override func loadView() {
        super.loadView()
        self.view.backgroundColor = UIColor.backgroundColor()
        self.descriptionTextView.backgroundColor = UIColor.backgroundColor()
        self.titleLabel.font = UIFont(name: "Avenir-Book", size: 19)
        self.descriptionTextView.font = UIFont(name: "Avenir-Book", size: 15)
        self.descriptionTextView.editable = false
        self.descriptionTextView.selectable = false
        self.descriptionTextView.indicatorStyle = .White
        self.buyButton.tintColor = UIColor.whiteColor()
        
        
        self.descriptionTextView.text = "• Multiple Countdowns: Add more than 2 countdowns \n\n• iCloud sync: Keep all your countdowns in sync across all your devices \n\n• Remove Ads: Use the whole app without the banner ad at teh bottom of the screen \n\n• Notifications: Get notifications when a countdown is about to be finished \n\n• Apple Watch: View all your countdowns on your brand-new apple watch"
        self.buyButton.setTitle("Loading", forState: .Normal)
        self.buyButton.userInteractionEnabled = false // Ignore taps while the price is loaded
        
        if LKPurchaseManager.didPurchase {
            self.buyButton.enabled = false
            self.buyButton.setTitle("PURCHASED", forState: .Normal)
            self.buyButton.setTitleColor(UIColor.whiteColor(), forState: .Disabled)
        } else {
            self.store.load()
        }
        
        // Google Analytics
        tracker.set(kGAIScreenName, value: "PurchasePremium")
        tracker.send(GAIDictionaryBuilder.createScreenView().build())

    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.store.didFinishLoadingCompletionHandler = {
            self.buyButton.userInteractionEnabled = true
            self.buyButton.setTitle("Buy for $\(self.store.recivedProduct[0].price)", forState: .Normal)
        }
        
        self.store.didFinishBuyingProductCompletionHandler = {(status: LKPurchaseStatus) in
            self.buyButton.setTitle("PURCHASED", forState: .Normal)
        }
        
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        self.descriptionTextView.flashScrollIndicators()
    }
    
    
    
    @IBAction func didClickBuyButton(sender: LKRoundBorderedButton) {
        println("Buy")
        self.store.buy()
    }
    
    
    func cancelButtonPressed() {
        // TODO: GA Tracking
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
}