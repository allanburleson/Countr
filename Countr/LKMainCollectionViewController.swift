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
    
    override func loadView() {
        super.loadView()
        //println(self.countdownManager.hash)
        self.countdownManager.didAddNewItemConpletionClosure = {
            //println("did add new item")
            
        }
        
        self.countdownManager.updateCompletionClosure = {
            //println("did update values")
            //self.collectionView?.reloadData()
        }
        
        //self.countdownManager.startUpdates()
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "modelDidLoadItems", name: modelDidLoadItemsKey, object: nil)
        


        

    }
    
    override func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        println("number of items as seen by the collectionview: \(self.countdownManager.numberOfItems)")
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
    }
    
    func modelDidLoadItems() {
        self.collectionView?.reloadData()
    }
    
    
    
}
