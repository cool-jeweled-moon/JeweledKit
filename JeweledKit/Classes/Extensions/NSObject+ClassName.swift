//
//  NSObject+ClassName.swift
//  JeweledKit
//
//  Created by Борис Анели on 05.09.2020.
//

import Foundation

extension NSObject {
    
    @objc func className() -> String {
        return String(describing: type(of: self)).components(separatedBy: ".").last ?? ""
    }
    
    @objc class func className() -> String {
        return String(describing: self).components(separatedBy: ".").last ?? ""
    }
}
