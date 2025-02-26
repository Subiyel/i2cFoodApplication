//
//  URLRequestConvertible.swift
//  i2cFoodApplication
//
//  Created by Muhammad Ahmar Hassan  on 06/09/2022.
//

import Foundation
import Combine

protocol URLRequestConvertibleType {
    func urlRequest() throws -> URLRequest
}

enum Route: String {
    case getLunchMenu = "/data.json"
    case getDinnerMenu = "/dinner.json"
}

enum HTTPMethod {
    case get
    case post(body: Data?)
    
    var toString: String {
        switch self {
        case .get:
            return "GET"
        case .post:
            return "POST"
        }
    }
}

struct Endpoint {
    private let scheme: String = "https"
    private let host: String = "i2cfoodmenu.000webhostapp.com"
    private let route: Route
    private let method: HTTPMethod
    private let queryItems: [String: Any]?
    private let path: [String]?
    
    init(route: Route,
         method: HTTPMethod,
         path: [String]? = nil,
         queryItems: [String: String]? = nil) {
        self.route = route
        self.method = method
        self.path = path
        self.queryItems = queryItems
    }
    
    fileprivate var url: URL? {
        var components = URLComponents()
        components.scheme = scheme
        components.host = host
        components.path = route.rawValue + (path?.compactMap { "/\($0)" }.joined() ?? "")
        components.queryItems = queryItems?.compactMap { URLQueryItem(name: $0.key, value: $0.value as? String) }
        return components.url
    }
}

extension Endpoint: URLRequestConvertibleType {
    
    func urlRequest() throws -> URLRequest {
        guard let url = url else { throw NetworkRequestError.serverError(error: "Invalid URL") }
        var request = URLRequest(url: url)
        request.httpMethod = method.toString
        
        if case let HTTPMethod.post(body) = method {
            request.httpBody = body
        }
        
        return request
    }
}
