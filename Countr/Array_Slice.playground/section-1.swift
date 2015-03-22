// Playground - noun: a place where people can play

import Foundation
import UIKit

var str = "Hello, playground"

extension Array {
    func subarrayToIndex(index: Int) -> Array {
        if index > self.count {
            return self
        }
        return Array(self[0...index-1])
    }
}

func subarrayOfArray(array: Array<AnyObject>, #toIndex: Int) -> Array<AnyObject> {
    let _tempArray: Array<AnyObject> = Array(array[1...toIndex])
    return _tempArray
}


let items: [String] = ["item #0", "item #1", "item #2", "item #3", "item #4", "item #5", "item #6", "item #7", "item #8", "item #9", "item #10"]

let itemsToIndexThree: Array<String> = Array(items[1...3])
let itemsToIndexThreeUsingFunction = subarrayOfArray(items, toIndex: 3)
let itemsToTndexThreeUsingArrayExtension = items.subarrayToIndex(3)

let sliceOfSmallArray = items.subarrayToIndex(3)

var array: [Int]

array = [1, 2, 3, 4, 5]

let slice = array.subarrayToIndex(3)


var extensionDataDict: [[String : AnyObject]] = [["title" : "hobbit3", "date" : NSDate()], ["title" : "maze runner", "date" : NSDate().dateByAddingTimeInterval(30000000)]]

var title = extensionDataDict[1]["date"]


func functionThatTakesTwoParamaters(param1: String, param2: String) {
    
}

func aFunction(param1: String, param2: String, param3: String = "default") {
    //println("params: param1: \(param1), param2: \(param2), param3: \(param3)")
    
}

aFunction("hi", "ho", "hhooo"