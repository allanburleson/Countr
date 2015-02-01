//
//  LKPurchasePremiumFeaturesViewController.swift
//  Countr
//
//  Created by Lukas Kollmer on 1/31/15.
//  Copyright (c) 2015 Lukas Kollmer. All rights reserved.
//

import Foundation
import UIKit
import StoreKit

private let didPurchasePremiumFeaturesKey = "didPurchasePremiumFeatures"
let didPurchasePremiumFeaturesNotificationKey = "didPurchasePremiumFeaturesNotification"

class LKPurchaseManager: NSObject, SKProductsRequestDelegate, SKPaymentTransactionObserver {
    
    let productIdentifier = "countr.premiumfeatures"
    let products: NSSet
    var recivedProduct: [SKProduct] = []
    
    var didFinishLoadingCompletionHandler: () -> () = {}
    var didFinishBuyingProductCompletionHandler: (status: LKPurchaseStatus) -> ()
    
    lazy var tracker = GAI.sharedInstance().defaultTracker
    
    class var didPurchase: Bool {
        get {
            return NSUserDefaults.standardUserDefaults().boolForKey(didPurchasePremiumFeaturesKey)
        }
    }
    
    override init() {
        self.products = NSSet(object: self.productIdentifier)
        self.didFinishBuyingProductCompletionHandler = {(status: LKPurchaseStatus) in}
        super.init()
    }
    
    func load() {
        if SKPaymentQueue.canMakePayments() {
            println("The pyment queue can make paymants, will continue")
            
            var productsRequest = SKProductsRequest(productIdentifiers: self.products)
            productsRequest.delegate = self
            productsRequest.start()
            println("fetching products")
            tracker.send(GAIDictionaryBuilder.createEventWithCategory(purchase_manager_key, action: purchase_manager_load_products_key, label: nil, value: nil).build())
        } else {
            println("The payment queue cannot make paymants, will cancel")
        }
    }
    
    func buy() {
        self.makePurchase(self.recivedProduct[0])
    }
    
    private func makePurchase(product: SKProduct) {
        var payment = SKPayment(product: product)
        SKPaymentQueue.defaultQueue().addTransactionObserver(self)
        SKPaymentQueue.defaultQueue().addPayment(payment)
    }
    
    
    internal func productsRequest(request: SKProductsRequest!, didReceiveResponse response: SKProductsResponse!) {
        
        println("got the request from Apple")
        var count : Int = response.products.count
        if (count>0) {
            var product: SKProduct = response.products[0] as SKProduct
            if (product.productIdentifier == self.productIdentifier){
                println("recived product: \(product)")
                self.recivedProduct = []
                self.recivedProduct.append(product)
                self.didFinishLoadingCompletionHandler()
            }
        } else {
            println("nothing")
        }
    }
    
    internal func paymentQueue(queue: SKPaymentQueue!, updatedTransactions transactions: [AnyObject]!) {
        println("Received Payment Transaction Response from Apple")
        println("transactions: \(transactions)")
        for transaction:AnyObject in transactions {
            if let trans:SKPaymentTransaction = transaction as? SKPaymentTransaction {
                switch trans.transactionState {
                case .Purchased:
                    println("Product Purchased")
                    SKPaymentQueue.defaultQueue().finishTransaction(transaction as SKPaymentTransaction)
                    break
                case .Failed:
                    println("Purchased Failed")
                    SKPaymentQueue.defaultQueue().finishTransaction(transaction as SKPaymentTransaction)
                        break;
                case .Restored:
                    println("Purchase restored")
                default:
                    break
                }
            }
        }
    }
    
    private func didFinishPurchaseWithStatus(status: LKPurchaseStatus) {
        switch status {
        case .Purchased:
            NSUserDefaults.standardUserDefaults().setBool(true, forKey: didPurchasePremiumFeaturesKey)
            NSUserDefaults.standardUserDefaults().synchronize()
            NSNotificationCenter.defaultCenter().postNotificationName(didPurchasePremiumFeaturesNotificationKey, object: nil)
            self.didFinishBuyingProductCompletionHandler(status: status)
            
            tracker.send(GAIDictionaryBuilder.createEventWithCategory(purchase_manager_key, action: purchase_Manager_did_finish_purchase_key, label: purchase_manager_did_purchase_key, value: self.recivedProduct[0].price).build())
        case .Restored:
            NSUserDefaults.standardUserDefaults().setBool(true, forKey: didPurchasePremiumFeaturesKey)
            NSUserDefaults.standardUserDefaults().synchronize()
            NSNotificationCenter.defaultCenter().postNotificationName(didPurchasePremiumFeaturesNotificationKey, object: nil)
            self.didFinishBuyingProductCompletionHandler(status: status)
            tracker.send(GAIDictionaryBuilder.createEventWithCategory(purchase_manager_key, action: purchase_Manager_did_finish_purchase_key, label: purchase_manager_did_restore_key, value: self.recivedProduct[0].price).build())

        case .Cancelled:
            tracker.send(GAIDictionaryBuilder.createEventWithCategory(purchase_manager_key, action: purchase_Manager_did_finish_purchase_key, label: purchase_manager_did_cancel_key, value: self.recivedProduct[0].price).build())

            break
        }
    }
    
}

enum LKPurchaseStatus {
    case Purchased
    case Restored
    case Cancelled
}

