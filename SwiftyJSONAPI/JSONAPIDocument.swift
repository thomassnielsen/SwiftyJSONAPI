//
//  JSONAPIDocument.swift
//  SwiftyJSONAPI
//
//  Created by Thomas Sunde Nielsen on 11.09.15.
//  Copyright © 2015 Thomas Sunde Nielsen. All rights reserved.
//

import Foundation

open class JSONAPIDocument: JSONPrinter {

    open var data: [JSONAPIResource] = []
    open var links: [String:URL] = [:]
    open var included: [JSONAPIResource] = []
    open var url: URL?
    open var meta: Dictionary<String,AnyObject>?
    open var errors: [JSONAPIError] = []
    
    public convenience init(_ json: NSDictionary) {
        self.init(json as! [String:AnyObject])
    }
    
    public convenience init(_ json: [String:AnyObject]) {
        self.init()
        for object in normalizeJSONAPIObjectToArray(json["data"]) {
            data.append(JSONAPIResource(object as NSDictionary, parentDocument: self, loaded: .NotLoaded))
        }
        
        for object in normalizeJSONAPIObjectToArray(json["included"]) {
            included.append(JSONAPIResource(object,parentDocument: self))
        }
        
        if let strings = json["links"] as? [String:String] {
            for (key, value) in strings {
                links[key] = URL(string: value)!
                if key == "self" {
                    url = URL(string: value)!
                }
            }
        }
        
        for object in normalizeJSONAPIObjectToArray(json["errors"]) {
            errors.append(JSONAPIError(object))
        }
        
        if let metadata = json["meta"] as? Dictionary<String,AnyObject> {
            meta = metadata
        }
        
    }
    
    public convenience init(_ data: Data) throws {
        let json = try JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.allowFragments)
        self.init(json as! [String:AnyObject])
    }
    
    open func toDict() -> [String:Any] {
        var dict: [String:Any] = [:]
        dict["data"] = data.count == 1 ? data.first!.toDict() : data.map { $0.toDict() }
        
        switch included.count {
        case 1:
            dict["included"] = included.first!.toDict() as AnyObject?
        case let x where x > 1:
            dict["included"] = included.map { $0.toDict() }
        default: break
        }
        
        return dict
    }
}
