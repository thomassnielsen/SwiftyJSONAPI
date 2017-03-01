//
//  JSONAPIRelationship.swift
//  SwiftyJSONAPI
//
//  Created by Thomas Sunde Nielsen on 11.09.15.
//  Copyright © 2015 Thomas Sunde Nielsen. All rights reserved.
//

import Foundation

open class JSONAPIRelationship {
    open var url: URL?
    open var type = ""
    open var resources: [JSONAPIResource] = []
    
    public convenience init (type: String, data: [String:AnyObject]) {
        self.init()
        self.type = type
        if let urls = data["links"] as? [String:String] {
            if let relationURL = urls["self"] {
                self.url = URL(string: relationURL)
            }
        }
        
        for object in normalizeJSONAPIObjectToArray(data["data"]) {
            resources.append(JSONAPIResource(object, parentDocument:nil, loadedState: .NotLoaded))
        }
    }
    
    open func toDict() -> [String:Any] {
        var dict: [String:Any] = [:]
        dict["data"] = resources.count == 1 ? resources.first!.toDict() : resources.map { $0.toDict() }
        
        if let url = url?.absoluteString {
            dict["links"] = ["self":url]
        }
        
        return dict
    }
}
