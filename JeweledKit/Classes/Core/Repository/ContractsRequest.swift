//
//  ContractsRequest.swift
//  JeweledKit_Example
//
//  Created by Борис Анели on 06.09.2020.
//  Copyright © 2020 CocoaPods. All rights reserved.
//

import Foundation
import JeweledKit

class ContractsRequest: BaseRequest, JeweledModelRequest {
    
    typealias Model = [Contract]
    
    private let page: Int?
    private let limit: Int?
    
    init(page: Int?, limit: Int?) {
        self.page = page
        self.limit = limit
    }
    
    override var path: String {
        return "contracts" + ".json?"
    }
    
    override var parameters: [String: Any] {
        var parameters = [String: Any]()
        
        if let page = page {
            parameters["page"] = "\(page)"
        }
        
        if let limit = limit {
            parameters["perPage"] = "\(limit)"
        }
        
        return parameters
    }
}
