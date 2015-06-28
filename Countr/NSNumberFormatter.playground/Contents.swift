//: Playground - noun: a place where people can play

import Foundation

let formatter = NSNumberFormatter()

let number: NSNumber = NSNumber(double: 5.5)


formatter.minimumIntegerDigits = 2

formatter.numberFromString(String(5))
