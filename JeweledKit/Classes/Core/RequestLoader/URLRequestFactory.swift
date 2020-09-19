//
//  URLRequestFactory.swift
//  JeweledKit
//
//  Created by Борис Анели on 05.09.2020.
//

import Foundation

class URLRequestFactory {
    
    public class func createURLRequest(from request: JeweledRequest) -> URLRequest {
        guard let url = URL(string: request.baseUrl + request.path + request.parameters.queryString)
            else { fatalError() }
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

extension Dictionary {
    
    var queryString: String {
        guard !isEmpty else { return "" }
        
        var output: String = "?"
        
        for (key,value) in self {
            output +=  "\(key)=\(value)&"
        }
        
        output = String(output.dropLast())
        
        return output
    }
}
