//
//  AGNCoreTests.swift
//  AGNetworkTests
//
//  Created by Alex Golovenkov on 16/09/2018.
//  Copyright © 2018 AGSoft. All rights reserved.
//

import XCTest
@testable import AGNetwork

class AGNCoreTests: XCTestCase {

    override class func setUp() {
        AGNetwork.shared.baseURL = "test://localhost/"
        FakeServer.register()
    }

    override class func tearDown() {
        FakeServer.unregister()
    }

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testErrorRequest() {
        let expectation = self.expectation(description: "Error Request expectation")
        AGNetwork.shared.get(from: "error", parameters: nil, convertTo: EmptyResponse.self) { (_, error) in
            XCTAssertNotNil(error, "Error must appear")
            let errorCode = (error! as NSError).code
            XCTAssertEqual(errorCode, 401, "Wrong error code: \(errorCode)")
            let errorMessage = (error! as NSError).localizedDescription
            XCTAssertEqual(errorMessage, "Authentification failed", "Wrong error message: \(errorMessage)")
            let domain = (error! as NSError).domain
            XCTAssertEqual(domain, "AGNetwork", "Wrong error domain: \(domain)")

            expectation.fulfill()
        }
        self.wait(for: [expectation], timeout: 15.0)
    }

    func testErrorWithDomainRequest() {
        let expectation = self.expectation(description: "Error Request expectation")
        AGNetwork.shared.get(from: "errorWithDomain", parameters: nil, convertTo: EmptyResponse.self) { (_, error) in
            XCTAssertNotNil(error, "Error must appear")
            let errorCode = (error! as NSError).code
            XCTAssertEqual(errorCode, 401, "Wrong error code: \(errorCode)")
            let errorMessage = (error! as NSError).localizedDescription
            XCTAssertEqual(errorMessage, "Authentification failed", "Wrong error message: \(errorMessage)")
            let domain = (error! as NSError).domain
            XCTAssertEqual(domain, "global", "Wrong error domain: \(domain)")

            expectation.fulfill()
        }
        self.wait(for: [expectation], timeout: 15.0)
    }

}
