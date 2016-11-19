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
    
    private let productIdentifier = "countr.premiumfeatures"
    private let products: Set<String>
    var recivedProduct: [SKProduct] = []
    
    var didFinishLoadingCompletionHandler: () -> () = {}
    var didFinishBuyingProductCompletionHandler: (status: LKPurchaseStatus) -> ()
    
    lazy private var tracker = GAI.sharedInstance().defaultTracker
    
    /**
    A Bool indicating if the user has already purchased the premium features
    */
    class var didPurchase: Bool {
        get {
            let purchased = NSUbiquitousKeyValueStore.defaultStore().boolForKey(didPurchasePremiumFeaturesKey)
            //println("did purchase: \(purchased)")
            return purchased
        }
    }
    
    override init() {
        self.products = Set(arrayLiteral: self.productIdentifier)
        self.didFinishBuyingProductCompletionHandler = {(status: LKPurchaseStatus) in}
        super.init()
    }
    
    /**
    Load the products from the store
    */
    func load() {
        if SKPaymentQueue.canMakePayments() {
            //println("The pyment queue can make paymants, will continue")
            var productsRequest = SKProductsRequest(productIdentifiers: self.products)
            productsRequest.delegate = self
            productsRequest.start()
            //println("fetching products")
            //tracker.send(GAIDictionaryBuilder.createEventWithCategory(purchase_manager_key, action: purchase_manager_load_products_key, label: nil, value: nil).build())
        } else {
            //println("The payment queue cannot make paymants, will cancel")
        }
    }
    
    /**
    Buy the premium features IAP
    */
    func buy() {
        self.makePurchase(self.recivedProduct[0])
    }
    
    /**
    Restore a previously made IAP
    */
    func restore() {
        SKPaymentQueue.defaultQueue().addTransactionObserver(self)
        SKPaymentQueue.defaultQueue().restoreCompletedTransactions()
    }
    
    private func makePurchase(product: SKProduct) {
        let payment = SKPayment(product: product)
        SKPaymentQueue.defaultQueue().addTransactionObserver(self)
        SKPaymentQueue.defaultQueue().addPayment(payment)
    }
    
    
    internal func productsRequest(request: SKProductsRequest, didReceiveResponse response: SKProductsResponse) {
        
        //println("got the request from Apple")
        let count : Int = response.products.count
        if (count>0) {
            let product: SKProduct = response.products[0] 
            if (product.productIdentifier == self.productIdentifier){
                //println("recived product: \(product)")
                self.recivedProduct = []
                self.recivedProduct.append(product)
                self.didFinishLoadingCompletionHandler()
            }
        } else {
            //println("nothing")
        }
    }
    
    internal func paymentQueue(queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        //println("Received Payment Transaction Response from Apple")
        //println("transactions: \(transactions)")
        for transaction:AnyObject in transactions {
            if let trans:SKPaymentTransaction = transaction as? SKPaymentTransaction {
                switch trans.transactionState {
                case .Purchased:
                    //println("Product Purchased")
                    SKPaymentQueue.defaultQueue().finishTransaction(transaction as! SKPaymentTransaction)
                    self.didFinishPurchaseWithStatus(.Purchased)
                    break
                case .Failed:
                    //println("Purchased Failed")
                    SKPaymentQueue.defaultQueue().finishTransaction(transaction as! SKPaymentTransaction)
                    self.didFinishPurchaseWithStatus(.Failed)
                        break;
                case .Restored:
                    //println("Purchase restored")
                    self.didFinishPurchaseWithStatus(.Restored)
                default:
                    break
                }
            }
        }
    }
    
    internal func paymentQueue(queue: SKPaymentQueue, restoreCompletedTransactionsFailedWithError error: NSError) {
        //println("paymentQueue:restoreCompletedTransactionsFailedWithError")
        //println("error: \(error)")
        //println("localizedDescription: \(error.localizedDescription)")
    }
    
    internal func paymentQueueRestoreCompletedTransactionsFinished(queue: SKPaymentQueue) {
        //println("paymentQueueRestoreCompletedTransactionsFinished")
        self.didFinishPurchaseWithStatus(.Restored)
    }
    
    private func didFinishPurchaseWithStatus(status: LKPurchaseStatus) {
        let model = LKModel.sharedInstance
        //println("didFinishPurchaseWithStatus")
        switch status {
        case .Purchased:
            NSUbiquitousKeyValueStore.defaultStore().setBool(true, forKey: didPurchasePremiumFeaturesKey)
            NSUbiquitousKeyValueStore.defaultStore().synchronize()
            NSNotificationCenter.defaultCenter().postNotificationName(didPurchasePremiumFeaturesNotificationKey, object: nil)
            self.didFinishBuyingProductCompletionHandler(status: status)
            
            //tracker.send(GAIDictionaryBuilder.createEventWithCategory(purchase_manager_key, action: purchase_Manager_did_finish_purchase_key, label: purchase_manager_did_purchase_key, value: self.recivedProduct[0].price).build())
        case .Restored:
            NSUbiquitousKeyValueStore.defaultStore().setBool(true, forKey: didPurchasePremiumFeaturesKey)
            NSUbiquitousKeyValueStore.defaultStore().synchronize()
            NSNotificationCenter.defaultCenter().postNotificationName(didPurchasePremiumFeaturesNotificationKey, object: nil)
            self.didFinishBuyingProductCompletionHandler(status: status)
            //tracker.send(GAIDictionaryBuilder.createEventWithCategory(purchase_manager_key, action: purchase_Manager_did_finish_purchase_key, label: purchase_manager_did_restore_key, value: self.recivedProduct[0].price).build())

        case .Cancelled:
            //tracker.send(GAIDictionaryBuilder.createEventWithCategory(purchase_manager_key, action: purchase_Manager_did_finish_purchase_key, label: purchase_manager_did_cancel_key, value: self.recivedProduct[0].price).build())

            break
        case .Failed:
            break
        }
    }

}

/**
An Enum representing the possible values of a purchase.

-  Purchased
-  Restored
-  Cancelled
-  Failed
*/
enum LKPurchaseStatus {
    case Purchased
    case Restored
    case Cancelled
    case Failed
}

