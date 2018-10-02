//
//  AGNResponse.swift
//  AGNetwork
//
//  Created by Alex Golovenkov on 15/09/2018.
//  Copyright © 2018 AGSoft. All rights reserved.
//

import Foundation

private let errorDomain = "AGNetwork"

public class NetworkError: Decodable {
    var code: Int?
    var message: String?
    var domain: String?

    var error: Error {
        let userInfo =  [NSLocalizedDescriptionKey: message ?? ""]
        return NSError(domain: domain ?? errorDomain, code: code ?? -1, userInfo: userInfo)
    }
}

public struct AGNResponse<T: Decodable>: Decodable {
    let error: NetworkError?
    let errors: [NetworkError]?
    let data: T?
}
