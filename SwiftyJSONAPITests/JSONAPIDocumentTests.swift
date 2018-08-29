//
//  JSONAPIDocumentTests.swift
//  SwiftyJSONAPI
//
//  Created by Thomas Sunde Nielsen on 11.09.15.
//  Copyright © 2015 Thomas Sunde Nielsen. All rights reserved.
//

import XCTest
@testable import SwiftyJSONAPI

class JSONAPIDocumentTests: XCTestCase {

    var testData: Data!
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
        if let file = Bundle(for: JSONAPIDocumentTests.self).path(forResource: "example-document-1", ofType: "json") {
            self.testData = try? Data(contentsOf: URL(fileURLWithPath: file))
        } else {
            XCTFail("Could not find test file")
        }
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testImportingDocument() {
        let document = try! JSONAPIDocument(self.testData)
        
        XCTAssert(document.data.count == 1, "Expected number of data elements to be 1, was \(document.data.count)")
        XCTAssert(document.included.count == 3, "Expected number of included documents to be 2, was \(document.included.count)")
        XCTAssert(document.links.count == 3, "Expected number of links to be 3, was \(document.links.count)")
        
        XCTAssertNotNil(document.url, "Expected document to find its own URL from the provided links")
    }
    
    func testRelationships() {
        let document = try! JSONAPIDocument(self.testData)
        let resource = document.data.first!
        
        XCTAssertNotNil(resource.url, "Resources should have an URL")
        XCTAssert(resource.relationships.count == 2, "Expected number of relationships to be 2, was \(resource.relationships.count)")
    }
    
    func testErrors() {
        
        if let errorFile = Bundle(for: JSONAPIDocumentTests.self).path(forResource: "example-error", ofType: "json") {
            self.testData = try? Data(contentsOf: URL(fileURLWithPath: errorFile))
        } else {
            XCTFail("Could not find error test file")
        }
        
        let document = try! JSONAPIDocument(self.testData)
        let error = document.errors.first!
        
        XCTAssertNotNil(error.id, "Errors should have an id")
        XCTAssertEqual(error.status,"422", "Expected error code to be 422")
    
    }
    
    func testMeta() {
        let document = try! JSONAPIDocument(self.testData)
        let meta = document.meta!
        let keys = [String](meta.keys)
    
        XCTAssertNotNil(meta, "document should have meta information")        
        XCTAssertTrue(keys.contains("authors"),"meta should contain a authors key")
        
    }
    
    func testResourcesLoadedFromInclude() {
        let document = try! JSONAPIDocument(self.testData)
        var authorAttributesCount   = 0
        var commentsAttributesCount = 0
        
        document.loadIncludedResources()
        
        guard let postResource = document.data.first else {
            XCTFail("Could not find resource of type Post"); return
        }
        
        postResource.relationships.forEach { relationship in
            switch relationship.type {
            case "author":
                authorAttributesCount = relationship.resources.first?.attributes.count ?? 0
            case "comments":
                commentsAttributesCount = relationship.resources.first?.attributes.count ?? 0
            default:
                // For now we are only handling these 2 cases
                break
            }
        }
        
        XCTAssertTrue(authorAttributesCount == 3,"Author resource should contain 3 attributes")
        XCTAssertTrue(commentsAttributesCount == 1,"Comment resource should contain 1 attribute")
    }
    
    func testbidirectionalRelationship() {
        if let bidirectionalFile = Bundle(for: JSONAPIDocumentTests.self).path(forResource: "example-bidirectional-relationship", ofType: "json") {
            self.testData = try? Data(contentsOf: URL(fileURLWithPath: bidirectionalFile))
        } else {
            XCTFail("Could not find error test file")
        }
        
        var userHasAdressRelationship = false
        var addressHasUserRelationship = false
        
        let document = try! JSONAPIDocument(self.testData)
        document.loadIncludedResources()
        
        let resource = document.data.first
        
        resource?.relationships.forEach { relationship in
            switch relationship.type {
            case "user":
               userHasAdressRelationship = relationship.hasRelationship(toType: "address")
            case "address":
                addressHasUserRelationship = relationship.hasRelationship(toType: "user")
            default:
                // For now we are only handling these 2 cases
                break
            }
        }
        
        XCTAssertTrue(userHasAdressRelationship, "Expected user to have a relationship to addess")
        XCTAssertTrue(addressHasUserRelationship, "Expected address to have a relationship to a user")
    }
    
//
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            _ = try! JSONAPIDocument(self.testData)
        }
    }

}

private extension JSONAPIRelationship {
    func hasRelationship(toType type: String) -> Bool {
        return resources.first?.relationships.contains(where: { $0.type == type }) ?? false
    }
}
