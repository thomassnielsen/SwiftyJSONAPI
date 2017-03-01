//
//  JSONPrinter.swift
//  SwiftyJSONAPI
//
//  Created by Thomas Sunde Nielsen on 11.09.15.
//  Copyright © 2015 Thomas Sunde Nielsen. All rights reserved.
//

import Foundation

public protocol JSONPrinter {
    func toDict() -> [String:Any]
}

public extension JSONPrinter {
    func toJSONData(_ prettyPrinted: Bool = false) -> Data {
        if prettyPrinted {
            return try! JSONSerialization.data(withJSONObject: toDict() as NSDictionary, options: JSONSerialization.WritingOptions.prettyPrinted)
        }
        return try! JSONSerialization.data(withJSONObject: toDict() as NSDictionary, options: JSONSerialization.WritingOptions(rawValue: 0))
    }
    
    func toJSONString(pretty: Bool = false) -> String {
        return String(data: toJSONData(pretty), encoding: String.Encoding.utf8)!
    }
}
