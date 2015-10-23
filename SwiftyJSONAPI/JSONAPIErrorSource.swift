//
//  JSONAPIErrorSource.swift
//  GodmotherKit
//
//  Created by Billy Tobon on 10/20/15.
//  Copyright © 2015 Rent The Runway. All rights reserved.
//

import Foundation

public class JSONAPIErrorSource: JSONPrinter {
    
    public var pointer:String = ""
    public var parameter:String = ""
    
    public init(){}
    
    public convenience init(_ json: NSDictionary) {
        self.init(json as! [String:AnyObject])
    }
    
    public convenience init(_ json: [String:AnyObject]) {
        self.init()
        if let objectPointer = json["pointer"] {
            pointer = "\(objectPointer)"
        }
        
        if let objectParameter = json["parameter"] {
            parameter = "\(objectParameter)"
        }
        
    }
    
    public func toDict() -> [String:AnyObject] {
        let dict: [String:AnyObject] = [
            "pointer":pointer,
            "parameter":parameter
        ]
        return dict
    }
    
}
