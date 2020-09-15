//
//  JeweledPersistable.swift
//  JeweledKit
//
//  Created by Борис Анели on 05.09.2020.
//

import Foundation
import CoreData

public protocol JeweledPersistable {
    
    associatedtype DBType: NSManagedObject
    
    static func from(_ dbModel: DBType) -> Self
    
    @discardableResult
    func createDB(in context: NSManagedObjectContext) -> DBType
}

extension JeweledPersistable {
    
    public func createPersistanceObject(_ context: NSManagedObjectContext,
                                        configureBlock: (inout DBType) -> Void) -> DBType {
        guard var entity = NSEntityDescription.insertNewObject(forEntityName: DBType.entityName(),
                                                               into: context) as? DBType else {
            fatalError("Missing DBModel: \(DBType.self)")
        }
        
        configureBlock(&entity)
        
        return entity
    }
    
    static public func from(_ dbModel: DBType?) -> Self? {
        guard let dbModel = dbModel else { return nil }
        
        return from(dbModel)
    }
}
