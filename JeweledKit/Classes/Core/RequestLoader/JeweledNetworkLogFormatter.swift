//
//  JeweledNetworkLogFormatter.swift
//  JeweledKit
//
//  Created by Борис Анели on 05.09.2020.
//

import Foundation

class JeweledNetworkLogFormatter {
    
    /// Форматированный лог для сетевого запроса
    static func formattedLog(request: URLRequest, parameters: [String: Any]?, data: Data?, error: NSError?) -> String {
        
        var resultString = "\n>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>\n"
                              
        let resultSymbol = error == nil ? "✅" : "❌"
        resultString += "\(resultSymbol) Request:\n"
        resultString += request.url?.absoluteString ?? ""
        
        if let parameters = parameters, !parameters.isEmpty,
            let formattedParameters = format(json: parameters) {
            resultString += "\n\n🌈 Parameters:\n"
            resultString += formattedParameters
        }
        
        
        if let headers = request.allHTTPHeaderFields,
            let formattedHeaders = format(json: headers) {
            resultString += "\n\n🦄 Headers:\n"
            resultString += formattedHeaders
        }
        
        if let body = request.httpBody,
            let formattedBody = format(data: body) {
            resultString += "\n\n👘 Body:\n"
            resultString += formattedBody
        }
        
        if let data = data {
            resultString += "\n\n🍭 Result:\n"
            resultString += format(data: data) ?? ""
        }
        
        resultString += "\n<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<\n"
        
        return resultString
    }
    
    static private func format(data: Data) -> String? {
        guard let json = try? JSONSerialization.jsonObject(with: data, options: []),
            let formattedData = format(json: json) else {
                return String(data: data, encoding: .utf8)
        }
        
        return formattedData
    }
    
    static private func format(json: Any) -> String? {
        guard let data = try? JSONSerialization.data(withJSONObject: json, options: .prettyPrinted),
            let formattedJson = String(data: data, encoding: .utf8) else {
                return nil
        }
        
        return formattedJson
    }
}
