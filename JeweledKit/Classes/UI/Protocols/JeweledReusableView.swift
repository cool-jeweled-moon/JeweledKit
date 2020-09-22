//
//  JeweledReusableView.swift
//  JeweledKit
//
//  Created by Борис Анели on 22.09.2020.
//

import Foundation

public protocol JeweledReusableView {
    func prepareForReuse()
}

extension JeweledReusableView {
    public func prepareForReuse() {}
}
