//
//  LKMainCollectionView.swift
//  Countr
//
//  Created by Lukas Kollmer on 30/11/14.
//  Copyright (c) 2014 Lukas Kollmer. All rights reserved.
//

import Foundation
import UIKit

class LKMainCollectionViewController: UICollectionViewController, UICollectionViewDataSource, UICollectionViewDelegate {
    
    let countdownManager = LKCountdownManager.sharedInstance
    
    var updateTimer: NSTimer?
    
    override func loadView() {
        super.loadView()
        
        let refreshButton = UIBarButtonItem(barButtonSystemItem: .Refresh, target: self, action: Selector("refresh"))
        self.navigationItem.leftBarButtonItem = refreshButton
        //println(self.countdownManager.hash)
        self.countdownManager.didAddNewItemConpletionClosure = {
            //println("did add new item")
            
        }
        
        self.countdownManager.updateCompletionClosure = {
            println("did update values")
            //self.collectionView?.reloadData()
            self.update()
        }
        
        self.countdownManager.startUpdates()
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "modelDidLoadItems", name: modelDidLoadItemsKey, object: nil)
        


        //self.updateTimer = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: Selector("update"), userInfo: nil, repeats: true)
        

    }
    
    func refresh() {
        println("refresh")
        self.countdownManager.reload()
        self.collectionView?.reloadData()
    }
    
    func update() {
        if let visible = self.collectionView?.indexPathsForVisibleItems() {
            for object in visible {
                println("in the for loop")
                let indexPath: NSIndexPath = object as NSIndexPath
                self.countdownManager.updateCellAtItem(indexPath.item)
                (self.collectionView?.cellForItemAtIndexPath(indexPath) as LKItemCell).updateTimeRemainignLabel()
            }
        }
        /*
        var items: Int = self.collectionView?.numberOfItemsInSection(0) as Int!
        //items++
        for var i = 1; i <= items; ++i {
            println("index is \(i) of \(items)")
            let indexPaths = self.collectionView?.indexPathsForVisibleItems()
            for object in indexPaths {
                let indexPath: NSIndexPath = object as NSIndexPath
            }
            let itemInt =  i - 1
            let indexPath = NSIndexPath(forItem: itemInt, inSection: 0)
            self.collectionView?.indexPathsForVisibleItems().count
            println("created indexPath: item= \(indexPath.item), section= \(indexPath.section)")
            //let cell: LKItemCell = self.collectionView?.cellForItemAtIndexPath(indexPath) as LKItemCell
            
            (self.collectionView?.cellForItemAtIndexPath(indexPath) as LKItemCell).updateTimeRemainignLabel()
            
            // The crash is caused by the fact that not all cells are visible.

        }
*/
    }
    
    
    override func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.countdownManager.numberOfItems
    }
    
    
    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        
        let nib = UINib(nibName: "LKItemCell", bundle: nil)
        collectionView.registerClass(LKItemCell.self, forCellWithReuseIdentifier: "itemCell")
        collectionView.registerNib(nib, forCellWithReuseIdentifier: "itemCell")
        
        let cell: LKItemCell = collectionView.dequeueReusableCellWithReuseIdentifier("itemCell", forIndexPath: indexPath) as LKItemCell
        
        println("will load the item for the cell")
        cell.countdownItem = self.countdownManager.items()[indexPath.item]
        
        //println(cell)
        return cell
    }
    
    override func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        //println("did select cell at indexpath\(indexPath)")
        //println("did select cell in section \(indexPath.section) and item \(indexPath.item)")
        self.countdownManager.endUpdates()
        
        
        let alertController = UIAlertController(title: "Delete Item", message: "Do you really want to delete the countdown \(self.countdownManager.items()[indexPath.row].name)", preferredStyle: UIAlertControllerStyle.Alert)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel) { (action) in
            println(action)
            self.countdownManager.startUpdates()
        }
        
        
        let deleteAction = UIAlertAction(title: "Delete", style: .Destructive) { (action) in
            println(action)
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
    
    }
    
    func modelDidLoadItems() {
        self.collectionView?.reloadData()
    }
    
    
    
}
