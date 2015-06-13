//
//  LKAcknowledgementsViewController.swift
//  Countr
//
//  Created by Lukas Kollmer on 5/31/15.
//  Copyright (c) 2015 Lukas Kollmer. All rights reserved.
//

import Foundation
import UIKit

private let LKLabelMargin: CGFloat = 20

class LKAcknowledgementsViewController: UITableViewController {
    
    private var headerText: String? = nil
    private var footerText: String? = nil
    
    private var acknowledgementsPlistPath: String = NSBundle.mainBundle().pathForResource("Pods-acknowledgements", ofType: "plist")!
    
    var acknowledgements: [LKAcknowledgement] = []
    
    
    override func loadView() {
        super.loadView()
        commonInit()
    }
    
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        if let indexPath = self.tableView.indexPathForSelectedRow() {
            self.tableView.deselectRowAtIndexPath(indexPath, animated: true)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.tableHeaderView = tableViewHeaderView()
        self.tableView.tableFooterView = tableViewFooterView()
    }

    
    func commonInit() {
        self.title = "Acknowleggements"
        
        self.tableView = UITableView(frame: CGRectZero, style: .Grouped)
        self.tableView.backgroundColor = UIColor.backgroundColor()
        
        let rootDict: NSDictionary = NSDictionary(contentsOfFile: acknowledgementsPlistPath)!
        var preferenceSpecifiersArray: NSArray = rootDict["PreferenceSpecifiers"] as! NSArray
        
        
        if preferenceSpecifiersArray.count >= 2 {
            
            headerText = (preferenceSpecifiersArray.firstObject as! NSDictionary)["FooterText"] as? String
            footerText = (preferenceSpecifiersArray.lastObject as! NSDictionary)["FooterText"] as? String
                
            // Remove the header and footer
            let range = NSMakeRange(1, preferenceSpecifiersArray.count - 2)
            preferenceSpecifiersArray = preferenceSpecifiersArray.subarrayWithRange(range)
        }
        
        let preferencesArrayWithoutHeaderAndFooter: Array<NSDictionary> = preferenceSpecifiersArray as! Array<NSDictionary>
        for preferenceSpecifierDict: NSDictionary in preferencesArrayWithoutHeaderAndFooter {
            let title = preferenceSpecifierDict["Title"] as! String
            let text = preferenceSpecifierDict["FooterText"] as! String
            let acknowledgement = LKAcknowledgement(title: title, text: text)
            acknowledgements.append(acknowledgement)
        }
        
        acknowledgements.sort{$0.title.localizedCaseInsensitiveCompare($1.title) == .OrderedAscending}
        
        
    }

    
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.acknowledgements.count
    }
    
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        
        cell.textLabel?.font = UIFont.systemFontOfSize(17)
        cell.textLabel?.textColor = UIColor.whiteColor()
        cell.textLabel?.text = acknowledgements[indexPath.row].title
        
        cell.backgroundColor = UIColor.foregroundColor()
        cell.accessoryType = .DisclosureIndicator
        
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        println("did select \(acknowledgements[indexPath.row])")
        
        let acknowledgementViewController = LKAcknowledgementViewController()
        acknowledgementViewController.acknowledgement = acknowledgements[indexPath.row]
        
        self.navigationController?.showViewController(acknowledgementViewController, sender: self)
    }
    
    
    
    func tableViewHeaderView() -> UIView? {
        return nil
    }
    
    func tableViewFooterView() -> UIView? {
        return nil
    }
}


class LKAcknowledgementViewController: UIViewController {
    
    var acknowledgement: LKAcknowledgement?
    
    override func loadView() {
        super.loadView()
        
        commonInit()
    }
    
    func commonInit() {
        self.title = self.acknowledgement?.title
        
        let textView = UITextView(frame: CGRectZero)
        textView.alwaysBounceVertical = true
        textView.font                 = UIFont.systemFontOfSize(17)
        textView.textColor = UIColor.whiteColor()
        textView.backgroundColor = UIColor.backgroundColor()
        textView.text                 = self.acknowledgement?.text
        textView.editable             = false
        textView.dataDetectorTypes    = .Link
        
        self.view = textView
    }
}


struct LKAcknowledgement {
    let title: String
    let text: String
}
