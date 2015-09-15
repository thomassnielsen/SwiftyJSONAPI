//
//  JSONAPIResource.swift
//  SwiftyJSONAPI
//
//  Created by Thomas Sunde Nielsen on 11.09.15.
//  Copyright © 2015 Thomas Sunde Nielsen. All rights reserved.
//

import Foundation

public enum JSONAPIResourceLoaded {
    case Loaded
    case Sparse // Not used
    case NotLoaded
}


public class JSONAPIResource: JSONPrinter {
    var id = ""
    var type = ""
    var url: NSURL?
    var attributes: [String:AnyObject] = [:]
    var relationships: [JSONAPIRelationship] = []
    var loaded = JSONAPIResourceLoaded.NotLoaded
    
    public convenience init(_ json: NSDictionary, loaded: JSONAPIResourceLoaded = .NotLoaded) {
        self.init(json as! [String:AnyObject], loaded: loaded)
    }
    
    public convenience init(_ json: [String:AnyObject], loadedState: JSONAPIResourceLoaded = .NotLoaded) {
        self.init()
        loaded = loadedState
        
        if let objectId = json["id"] {
            id = "\(objectId)"
        }
        if let objectType = json["type"] {
            type = "\(objectType)"
        }
        
        if let attrs = json["attributes"] as? [String:AnyObject] {
            attributes = attrs
            loaded = .Loaded
        }
        
        if let rels = json["relationships"] as? [String:AnyObject] {
            rels
            for (key, data) in rels {
                relationships.append(JSONAPIRelationship(type: key, data: data as! [String : AnyObject]))
            }
            loaded = .Loaded
        }
        
        if let links = json["links"] {
            if let objectUrl = links["self"] as? String {
                url = NSURL(string: objectUrl)!
            }
        }
    }
    
    public func toDict() -> [String:AnyObject] {
        var dict: [String:AnyObject] = [
            "id":id,
            "type":type
        ]
        
        if let url = url {
            dict["links"] = ["self":url.absoluteString]
        }
        
        if loaded == .Loaded {
            dict["attributes"] = attributes
            var rels: [String:AnyObject] = [:]
            for rel in relationships {
                rels[rel.type] = rel.toDict()
            }
            if rels.count > 0 {
                dict["relationships"] = rels
            }
        }
        
        return dict
    }
    
    public subscript(key: String) -> AnyObject? {
        return attributes[key]
    }
}