//
//  JSONAPIError.swift
//  SwiftyJSONAPI
//
//  Created by Billy Tobon on 10/15/15.
//  Copyright © 2015 Thomas Sunde Nielsen. All rights reserved.
//

import Foundation


open class JSONAPIError: JSONPrinter {

    open var id = ""
    open var links: [String:URL] = [:]
    open var status = ""
    open var code = ""
    open var title = ""
    open var detail = ""
    open var source: JSONAPIErrorSource?
    open var meta: Dictionary<String,AnyObject>?
    
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
                links[key] = URL(string: value)!
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
    
    open func toDict() -> [String:Any] {
        var dict: [String:Any] = [
            "id":id as Any,
            "links":links as Any,
            "status":status as Any,
            "code":code as Any,
            "title":title as Any,
            "detail":detail as Any,
        ]
        
        if source != nil {
            dict["source"] = source!
        }
        
        if meta != nil {
            dict["meta"] = meta! as Any?
        }
        
        return dict
    }
    
    //TODO: fill it with the correct attributes
    open func toNSError() -> NSError {
        return NSError(domain: "SwiftyJSONAPI", code: 99, userInfo: nil)
    }


}
