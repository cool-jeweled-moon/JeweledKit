//
//  URLRequestFactory.swift
//  JeweledKit
//
//  Created by Борис Анели on 05.09.2020.
//

import Foundation

class URLRequestFactory {
    
    public class func createURLRequest(from request: JeweledRequest) -> URLRequest {
        guard var urlComponents = URLComponents(string: request.baseUrl + request.path) else {
            fatalError("Couldn't create url components from string: \(request.baseUrl)\(request.path)")
        }
        
        var queryItems = [URLQueryItem]()
        for (key, value) in request.parameters {
            queryItems.append(URLQueryItem(name: key, value: value))
        }
        urlComponents.queryItems = queryItems
        
        guard let url = urlComponents.url else {
            fatalError("Couldn't create url from components: \(request.parameters)")
        }
        var urlRequest = URLRequest(url: url)
        
        urlRequest.httpMethod = request.type.rawValue
        urlRequest.timeoutInterval = 60
        
        if let bodyData = request.body {
            urlRequest.httpBody = bodyData
        }

        for (key, value) in request.headerFields {
            urlRequest.addValue(value, forHTTPHeaderField: key)
        }
        
        return urlRequest
    }
}
