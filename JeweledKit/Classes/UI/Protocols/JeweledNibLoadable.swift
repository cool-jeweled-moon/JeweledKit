//
//  JeweledNibLoadable.swift
//  JeweledKit
//
//  Created by Борис Анели on 06.09.2020.
//

import Foundation

public protocol JeweledNibLoadable {}
extension UIView: JeweledNibLoadable {}

public extension JeweledNibLoadable where Self: UIView {
    
    static func isLoadableFromNib() -> Bool {
        let bundle = Bundle(for: self)
        return bundle.path(forResource: nibName, ofType: "nib") != nil
    }
    
    static func fromNib() -> Self {
        let bundle = Bundle(for: self)
        let nibName = self.nibName
        guard let viewFromNib = bundle.loadNibNamed(nibName,
                                                    owner: self,
                                                    options: nil)?.first as? Self
            else {
                fatalError("Can't load Nib with name \(nibName)")
        }
        return viewFromNib
    }
    
    static var nibName: String {
        return String(describing: type(of: self)).components(separatedBy: ".").first ?? ""
    }
}
