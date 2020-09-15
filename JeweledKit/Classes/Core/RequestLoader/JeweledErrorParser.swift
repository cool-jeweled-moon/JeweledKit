//
//  JeweledErrorParser.swift
//  JeweledKit
//
//  Created by Борис Анели on 05.09.2020.
//

import Foundation

public protocol JeweledErrorParser {
    func parse(from data: Data?) -> Error?
}
