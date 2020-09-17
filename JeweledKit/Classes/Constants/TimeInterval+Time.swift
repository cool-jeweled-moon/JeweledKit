//
//  TimeInterval+Time.swift
//  JeweledKit
//
//  Created by Борис Анели on 17.09.2020.
//

import Foundation

public extension TimeInterval {
    
    static let animation100ms: TimeInterval = 0.1
    static let animation200ms: TimeInterval = 0.2
    static let animation300ms: TimeInterval = 0.3
    
    static let minute: TimeInterval = 60
    static let hour: TimeInterval   = 60 * .minute
    static let day: TimeInterval    = 24 * .hour
    static let week: TimeInterval   = 7  * .day
}
