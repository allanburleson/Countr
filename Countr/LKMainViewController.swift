//
//  LKMainViewController.swift
//  Countr
//
//  Created by Lukas Kollmer on 2/1/15.
//  Copyright (c) 2015 Lukas Kollmer. All rights reserved.
//

import Foundation
import UIKit
import iAd

class LKMainViewController: UIViewController, ADBannerViewDelegate {
    
    @IBOutlet weak var addButton: UIBarButtonItem!
    @IBOutlet weak var adBannerView: ADBannerView!
    
    var collectionViewController: LKMainCollectionViewController?
    
    lazy private var tracker = GAI.sharedInstance().defaultTracker
    
    override func loadView() {
        super.loadView()
        self.title = "Countr"
        
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: "didTap")
        let longPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: "didLongPress")
        (self.addButton.valueForKey("view") as! UIView).addGestureRecognizer(tapGestureRecognizer)
        (self.addButton.valueForKey("view") as! UIView).addGestureRecognizer(longPressGestureRecognizer)
        
        self.navigationController?.navigationBar.setDarkAttributes()
        
        self.view.backgroundColor = UIColor.backgroundColor()
        
        self.adBannerView.delegate = self
        self.adBannerView.hidden = true
        
        if LKPurchaseManager.didPurchase {
            self.adBannerView.removeFromSuperview()
            self.adBannerView.delegate = nil
            self.adjustViewForAdBannerVisible(false)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // set initial content inset
        //self.collectionViewController?.collectionView?.contentInset = UIEdgeInsetsMake(21, 0, 0, 0)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "embedCollectionView" {
            self.collectionViewController = segue.destinationViewController as? LKMainCollectionViewController
            //println("self.bounds: \(self.view.bounds)")
            self.collectionViewController?.collectionView?.bounds = self.view.bounds
            //println("collectionView.bounds: \(self.collectionViewController?.collectionView?.bounds)")
        }
    }
    
    // MARK: Add Button
    
    func didTap() {
        createNewCountdownItem()
    }
    
    func didLongPress() {
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .ActionSheet)
        
        let createCountdownAction = UIAlertAction(title: "New Countdown", style: .Default) { (action) in
            self.createNewCountdownItem()
        }
        
        let createCountdownItemFromCalendarEventAction = UIAlertAction(title: "New Countdown from calendar", style: .Default) { (action) in
            UIAlertController.alert("Countdown from calendar")
        }
        
        alertController.addActions([createCountdownAction, createCountdownItemFromCalendarEventAction])
        
        self.presentViewController(alertController, animated: true, completion: nil)
    }
    
    func createNewCountdownItem() {
        let newItemViewController: LKEditItemPropertiesViewController = self.storyboard?.instantiateViewControllerWithIdentifier("me.countr.editItemViewController") as! LKEditItemPropertiesViewController
        
        let navigationController = UINavigationController(rootViewController: newItemViewController)
        
        self.presentViewController(navigationController, animated: true, completion: nil)
    }
    
    // MARK: ADBannerView
    
    func adjustViewForAdBannerVisible(visible: Bool) {

        //self.collectionViewController?.collectionView?.contentInset = UIEdgeInsetsMake(75, 0, 20, 0)
        if visible {
            self.adBannerView.hidden = false
            //self.collectionViewController?.collectionView?.contentInset = UIEdgeInsetsMake(200, 0, 55, 0)
            //self.collectionViewController?.collectionView?.scrollIndicatorInsets = UIEdgeInsetsMake(200, 0, 55, 0)
        } else {
            self.adBannerView.hidden = true
            //self.collectionViewController?.collectionView?.contentInset = UIEdgeInsetsMake(200, 0, 30, 0)
            //self.collectionViewController?.collectionView?.scrollIndicatorInsets = UIEdgeInsetsMake(200, 0, 30, 0)
        }
    }
    
    
    // MARK: ADBannerView delegate
    func bannerViewWillLoadAd(banner: ADBannerView!) {
        //println("bannerViewWillLoadAd")
    }
    
    func bannerViewDidLoadAd(banner: ADBannerView!) {
        //println("bannerViewDidLoadAd")
        adjustViewForAdBannerVisible(true)
        self.tracker.send(GAIDictionaryBuilder.createEventWithCategory(ad_key, action: did_display_ad_key, label: nil, value: nil).build() as [NSObject : AnyObject])
    }
    
    func bannerViewActionShouldBegin(banner: ADBannerView!, willLeaveApplication willLeave: Bool) -> Bool {
        //println("bannerViewActionShouldBegin")
        self.tracker.send(GAIDictionaryBuilder.createEventWithCategory(ad_key, action: did_tap_on_ad_key, label: nil, value: nil).build() as [NSObject : AnyObject])
        return true
    }
    
    func bannerViewActionDidFinish(banner: ADBannerView!) {
        //println("bannerViewActionDidFinish")
    }
    
    func bannerView(banner: ADBannerView!, didFailToReceiveAdWithError error: NSError!) {
        //println("bannerViewDidFailToReceiveAdWithError")
        //println("error: \(error.debugDescription)")
        adjustViewForAdBannerVisible(false)
        self.tracker.send(GAIDictionaryBuilder.createEventWithCategory(ad_key, action: did_fail_to_display_ad_key, label: nil, value: nil).build() as [NSObject : AnyObject])
    }
}