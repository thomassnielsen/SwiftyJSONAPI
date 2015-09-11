//
//  JSONAPIDocument.swift
//  SwiftyJSONAPI
//
//  Created by Thomas Sunde Nielsen on 11.09.15.
//  Copyright © 2015 Thomas Sunde Nielsen. All rights reserved.
//

import Foundation

class JSONAPIDocument: JSONPrinter {
    var data: [JSONAPIResource] = []
    var links: [String:NSURL] = [:]
    var included: [JSONAPIResource] = []
    var url: NSURL?
    
    convenience init(_ json: NSDictionary) {
        self.init(json as! [String:AnyObject])
    }
    
    convenience init(_ json: [String:AnyObject]) {
        self.init()
        var objects: [[String:AnyObject]] = []
        if json["data"] is NSArray {
            objects = json["data"] as! [[String:AnyObject]]
        } else if json["Data"] is NSDictionary {
            objects = [json["data"] as! [String:AnyObject]]
        }
        objects.forEach { (object) -> () in
            data.append(JSONAPIResource(object))
        }
        
        objects.removeAll()
        if let incl = json["included"] as? [[String:AnyObject]] {
            objects = incl
        } else if let incl = json["included"] as? [String:AnyObject] {
            objects = [incl]
        }
        
        objects.forEach { (object) -> () in
            included.append(JSONAPIResource(object))
        }
        
        if json["links"] is NSDictionary {
            // TODO: Rewrite with map
            let strings = json["links"] as! [String:String]
            var mapped: [String:NSURL] = [:]
            for (key, value) in strings {
                mapped[key] = NSURL(string: value)!
                if key == "self" {
                    url = NSURL(string: value)!
                }
            }
            links = mapped
        }
    }
    
    convenience init(_ data: NSData) throws {
        let json = try NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.AllowFragments)
        self.init(json as! [String:AnyObject])
    }
    
    func toDict() -> [String:AnyObject] {
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