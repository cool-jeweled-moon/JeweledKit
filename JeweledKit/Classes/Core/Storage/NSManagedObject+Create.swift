//
//  NSManagedObject+Create.swift
//  JeweledKit
//
//  Created by Борис Анели on 05.09.2020.
//

import Foundation
import CoreData

extension NSManagedObject {
    
    class func entityName() -> String {
        var name = String(describing: self)
        if name.hasPrefix("DB") {
            let index = name.index(name.startIndex, offsetBy: 2)
            name = String(name[index...])
        }
        
        return name
    }
    
    public class func create(in context: NSManagedObjectContext) -> Self {
        guard let description = NSEntityDescription.entity(forEntityName: entityName(), in: context) else {
            fatalError("DBModel don't exist: \(self)")
        }
        let dbModel = self.init(entity: description, insertInto: context)
        
        return dbModel
    }
}
