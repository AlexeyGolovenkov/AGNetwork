//
//  AGNetwork.swift
//  AGNetwork
//
//  Created by Alex Golovenkov on 15/09/2018.
//  Copyright © 2018 AGSoft. All rights reserved.
//

import UIKit

public typealias AGNetworkCompletionClosure = (Any?, Error?) -> Void
public let AGNActiveRequestAppearedNotification = Notification.Name("AGNActiveRequest")
public let AGNNoActiveRequestNotification = Notification.Name("AGNActiveRequest")

public class AGNetwork {
    static let shared = AGNetwork()
    
    var requestsCount = 0 {
        didSet {
            guard requestsCount != oldValue else {
                // request counter not changed. No necessity to send notification
                return
            }
            if requestsCount == 0 {
                DispatchQueue.main.async {
                    NotificationCenter.default.post(name: AGNActiveRequestAppearedNotification, object: self)
                }
            } else {
                if oldValue == 0 {
                    DispatchQueue.main.async {
                        NotificationCenter.default.post(name: AGNNoActiveRequestNotification, object: self)
                    }
                }
            }
        }
    }
    
    public var baseURL = ""
    public var session: URLSession!
    public var authorizationHeader: [String: String]?
    
    init() {
        session = URLSession(configuration: AGNetwork.sessionConfiguration())
    }
    
    public func getData(from path: String, method: AGNHTTPMethod = .get, parameters: [String: Any]? = nil, completion:@escaping AGNetworkCompletionClosure) {
        guard let request = self.request(for: path, method: method, parameters: parameters) else {
            return
        }
        requestsCount += 1
        let task = self.session.dataTask(with: request) { (data, response, error) in
            if self.requestsCount > 0 {
                self.requestsCount -= 1
            }
            guard error == nil else {
                completion(nil, error)
                return
            }
            completion(data, nil)
        }
        task.resume()
    }
    
    public func get<T:Decodable>(to path: String, parameters: [String: Any]? = nil, method: AGNHTTPMethod = .get, convertTo type: T.Type, completion: @escaping AGNetworkCompletionClosure) {
        getData(from: path, method: method, parameters: parameters) { data, error in
            guard error == nil, let data = data as? Data else {
                DispatchQueue.main.async {
                    completion(nil, error)
                }
                return
            }
            var serializationError: Error?
            var response: AGNResponse<T>?
            do {
                let decoder = JSONDecoder()
                decoder.dateDecodingStrategy = .iso8601
                response = try decoder.decode(AGNResponse<T>.self, from: data)
            } catch let parsingError {
                serializationError = parsingError
            }
            guard response != nil, response?.error == nil else {
                DispatchQueue.main.async {
                    completion(nil, response?.error?.error)
                }
                return
            }
            DispatchQueue.main.async {
                completion(response, serializationError)
            }
        }
    }
}

fileprivate extension AGNetwork {
    class func sessionConfiguration() -> URLSessionConfiguration {
        let configuration = URLSessionConfiguration.default
        
        // configure session here
        configuration.requestCachePolicy = .returnCacheDataElseLoad
        
        return configuration
    }
    
    func request(for pathString: String, method: AGNHTTPMethod, parameters: [String: Any]?) -> URLRequest? {
        let path = method.path(from: pathString, and: parameters)
        
        guard let fullPath = "\(self.baseURL)\(path)".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else {
            return nil
        }
        guard let url = URL(string: fullPath) else {
            return nil
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        if let headers = self.authorizationHeader {
            for header in headers {
                request.setValue(header.value, forHTTPHeaderField: header.key)
            }
        }
        request.httpBody = method.body(for: parameters)
        
        return request
    }
}
