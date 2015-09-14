//
//  JSONAPIRelationship.swift
//  SwiftyJSONAPI
//
//  Created by Thomas Sunde Nielsen on 11.09.15.
//  Copyright © 2015 Thomas Sunde Nielsen. All rights reserved.
//

import Foundation

public class JSONAPIRelationship {
    var url: NSURL?
    var type = ""
    var resources: [JSONAPIResource] = []
    
    public convenience init (type: String, data: [String:AnyObject]) {
        self.init()
        self.type = type
        if let urls = data["links"] as? [String:String] {
            if let relationURL = urls["self"] {
                self.url = NSURL(string: relationURL)
            }
        }
        
        for object in normalizeJSONAPIObjectToArray(data["data"]) {
            resources.append(JSONAPIResource(object))
        }
    }
    
    public func toDict() -> [String:AnyObject] {
        var dict: [String:AnyObject] = [:]
        dict["data"] = resources.count == 1 ? resources.first!.toDict() : resources.map { $0.toDict() }
        
        if let url = url {
            dict["links"] = ["self":url.absoluteString]
        }
        
        return dict
    }
}