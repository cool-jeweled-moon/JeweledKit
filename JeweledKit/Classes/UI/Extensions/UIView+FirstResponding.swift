//
//  UIView+FirstResponding.swift
//  JeweledKit
//
//  Created by Борис Анели on 15.09.2020.
//

import UIKit

public extension UIView {
    
    func findFirstResponder() -> UIView? {
        if isFirstResponder { return self }
        
        for subview in subviews {
            if let firstResponder = subview.findFirstResponder() { return firstResponder }
        }
        
        return nil
    }
    
    func firstAvailableUIViewController() -> UIViewController? {
        if let nextViewControllerResponder = next as? UIViewController {
            return nextViewControllerResponder
        } else if let nextViewResponder = next as? UIView {
            return nextViewResponder.firstAvailableUIViewController()
        }
        
        return nil
    }
}
