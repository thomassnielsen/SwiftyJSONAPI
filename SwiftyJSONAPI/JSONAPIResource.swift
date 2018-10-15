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

typealias ResourceType = String
typealias ResourceIds = Set<String>
typealias CachedResources = [ResourceType : ResourceIds]

public class JSONAPIResource: JSONPrinter {
    public var id = ""
    public var type = ""
    public var url: NSURL?
    public var attributes: [String:Any] = [:]
    public var relationships: [JSONAPIRelationship] = []
    public var loaded = JSONAPIResourceLoaded.NotLoaded
    weak public var parent:JSONAPIDocument?
    
    public init(){}
    
    public convenience init(_ json: NSDictionary, parentDocument: JSONAPIDocument?, loaded: JSONAPIResourceLoaded = .NotLoaded) {
        self.init(json as! [String:Any], parentDocument:parentDocument)
    }
    
    public convenience init(_ json: [String:Any], parentDocument: JSONAPIDocument?, loadedState: JSONAPIResourceLoaded = .NotLoaded) {
        self.init()
        loaded = loadedState
        
        if let document = parentDocument {
            parent = document
        }
        
        if let objectId = json["id"] {
            id = "\(objectId)"
        }
        if let objectType = json["type"] {
            type = "\(objectType)"
        }
        
        if let attrs = json["attributes"] as? [String:Any] {
            attributes = attrs
            loaded = .Loaded
        }
        
        if let rels = json["relationships"] as? [String:Any] {
            for (key, data) in rels {
                relationships.append(JSONAPIRelationship(type: key, data: data as! [String : Any]))
            }
            loaded = .Loaded
        }
        
        if let links = json["links"] as? [String:Any] {
            if let objectUrl = links["self"] as? String {
                url = NSURL(string: objectUrl)!
            }
        }
    }
    
    public func toDict() -> [String:Any] {
        var dict: [String:Any] = [
            "id":id as Any,
            "type":type as Any
        ]
        
        if let url = url?.absoluteString {
            dict["links"] = ["self":url]
        }
        
        if loaded == .Loaded {
            dict["attributes"] = attributes as Any?
            var rels: [String:Any] = [:]
            for rel in relationships {
                rels[rel.type] = rel.toDict() as Any?
            }
            if rels.count > 0 {
                dict["relationships"] = rels as Any?
            }
        }
        
        return dict
    }
    
    public subscript(key: String) -> Any? {
        return attributes[key]
    }
    
    func loadResources(withIncludedResources includedResources: ResourcesByTypeAndId) {
        var cachedResources = CachedResources()
        _loadResources(withIncludedResources: includedResources, cachedResources: &cachedResources)
    }
    
    fileprivate  func _loadResources(withIncludedResources includedResources: ResourcesByTypeAndId, cachedResources: inout CachedResources) {
        for relationship in self.relationships {
            
            for resource in relationship.resources {
                
                guard let includedResource = includedResources[resource] else { continue }
                
                resource.attributes    = includedResource.attributes
                resource.relationships = includedResource.relationships
                
                
                if !resource.relationships.isEmpty, resource.cacheIfNeeded(&cachedResources) {
                    
                    resource.parent = self.parent
                    resource._loadResources(withIncludedResources: includedResources, cachedResources: &cachedResources)
                }
                
                resource.loaded = .Loaded
            }
        }
    }
}

private extension JSONAPIResource {
    
    // Checks if a resource has been loaded already, prevents bidirectional relationships from being recursively called
    @discardableResult func cacheIfNeeded(_ cache: inout CachedResources) -> Bool {
        
        if var cachedIds = cache[type] {
            
            if cachedIds.contains(id) {
                
                return false
            } else {
                
                cachedIds.insert(id)
                cache[type] = cachedIds
                return true
            }
        } else {
            
            cache[type] = [id]
            return true
        }
    }
}
