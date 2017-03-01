//
//  JSONAPIErrorSource.swift
//  GodmotherKit
//
//  Created by Billy Tobon on 10/20/15.
//  Copyright © 2015 Rent The Runway. All rights reserved.
//

import Foundation

open class JSONAPIErrorSource: JSONPrinter {
    
    open var pointer:String = ""
    open var parameter:String = ""
    
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
    
    open func toDict() -> [String:Any] {
        let dict: [String:Any] = [
            "pointer":pointer as Any,
            "parameter":parameter as Any
        ]
        return dict
    }
    
}
