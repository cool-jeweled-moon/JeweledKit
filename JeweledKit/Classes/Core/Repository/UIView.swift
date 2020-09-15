//
//  UIView.swift
//  JeweledKit
//
//  Created by Борис Анели on 06.09.2020.
//

import Foundation

extension UIView {
    class var nibName: String {
        return String(describing: self).components(separatedBy: ".").first ?? ""
    }
}
