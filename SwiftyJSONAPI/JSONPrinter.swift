//
//  JSONPrinter.swift
//  SwiftyJSONAPI
//
//  Created by Thomas Sunde Nielsen on 11.09.15.
//  Copyright © 2015 Thomas Sunde Nielsen. All rights reserved.
//

import Foundation

protocol JSONPrinter {
    func toDict() -> [String:AnyObject]
}

extension JSONPrinter {
    func toJSONData(prettyPrinted: Bool = false) -> NSData {
        if prettyPrinted {
            return try! NSJSONSerialization.dataWithJSONObject(toDict() as NSDictionary, options: NSJSONWritingOptions.PrettyPrinted)
        }
        return try! NSJSONSerialization.dataWithJSONObject(toDict() as NSDictionary, options: NSJSONWritingOptions(rawValue: 0))
    }
    
    func toJSONString(pretty pretty: Bool = false) -> String {
        return String(data: toJSONData(pretty), encoding: NSUTF8StringEncoding)!
    }
}