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
    @IBOutlet weak var restoreButton: UIButton!
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descriptionTextView: UITextView!
    
    lazy var store = LKPurchaseManager()
    
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
        
        
        self.titleLabel.text = NSLocalizedString("me.kollmer.countr.purchaseView.titleLabel", comment: "")
        self.descriptionTextView.text = NSLocalizedString("me.kollmer.countr.purchaseView.descriptionTextView", comment: "")

        
        // Notifications + Watch:  \n\n• Notifications: Get notifications when a countdown is about to be finished \n\n• Apple Watch: View all your countdowns on your brand-new apple watch
        let title = NSLocalizedString("me.kollmer.countr.purchaseView.buyButton.loading", comment: "")
        self.buyButton.setTitle(title, forState: .Normal)
        self.buyButton.userInteractionEnabled = false // Ignore taps while the price is loaded
        
        if LKPurchaseManager.didPurchase {
            self.buyButton.enabled = false
            let title = NSLocalizedString("me.kollmer.countr.purchaseView.buyButton.purchased", comment: "")
            self.buyButton.setTitle(title, forState: .Normal)
            self.buyButton.setTitleColor(UIColor.whiteColor(), forState: .Disabled)
            self.restoreButton.hidden = true
            self.restoreButton.setTitle(nil, forState: .Disabled)
            self.restoreButton.enabled = false
            self.restoreButton.frame.size.height = 0
            self.updateViewConstraints() // This does not work (as it seems)
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
            
            let product = self.store.recivedProduct[0]
            
            let numberFormater = NSNumberFormatter()
            numberFormater.formatterBehavior = .Behavior10_4
            numberFormater.numberStyle = .CurrencyStyle
            numberFormater.locale = product.priceLocale
            
            let formattedPrice = numberFormater.stringFromNumber(product.price)!
            
            
            let buttonTitle = NSString(format: NSLocalizedString("me.kollmer.countr.purchaseView.buyButton.price", comment: ""), formattedPrice)
            self.buyButton.setTitle(buttonTitle, forState: .Normal)
        }
        
        self.store.didFinishBuyingProductCompletionHandler = {(status: LKPurchaseStatus) in
            let title = NSLocalizedString("me.kollmer.countr.purchaseView.buyButton.purchased", comment: "")
            self.buyButton.setTitle(title, forState: .Normal)
        }
        
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        self.descriptionTextView.flashScrollIndicators()
    }
    
    
    
    @IBAction func didClickBuyButton(sender: LKRoundBorderedButton) {
        //println("Buy")
        let title = NSLocalizedString("me.kollmer.countr.purchaseView.buyButton.loading", comment: "")
        self.buyButton.setTitle(title, forState: .Normal)
        self.store.buy()
    }
    
    @IBAction func didTapRestoreButton(sender: UIButton) {
        self.store.restore()
    }
    
    func cancelButtonPressed() {
        // TODO: GA Tracking
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
}