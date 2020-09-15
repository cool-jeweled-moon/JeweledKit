//
//  JeweledIdentifiable.swift
//  JeweledKit
//
//  Created by Борис Анели on 05.09.2020.
//

import Foundation

public protocol JeweledIdentifiable {
    
    associatedtype ID: Hashable
    
    var id: ID { get }
}
