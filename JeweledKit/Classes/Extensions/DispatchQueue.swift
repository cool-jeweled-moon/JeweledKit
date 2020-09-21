//
//  DispatchQueue.swift
//  JeweledKit
//
//  Created by Борис Анели on 15.09.2020.
//

import Foundation

public extension DispatchQueue {

    /// If already in main thread call block synchronously
    /// else DispatchQueue.async
    func asyncIfNeeded(_ block: @escaping () -> Void) {
        if self == DispatchQueue.main && Thread.isMainThread {
            block()
        } else {
            async(execute: block)
        }
    }
    
    final class var current: DispatchQueue {
        if Thread.isMainThread {
            return DispatchQueue.main
        } else {
            return DispatchQueue.global()
        }
    }
}
