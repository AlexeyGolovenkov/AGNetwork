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
        XCTAssertEqual(path, "https://example.com/?name=John&age=21")
    }
}
