//
//  AGNetworkTests.swift
//  AGNetworkTests
//
//  Created by Alex Golovenkov on 15/09/2018.
//  Copyright © 2018 AGSoft. All rights reserved.
//

import XCTest
@testable import AGNetwork

class AGNHTTPMethodTests: XCTestCase {

    func testGetPath() {
        let method = AGNHTTPMethod.get
        
        let parameters: [String: Any] = ["name": "John",
                                         "age": 21]
        let path = method.path(from: "https://example.com/", and: parameters)
        XCTAssertTrue(path == "https://example.com/?name=John&age=21" ||
            path == "https://example.com/?age=21&name=John", "Wrong path: \(path)")
    }
    
    func testPostPath() {
        let method = AGNHTTPMethod.post
        
        let parameters: [String: Any] = ["name": "John",
                                         "age": 21]
        let path = method.path(from: "https://example.com/", and: parameters)
        XCTAssertTrue(path == "https://example.com/", "Wrong path: \(path)")
    }
    
    func testGetBodyParameters() {
        let method = AGNHTTPMethod.get
        
        let parameters: [String: Any] = ["name": "John",
                                         "age": 21]
        let body = method.body(for: parameters)
        XCTAssertNil(body, "Body for GET must be nil")
    }
    
    func testPostBodyParameters() {
        let method = AGNHTTPMethod.post
        
        let parameters: [String: Any] = ["name": "John",
                                         "age": 21]
        guard let body = method.body(for: parameters) else {
            XCTFail("Body can't be nil")
            return
        }
        guard let parsedParameters = (try? JSONSerialization.jsonObject(with: body, options: [])) as? [String: Any] else {
            XCTFail("body not parsed")
            return
        }
        XCTAssertEqual(parameters.count, parsedParameters.count, "Parameters were parsed in a wrong way")
        XCTAssertEqual(parameters["name"] as! String, parsedParameters["name"] as! String, "Parameters were parsed in a wrong way")
        XCTAssertEqual(parameters["age"] as! Int, parsedParameters["age"] as! Int, "Parameters were parsed in a wrong way")
    }
}
