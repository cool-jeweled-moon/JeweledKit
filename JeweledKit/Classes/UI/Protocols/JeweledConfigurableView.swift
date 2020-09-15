//
//  JeweledConfigurableView.swift
//  JeweledKit
//
//  Created by Борис Анели on 15.09.2020.
//

import UIKit

public protocol JeweledConfigurableView {
    
    associatedtype ConfigurationModel
    
    func configure(with model: ConfigurationModel)
}
