//
//  JeweledRequest.swift
//  JeweledKit
//
//  Created by Борис Анели on 05.09.2020.
//

import Foundation

public enum JeweledRequestType: String {
    case get = "GET"
    case post = "POST"
    case put = "PUT"
    case delete = "DELETE"
}

public protocol JeweledRequest {
    var type: JeweledRequestType { get }
    var timeoutInterval: TimeInterval { get }
    var baseUrl: String { get }
    var path: String { get }
    var parameters: [String: String?] { get }
    var headerFields: [String: String] { get }
    var body: Data? { get }
    var payloadKey: String? { get }
}

public protocol JeweledModelRequest: JeweledRequest {
    associatedtype Model: Codable
}
