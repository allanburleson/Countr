//: Playground - noun: a place where people can play

import UIKit

var str = "Hello, playground"


let title = "WWDC 2015"
let unixTimestamp = NSDate().timeIntervalSince1970
let mode = "dateAndTime"
let url: NSURL! = NSURL(string: "countr://add?title=" + title.stringByAddingPercentEscapesUsingEncoding(NSUTF8StringEncoding)! + "&date=" + String(stringInterpolationSegment: unixTimestamp) + "&mode=" + mode)!


let urlComponents = NSURLComponents(URL: url, resolvingAgainstBaseURL: false)




println("scheme: \(url.scheme)")
println("host: \(url.host)")
println("port: \(url.port)")
println("path: \(url.path)")
let pathComponents = url.pathComponents
println("parameterString: \(url.parameterString)")
println("query: \(url.query)")
println("fragment: \(url.fragment)")



/*
NSString *url_ = @"foo://name.com:8080/12345;param?foo=1&baa=2#fragment";
NSURL *url = [NSURL URLWithString:url_];

NSLog(@"scheme: %@", [url scheme]);
NSLog(@"host: %@", [url host]);
NSLog(@"port: %@", [url port]);
NSLog(@"path: %@", [url path]);
NSLog(@"path components: %@", [url pathComponents]);
NSLog(@"parameterString: %@", [url parameterString]);
NSLog(@"query: %@", [url query]);
NSLog(@"fragment: %@", [url fragment]);*/
