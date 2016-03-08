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
    public var links: [String:NSURL] = [:]
    public var status = ""
    public var code = ""
    public var title = ""
    public var detail = ""
    public var source: JSONAPIErrorSource?
    public var meta: Dictionary<String,AnyObject>?
    
    public init(){}
    
    public convenience init(_ json: NSDictionary) {
        self.init(json as! [String:AnyObject])
    }
    
    public convenience init(_ json: [String:AnyObject]) {
        self.init()
        if let objectId = json["id"] {
            id = "\(objectId)"
        }
        
        if let strings = json["links"] as? [String:String] {
            for (key, value) in strings {
                links[key] = NSURL(string: value)!
            }
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
        
        if let objectDetail = json["details"] {
            detail = "\(objectDetail)"
        }
        
        if let objectSource = json["source"] as? [String:AnyObject] {
            source = JSONAPIErrorSource(objectSource)
        }
        
        if let objectMeta = json["meta"] as? [String:AnyObject] {
            meta = objectMeta
        }

    }
    
    public func toDict() -> [String:AnyObject] {        
        var dict: [String:AnyObject] = [
            "id":id,
            "links":links,
            "status":status,
            "code":code,
            "title":title,
            "detail":detail,
        ]
        
        if source != nil {
            dict["source"] = source!
        }
        
        if meta != nil {
            dict["meta"] = meta!
        }
        
        return dict
    }
    
    //TODO: fill it with the correct attributes
    public func toNSError() -> NSError {
        return NSError(domain: "SwiftyJSONAPI", code: 99, userInfo: nil)
    }


}