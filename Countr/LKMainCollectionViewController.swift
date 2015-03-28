//
//  LKMainCollectionView.swift
//  Countr
//
//  Created by Lukas Kollmer on 30/11/14.
//  Copyright (c) 2014 Lukas Kollmer. All rights reserved.
//

import Foundation
import UIKit

class LKMainCollectionViewController: UICollectionViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    let countdownManager = LKCountdownManager.sharedInstance
    
    lazy var tracker = GAI.sharedInstance().defaultTracker
    
    var refreshControl = UIRefreshControl()
    
    
    
    var updateTimer: NSTimer?
    
    override func loadView() {
        super.loadView()


        /*
            NOTE: The default contentInset is 64. If you want to get more than 64 (in this case 85), you have to set the difference (85-64=21) as the "new" contentInsetn
        */
        //self.collectionView?.contentInset = UIEdgeInsetsMake(21, 0, 0, 0)
        //self.collectionView?.scrollIndicatorInsets = UIEdgeInsetsMake(18, 0, 10, 0)

        /*
        NOTE: The default scrollIndicatorInsets is -5. If you want to get 10 , you have to set the new inset + 5
        */
        //if LKPurchaseManager.didPurchase {
        //    self.collectionView?.scrollIndicatorInsets = UIEdgeInsetsMake(18, 0, 10, 0)
        //} else {
        //    self.collectionView?.scrollIndicatorInsets = UIEdgeInsetsMake(18, 0, 62, 0)
        //}
        adjustInsets()
        self.collectionView?.indicatorStyle = .White

        
        
        self.refreshControl.addTarget(self, action: Selector("refresh"), forControlEvents: UIControlEvents.ValueChanged)
        self.refreshControl.tintColor = UIColor.whiteColor()
        self.collectionView?.addSubview(self.refreshControl)

        
        self.countdownManager.didAddNewItemCompletionClosure = { (item: LKCountdownItem) in
            //println("did add new item: \(item.description)")
            //self.countdownManager.reload()
            //self.collectionView?.insertItemsAtIndexPaths([NSIndexPath(forItem: 0, inSection: 0)])
            self.collectionView?.reloadData()
            self.reloadEmptyDataMessage()
            self.disableAddButtonIfNeeded()
            self.startUpdates()
            
            self.tracker.send(GAIDictionaryBuilder.createEventWithCategory(countdown_manager_key, action: did_add_new_item_key, label: "", value: nil).build()) // TODO: set the item kind
            
        }
        
        
        // NOTE: Not needed, use delete function in cellForItemAtIndexPath instead
        
        //self.countdownManager.didDeleteItemCompletionClosure = { (item: LKCountdownItem) in
        //    self.disableAddButtonIfNeeded()
        //    self.reloadEmptyDataMessage()
        //}
        
        self.countdownManager.updateCompletionClosure = {
            //println("did update values")
            //self.collectionView?.reloadData()
            self.update()
        }
        
        self.countdownManager.didDeleteAllItemsCompletionClosure = {
            self.reloadEmptyDataMessage()
            self.countdownManager.reload()
            self.collectionView?.reloadData()
            self.disableAddButtonIfNeeded()
        }

        self.countdownManager.startUpdates()
        
        let notificationCenter = NSNotificationCenter.defaultCenter()
        
        notificationCenter.addObserver(self, selector: "modelDidLoadItems", name: modelDidLoadItemsKey, object: nil)
        notificationCenter.addObserver(self, selector: "refresh", name: refreshUIKey, object: nil)
        notificationCenter.addObserver(self, selector: "refresh", name: didDeleteAllItemsKey, object: nil)
        notificationCenter.addObserver(self, selector: "didPurchasePremiumFeatures", name: didPurchasePremiumFeaturesNotificationKey, object: nil)
        

    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.reloadEmptyDataMessage()
    }
    
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        disableAddButtonIfNeeded()
        
        if self.countdownManager.numberOfItems > 0 {
            self.startUpdates()
        }
    }

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)

        self.collectionView?.flashScrollIndicators()
        
        // Google Analytics
        tracker.set(kGAIScreenName, value: "MainCollectionView")
        tracker.send(GAIDictionaryBuilder.createScreenView().build())
        
        
    
    }
    
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        
        self.stopUpdates()
    }
    
    func didLongPress() {
        //println("didLongPressOnMainScreen")
    }
    
    func refresh() {
        //println("refresh")
        self.reloadEmptyDataMessage()
        self.countdownManager.reload()
        self.collectionView?.reloadData()
        self.refreshControl.endRefreshing()
    }
    
    func disableAddButtonIfNeeded() {
        if !self.countdownManager.canAddCountdowns {
            //println("at limit. Add button will be disabled")
            //self.addButton.enabled = false
            (self.parentViewController as LKMainViewController).addButton.enabled = false
        } else {
            //self.addButton.enabled = true
            (self.parentViewController as LKMainViewController).addButton.enabled = true
        }

    }
    func startUpdates() {
        self.updateTimer = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: Selector("update"), userInfo: nil, repeats: true)
    }
    
    func stopUpdates() {
        self.updateTimer?.invalidate()
        self.updateTimer = nil
    }

    func reloadEmptyDataMessage() {
        self.countdownManager.reload()
        if self.countdownManager.items().isEmpty {
            let messageLabel = UILabel()
            messageLabel.text = NSLocalizedString("me.kollmer.countr.mainView.noDataAddedYetLabel", comment: "")
            messageLabel.textAlignment = .Center
            messageLabel.textColor = UIColor.whiteColor()
            messageLabel.font = UIFont(name: "Avenir-Book", size: 26)
            self.collectionView?.backgroundView = messageLabel
        } else {
            let view = UIView()
            self.collectionView?.backgroundView = view
        }
    }
    
    func update() {
        if let visible = self.collectionView?.indexPathsForVisibleItems() {
            //println("visiblecells: \(visible)")
            for object in visible {
                //println("in the for loop")
                let indexPath: NSIndexPath = object as NSIndexPath
                //println("Will update item \(indexPath.item) in section: \(indexPath.section)")
                let cell = self.collectionView?.cellForItemAtIndexPath(indexPath)
                //println("cell.tag: \(cell?.tag)")
                if cell?.tag == countdown_cell_tag {
                    self.countdownManager.updateCellAtItem(indexPath.item)
                    (self.collectionView?.cellForItemAtIndexPath(indexPath) as LKItemCell).updateTimeRemainignLabel()
                }
            }
        }
        /*
        var items: Int = self.collectionView?.numberOfItemsInSection(0) as Int!
        //items++
        for var i = 1; i <= items; ++i {
            //println("index is \(i) of \(items)")
            let indexPaths = self.collectionView?.indexPathsForVisibleItems()
            for object in indexPaths {
                let indexPath: NSIndexPath = object as NSIndexPath
            }
            let itemInt =  i - 1
            let indexPath = NSIndexPath(forItem: itemInt, inSection: 0)
            self.collectionView?.indexPathsForVisibleItems().count
            //println("created indexPath: item= \(indexPath.item), section= \(indexPath.section)")
            //let cell: LKItemCell = self.collectionView?.cellForItemAtIndexPath(indexPath) as LKItemCell
            
            (self.collectionView?.cellForItemAtIndexPath(indexPath) as LKItemCell).updateTimeRemainignLabel()
            
            // The crash is caused by the fact that not all cells are visible.

        }
*/
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "addNewItem" {
            //println("addNewItem")
            self.tracker.send(GAIDictionaryBuilder.createEventWithCategory(ui_action_key, action: button_press_key, label: add_new_item_button_key, value: nil).build())
        }
    }
    
    
    override func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if LKPurchaseManager.didPurchase {
            return self.countdownManager.numberOfItems
        } else {
            return self.countdownManager.numberOfItems + 1
        }
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAtIndex section: Int) -> UIEdgeInsets {
        return UIEdgeInsetsMake(0, 30, 0, 30)
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAtIndex section: Int) -> CGFloat {
        return 80
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAtIndex section: Int) -> CGFloat {
        return 20
    }
    
    
    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        if (indexPath.item >= self.countdownManager.numberOfItems) || (indexPath.item == 0 && self.countdownManager.numberOfItems == 0) {
            // The purchase item
            //println("The purchase item")
            let nib = UINib(nibName: "LKPurchasePremiumCell", bundle: nil)
            collectionView.registerClass(LKPurchasePremiumCell.self, forCellWithReuseIdentifier: "purchasePremiumCell")
            collectionView.registerNib(nib, forCellWithReuseIdentifier: "purchasePremiumCell")
            
            let cell: LKPurchasePremiumCell = collectionView.dequeueReusableCellWithReuseIdentifier("purchasePremiumCell", forIndexPath: indexPath) as LKPurchasePremiumCell
            
            cell.tag = purchase_cell_tag
            
            cell.shortPressAction = {
                
                // Google Analytics
                self.tracker.send(GAIDictionaryBuilder.createEventWithCategory(ui_action_key, action: select_collection_view_cell_short_press_key, label: nil, value: nil).build())
                
                let purchasePremiumViewController: LKPurchasePremiumViewController = self.storyboard?.instantiateViewControllerWithIdentifier("purchasePremiumViewController") as LKPurchasePremiumViewController
                let navigationController = UINavigationController(rootViewController: purchasePremiumViewController)
                purchasePremiumViewController.modalPresentationStyle = UIModalPresentationStyle.FormSheet
                navigationController.modalPresentationStyle = .FormSheet
                purchasePremiumViewController.sender = .PurchaseCell
                
                // TODO: Add a cancel button to the navBar in order ti dismiss th epurchaseViewController
            self.showDetailViewController(navigationController, sender: self)
            }
            
            return cell
        }
        
        //println("will load cell for item \(indexPath.item) in section \(indexPath.section)")
        //println("name for this item: \(self.countdownManager.items()[indexPath.item].name)")
        
        let nib = UINib(nibName: "LKItemCell", bundle: nil)
        collectionView.registerClass(LKItemCell.self, forCellWithReuseIdentifier: "itemCell")
        collectionView.registerNib(nib, forCellWithReuseIdentifier: "itemCell")
        
        let cell: LKItemCell = collectionView.dequeueReusableCellWithReuseIdentifier("itemCell", forIndexPath: indexPath) as LKItemCell
        
        cell.tag = countdown_cell_tag
        
        //println("will load the item for the cell")
        cell.countdownItem = self.countdownManager.items()[indexPath.item]
        
        cell.longPressAction = {
            self.countdownManager.endUpdates()
            
            self.tracker.send(GAIDictionaryBuilder.createEventWithCategory(ui_action_key, action: button_press_key, label: select_collection_view_cell_long_press_key, value: nil).build())
            
            let indexPath = collectionView.indexPathForCell(cell)!

            let alertTitle = NSLocalizedString("me.kollmer.countr.deleteItemAlert.title", comment: "")
            let alertMessage = NSString(format: NSLocalizedString("me.kollmer.countr.deleteItemAlert.message", comment: ""), self.countdownManager.items()[indexPath.item].name)
            let alertDelete = NSLocalizedString("me.kollmer.countr.deleteItemAlert.delete", comment: "")
            let alertCancel = NSLocalizedString("me.kollmer.countr.deleteItemAlert.cancel", comment: "")
            let alertController = LKAlertController.actionSheetWithTitle(alertTitle, message: alertMessage)
            alertController.popoverPresentationController?.sourceView = cell
            alertController.popoverPresentationController?.sourceRect = cell.bounds
            //println("cell.frame: \(cell.frame)")
            //println("alertController.popoverPresentationController?.sourceRect: \(alertController.popoverPresentationController?.sourceRect)")
            
            let cancelAction = UIAlertAction(title: alertCancel, style: .Cancel) { (action) in
                //println(action)
                self.countdownManager.startUpdates()
            }
            
            
            let deleteAction = UIAlertAction(title: alertDelete, style: .Destructive) { (action) in
                //println(action)
                self.countdownManager.deleteCountdownItem(self.countdownManager.items()[indexPath.item])
                
                if self.countdownManager.items().count > 1 {
                    self.collectionView?.deleteItemsAtIndexPaths([indexPath])
                } else {
                    self.collectionView?.reloadData()
                }
                self.reloadEmptyDataMessage()
                self.disableAddButtonIfNeeded()
                self.countdownManager.startUpdates()
                
                self.tracker.send(GAIDictionaryBuilder.createEventWithCategory(countdown_manager_key, action: did_delete_item_key, label: nil, value: nil).build())
            }
            
            alertController.addAction(cancelAction)
            alertController.addAction(deleteAction)
            
            self.presentViewController(alertController, animated: true, completion: nil)

        }
        
        //println(cell)
        return cell
    }
    
    override func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        //println("did select cell at indexpath\(indexPath)")
        //println("did select cell in section \(indexPath.section) and item \(indexPath.item)")
        /*
        self.countdownManager.endUpdates()
        
        
        let alertController = UIAlertController(title: "Delete Item", message: "Do you really want to delete the countdown \(self.countdownManager.items()[indexPath.row].name)", preferredStyle: UIAlertControllerStyle.Alert)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel) { (action) in
            //println(action)
            self.countdownManager.startUpdates()
        }
        
        
        let deleteAction = UIAlertAction(title: "Delete", style: .Destructive) { (action) in
            //println(action)
            self.countdownManager.deleteCountdownItem(self.countdownManager.items()[indexPath.row])
            
            if self.countdownManager.items().count > 1 {
                self.collectionView?.deleteItemsAtIndexPaths([indexPath])
            } else {
                self.collectionView?.reloadData()
            }
            self.countdownManager.startUpdates()
        }
        
        alertController.addAction(cancelAction)
        alertController.addAction(deleteAction)
        
        self.presentViewController(alertController, animated: true, completion: nil)
*/
    
    }
    
    func modelDidLoadItems() {
        //println("modelDidLoadItems")
        self.refresh()
        adjustInsets()
    }
    
    
    func didPurchasePremiumFeatures() {
        self.refresh()
        adjustInsets()
    }

    func adjustInsets() {
        if LKPurchaseManager.didPurchase {
            self.collectionView?.contentInset = UIEdgeInsetsMake(21, 0, 15, 0)
            self.collectionView?.scrollIndicatorInsets = UIEdgeInsetsMake(21, 0, 15, 0)
        } else {
            self.collectionView?.contentInset = UIEdgeInsetsMake(21, 0, 75, 0)
            self.collectionView?.scrollIndicatorInsets = UIEdgeInsetsMake(21, 0, 70, 0)
        }
        
        
    }
    
    
}
