//
//  JSONAPIDocumentTests.swift
//  SwiftyJSONAPI
//
//  Created by Thomas Sunde Nielsen on 11.09.15.
//  Copyright © 2015 Thomas Sunde Nielsen. All rights reserved.
//

import XCTest
@testable import SwiftyJSONAPI

final class JSONAPIDocumentTests: XCTestCase {

    private func fetchDocument(for resource: String) -> JSONAPIDocument? {
        #if SWIFT_PACKAGE
        guard let url = Bundle.module.url(forResource: resource, withExtension: nil) else {
            XCTFail()
            return nil
        }
        #else
        guard let file = Bundle(for: JSONAPIDocumentTests.self).path(forResource: resource, ofType: nil) else {
            XCTFail()
            return nil
        }
        let url = URL(fileURLWithPath: file)
        #endif
        let testData = try! Data(contentsOf: url)
        return try? JSONAPIDocument(testData)
    }

    func testImportingDocument() {
        guard let document = fetchDocument(for: "example-document-1.json") else {
            XCTFail()
            return
        }

        XCTAssert(document.data.count == 1, "Expected number of data elements to be 1, was \(document.data.count)")
        XCTAssert(document.included.count == 3, "Expected number of included documents to be 2, was \(document.included.count)")
        XCTAssert(document.links.count == 3, "Expected number of links to be 3, was \(document.links.count)")

        XCTAssertNotNil(document.url, "Expected document to find its own URL from the provided links")
    }

    func testRelationships() {
        guard let document = fetchDocument(for: "example-document-1.json") else {
            XCTFail()
            return
        }
        let resource = document.data.first!

        XCTAssertNotNil(resource.url, "Resources should have an URL")
        XCTAssert(resource.relationships.count == 2, "Expected number of relationships to be 2, was \(resource.relationships.count)")
    }

    func testErrors() {

        guard let document = fetchDocument(for: "example-error.json") else {
            XCTFail()
            return
        }
        let error = document.errors.first!

        XCTAssertNotNil(error.id, "Errors should have an id")
        XCTAssertEqual(error.status,"422", "Expected error code to be 422")

    }

    func testMeta() {
        guard let document = fetchDocument(for: "example-document-1.json") else {
            XCTFail()
            return
        }
        let meta = document.meta!
        let keys = [String](meta.keys)

        XCTAssertNotNil(meta, "document should have meta information")
        XCTAssertTrue(keys.contains("authors"),"meta should contain a authors key")

    }

    func testResourcesLoadedFromInclude() {
        guard let document = fetchDocument(for: "example-document-1.json") else {
            XCTFail()
            return
        }
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

    func testBidirectionalRelationship() {

        guard let document = fetchDocument(for: "example-bidirectional-relationship.json") else {
            XCTFail()
            return
        }
        var userHasAdressRelationship = false
        var addressHasUserRelationship = false

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
}

private extension JSONAPIRelationship {
    func hasRelationship(toType type: String) -> Bool {
        return resources.first?.relationships.contains(where: { $0.type == type }) == true
    }
}
