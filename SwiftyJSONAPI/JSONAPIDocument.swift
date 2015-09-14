//
//  JSONAPIDocument.swift
//  SwiftyJSONAPI
//
//  Created by Thomas Sunde Nielsen on 11.09.15.
//  Copyright © 2015 Thomas Sunde Nielsen. All rights reserved.
//

import Foundation

public class JSONAPIDocument: JSONPrinter {
    var data: [JSONAPIResource] = []
    var links: [String:NSURL] = [:]
    var included: [JSONAPIResource] = []
    var url: NSURL?
    
    public convenience init(_ json: NSDictionary) {
        self.init(json as! [String:AnyObject])
    }
    
    public convenience init(_ json: [String:AnyObject]) {
        self.init()
        for object in normalizeJSONAPIObjectToArray(json["data"]) {
            data.append(JSONAPIResource(object))
        }
        
        for object in normalizeJSONAPIObjectToArray(json["included"]) {
            included.append(JSONAPIResource(object))
        }
        
        if let strings = json["links"] as? [String:String] {
            for (key, value) in strings {
                links[key] = NSURL(string: value)!
                if key == "self" {
                    url = NSURL(string: value)!
                }
            }
        }
    }
    
    public convenience init(_ data: NSData) throws {
        let json = try NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.AllowFragments)
        self.init(json as! [String:AnyObject])
    }
    
    public func toDict() -> [String:AnyObject] {
        var dict: [String:AnyObject] = [:]
        dict["data"] = data.count == 1 ? data.first!.toDict() : data.map { $0.toDict() }
        
        switch included.count {
        case 1:
            dict["included"] = included.first!.toDict()
        case let x where x > 1:
            dict["included"] = included.map { $0.toDict() }
        default: break
        }
        
        return dict
    }
}