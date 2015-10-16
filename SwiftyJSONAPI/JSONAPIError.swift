//
//  JSONAPIError.swift
//  SwiftyJSONAPI
//
//  Created by Billy Tobon on 10/15/15.
//  Copyright © 2015 Thomas Sunde Nielsen. All rights reserved.
//

import Foundation


public class JSONAPIError: JSONPrinter {

    public var id = ""
    public var status = ""
    public var code = ""
    public var title = ""

    //TODO: add other attributes
    
    public init(){}
    
    public convenience init(_ json: NSDictionary) {
        self.init(json as! [String:AnyObject])
    }
    
    public convenience init(_ json: [String:AnyObject]) {
        self.init()
        if let objectId = json["id"] {
            id = "\(objectId)"
        }
        
        if let objectStatus = json["status"] {
            status = "\(objectStatus)"
        }
        
        if let objectCode = json["code"] {
            code = "\(objectCode)"
        }
        
        if let objectTitle = json["title"] {
            title = "\(objectTitle)"
        }
        
        

    }
    
    public func toDict() -> [String:AnyObject] {        
        let dict: [String:AnyObject] = [
            "id":id,
            "status":status,
            "code":code,
            "title":title
            
        ]
        
        return dict
    }


}