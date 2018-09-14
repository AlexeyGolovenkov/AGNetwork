//
//  AGNHTTPMethod.swift
//  AGNetwork
//
//  Created by Alex Golovenkov on 15/09/2018.
//  Copyright © 2018 AGSoft. All rights reserved.
//

import Foundation

public enum AGNHTTPMethod: String {
    case get = "GET"
    case post = "POST"
}

extension AGNHTTPMethod {
    func path(from basePath:String, and parameters: [String: Any]?) -> String? {
        var string = basePath
        guard self == .get, let parameters = parameters else {
            return string
        }
        var delimiter = "?"
        for (key, value) in parameters {
            string += "\(delimiter)\(key)=\(value)"
            delimiter = "&"
        }
        return string
    }
    
    func body(for parameters: [String: Any]?) -> Data? {
        guard self == .post, let parameters = parameters else {
            return nil
        }
        return try? JSONSerialization.data(withJSONObject: parameters, options: [])
    }
}
