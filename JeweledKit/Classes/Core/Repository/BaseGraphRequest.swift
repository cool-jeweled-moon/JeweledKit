//
//  BaseGraphRequest.swift
//  JeweledKit_Example
//
//  Created by Борис Анели on 06.09.2020.
//  Copyright © 2020 CocoaPods. All rights reserved.
//

import Foundation
import JeweledKit

protocol GraphRequest: JeweledRequest {
    var manager: Manager? { get }
    var entity: String? { get }
    var join: [[String: String]] { get }
    var alias: String? { get }
    var fields: [String] { get }
    var updateFields: [String: Any] { get }
    var sort: [String: String] { get }
    var conditions: [String: Any] { get }
    var rules: [Any] { get }
    var graphPath: Path { get }
    var graphParameters: [String: Any] { get }
}

enum Manager: String {
    case sphinx
    case ea
    case procedures
}

enum Path: String {
    case list = "api/list"
    case get = "api/get"
    case update = "api/update"
    case events = "NewCalendar/events"
    case procedureTypes = "dictionary/placing-way"
}

class BaseGraphRequest: GraphRequest {
    
    var timeoutInterval: TimeInterval { return 60 }
    
    var baseUrl: String { return "https://gz.lot-online.ru/etp_back/" }
    
    var path: String { return graphPath.rawValue }
    
    var headerFields: [String : String] {
        return ["Content-Type": "application/json",
                "Authorization": "Bearer 1878C253-FDEC-2D0C-B53C-908A29BEC5CB"]
    }
    
    var payloadKey: String? { return "data" }
    
    var type: JeweledRequestType {
        return .post
    }
    
    var graphPath: Path {
        return .list
    }
    
    var parameters: [String : Any] {
        return [:]
    }
    
    var graphParameters: [String : Any] {
        return [:]
    }
    
    var body: Data? {
        guard type != .get else { return nil }
        
        var bodyDictionary: [String: Any] = [
            "conditions": conditions,
            "rules": rules,
            "fields": graphPath == .update ? updateFields : fields,
            "join": join
        ]
        
        if let manager = manager {
            bodyDictionary["manager"] = manager.rawValue
        }
        
        if let entity = entity {
            bodyDictionary["entity"] = entity
        }
        
        if let alias = alias {
            bodyDictionary["alias"] = alias
        }
        
        if !sort.isEmpty {
            bodyDictionary["sort"] = sort
        }
        
        if !graphParameters.isEmpty {
            for (key, value) in graphParameters {
                bodyDictionary[key] = value
            }
        }
        
        do {
            return try JSONSerialization.data(withJSONObject: bodyDictionary, options: [])
        } catch let error {
            assertionFailure(error.localizedDescription)
            return nil
        }
    }
    
    var manager: Manager? {
        return nil
    }
    
    var entity: String? { return "" }
    
    var alias: String? { return "" }
    
    var sort: [String : String] { return [:] }
    
    var conditions: [String : Any] { return [:] }
    
    var rules: [Any] { return [] }
    
    var fields: [String] { return [] }
    
    var updateFields: [String: Any] { return [:] }
    
    var join: [[String : String]] { return [] }
}
/*
[String : Any]) bodyDictionary = 10 key/value pairs {
[0] = {
  key = "offset"
  value = 0
}
[1] = {
  key = "conditions"
  value = 1 key/value pair {
    [0] = {
      key = "procedure.id"
      value = 2 values {
        [0] = "gt"
        [1] = 0
      }
    }
  }
}
[2] = {
  key = "manager"
  value = "sphinx"
}
[3] = {
  key = "sort"
  value = 1 key/value pair {
    [0] = (key = "procedure.publicationDateTime", value = "DESC")
  }
}
[4] = {
  key = "limit"
  value = 16
}
[5] = {
  key = "fields"
  value = 10 values {
    [0] = "procedure.id"
    [1] = "procedure.status"
    [2] = "procedure.type"
    [3] = "procedure.purchaseObjectInfo"
    [4] = "procedure.maxSum"
    [5] = "procedure.purchaseNumber"
    [6] = "procedure.publicationDateTime"
    [7] = "procedure.isFavor"
    [8] = "procedure.number"
    [9] = "procedure.requestCount"
  }
}
[6] = {
  key = "rules"
  value = 2 values {
    [0] = "Procedure.Registry"
    [1] = "Procedure.AdditionalInfo"
  }
}
[7] = {
  key = "join"
  value = 0 values {}
}
[8] = {
  key = "entity"
  value = "Procedure"
}
[9] = {
  key = "alias"
  value = "procedure"
}
*/
