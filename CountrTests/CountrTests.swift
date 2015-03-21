//
//  CountrTests.swift
//  CountrTests
//
//  Created by Lukas Kollmer on 30/11/14.
//  Copyright (c) 2014 Lukas Kollmer. All rights reserved.
//

import UIKit
import XCTest

class CountrTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testExample() {
        // This is an example of a functional test case.
        XCTAssert(true, "Pass")
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measureBlock() {
            // Put the code you want to measure the time of here.
            
            ////////////////////////////////
            //    !!!!! OLD CODE !!!!!    //
            ////////////////////////////////
            
            var dates: [NSDate] = []
            
            let testDate = NSDate()
            let dateComponents = NSDateComponents()
            let calendar = NSCalendar.currentCalendar()
            dateComponents.day = 1
            
            for index in 1...1001 {
                let _date = calendar.dateByAddingUnit(.CalendarUnitDay, value: -index, toDate: NSDate(), options: nil)!
                dates.append(_date)
            }
        }
    }
    
    func testSaveDataToFileForExtension() {
        let testItemOne   = LKCountdownItem(name: "test item #1", date: NSDate().dateByAddingTimeInterval(100), mode: .Date)
        let testItemTwo   = LKCountdownItem(name: "test item #2", date: NSDate().dateByAddingTimeInterval(200), mode: .Date)
        let testItemThree = LKCountdownItem(name: "test item #3", date: NSDate().dateByAddingTimeInterval(300), mode: .Date)
        
        let items: [LKCountdownItem] = [testItemOne, testItemTwo, testItemThree]
        
        var extensionDataManager = LKSharedExtensionDataManager()
        extensionDataManager.saveCountdownItemsToExtension(items)
        
        let itemsReadByExtension = extensionDataManager.loadCountdownItemsForExtension()
        println("The arrays: saved: \(items), loaded: \(itemsReadByExtension)")
        
        XCTAssert(items == itemsReadByExtension, "Items saved are equal to items read")
    }
}
