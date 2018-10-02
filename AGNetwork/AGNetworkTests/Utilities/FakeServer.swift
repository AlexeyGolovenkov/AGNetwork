//
//  FakeServer.swift
//  AGNetworkTests
//
//  Created by Alex Golovenkov on 16/09/2018.
//  Copyright © 2018 AGSoft. All rights reserved.
//

import UIKit
@testable import AGNetwork

var oldSession: URLSession?

class FakeServer: URLProtocol {
    var connection: NSURLConnection!

    class func register() {
        oldSession = AGNetwork.shared.session
        AGNetwork.shared.session = URLSession(configuration: FakeServer.testSessionConfiguration())
    }

    class func unregister() {
        guard let oldSession = oldSession else {
            return
        }
        AGNetwork.shared.session = oldSession
    }

    class func testSessionConfiguration() -> URLSessionConfiguration {
        let configuration = URLSessionConfiguration.default

        // configure session here
        configuration.requestCachePolicy = .reloadIgnoringCacheData
        configuration.protocolClasses?.insert(FakeServer.self, at: 0)
        return configuration
    }

    override class func canInit(with request: URLRequest) -> Bool {
        guard let url = request.url else {
            return false
        }
        return url.scheme == "test"
    }

    override class func canonicalRequest(for request: URLRequest) -> URLRequest {
        return request
    }

    override func startLoading() {
        let data = self.data(for: self.request)
        let url = request.url!
        let mimeType = "app/json"
        let length = data.count
        let response = URLResponse(url: url, mimeType: mimeType, expectedContentLength: length, textEncodingName: nil)

        self.client!.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
        self.client!.urlProtocol(self, didLoad: data)
        self.client!.urlProtocolDidFinishLoading(self)
    }

    override func stopLoading() {
        if self.connection != nil {
            self.connection.cancel()
        }
        self.connection = nil
    }

    func data(for request: URLRequest) -> Data {
        guard let dataFileName = fileName(for: request) else {
            return Data()
        }
        let data = Data(testFile: dataFileName)
        return data ?? Data()
    }

    func fileName(for request: URLRequest) -> String? {
        guard var path = request.url?.path.trimmingCharacters(in: CharacterSet(charactersIn: "/")) else {
            return nil
        }
        if request.allHTTPHeaderFields?["authenticated"] != nil {
            path += "_auth"
        } else {
            path += "_anon"
        }
        return path
    }
}

extension Data {
    init?(testFile: String) {
        let bundle = Bundle(for: FakeServer.self)
        guard let fileName = bundle.path(forResource: testFile, ofType: "json") else {
            return nil
        }
        do {
            self = try Data(contentsOf: URL(fileURLWithPath: fileName))
        } catch {
            return nil
        }
    }
}
