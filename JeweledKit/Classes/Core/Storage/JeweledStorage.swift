//
//  JeweledStorage.swift
//  JeweledKit
//
//  Created by Борис Анели on 05.09.2020.
//

import Foundation
import CoreData

private enum Constants {
    
    static let idKey = "id"
    
    static let saveBatchSize = 100
    static let removeBatchSize = 100
}

public protocol JeweledStorageProtocol {
    var persistentContainer: NSPersistentContainer { get }
}

public final class JeweledStorage: JeweledStorageProtocol {
    
    public let persistentContainer: NSPersistentContainer
    
    public init(persistentContainer: NSPersistentContainer) {
        self.persistentContainer = persistentContainer
    }
    
    public func saveChanges() {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                assertionFailure("Couldn't save changes with error: \(error)")
            }
        }
    }
}

extension JeweledStorageProtocol {
    
    public func fetch<Model: JeweledIdentifiable & JeweledPersistable>(_ modelType: Model.Type, id: String) -> Model? {
        let predicate = NSPredicate(format: "\(Constants.idKey) == \(id)")
        return fetch(Model.self, predicate: predicate).first
    }
    
    public func fetch<Model: JeweledIdentifiable & JeweledPersistable>(_ modelType: Model.Type,
                                                                       predicate: NSPredicate? = nil,
                                                                       sortDescriptors: [NSSortDescriptor]? = nil) -> [Model] {
        let context = contextForCurrentThread()
        let fetchRequest = NSFetchRequest<Model.DBType>(entityName: Model.DBType.entityName())
        fetchRequest.predicate = predicate
        fetchRequest.sortDescriptors = sortDescriptors
        fetchRequest.returnsObjectsAsFaults = false
        
        var result: [Model] = []
        context.performAndWait {
            do {
                let fetched = try context.fetch(fetchRequest)
                result = fetched.compactMap(Model.from)
            } catch {
                let metadata = "entity: \(Model.DBType.entityName()), "
                + "predicate: \(predicate?.predicateFormat ?? ""), "
                + "sortDescriptorsCount: \(sortDescriptors?.count ?? 0),"
                + "error: \(error)"
                
                assertionFailure("Core Data Fetch Failed: \(metadata)")
            }
        }
        
        return result
    }
    
    public func save<Model: JeweledIdentifiable & JeweledPersistable>(_ object: inout Model) {
        let context = contextForCurrentThread()
        let predicate = NSPredicate(format: "\(Constants.idKey) == \(object.id)")
        let objectCopy = object
        
        context.applyStackChangesAndWait {
            self.removeAll(Model.self, with: predicate, in: context)
            objectCopy.createDB(in: context)
        }
        
        if let cachedObject = fetch(Model.self, id: "\(object.id)") {
            object = cachedObject
        } else {
            print("Core Data Fetch after Save Failed\nentity: \(Model.DBType.entityName()), id: \(object.id)")
        }
    }
    
    public func save<Model: JeweledIdentifiable & JeweledPersistable>(_ objects: inout [Model]) {
        let context = contextForCurrentThread()
        
        let batches = objects.split(batchSize: Constants.saveBatchSize)
        for var batch in batches {
            let objectsIds = batch.map({ "\($0.id)" })
            let predicate = NSPredicate(format: "\(Constants.idKey) IN %@", objectsIds)
            let batchCopy = batch
            
            context.applyStackChangesAndWait {
                self.removeAll(Model.self, with: predicate, in: context)
                _ = batchCopy.map({ $0.createDB(in: context) })
            }
            
            batch = fetch(Model.self, predicate: predicate)
            
            if batchCopy.count != batch.count {
                print("Core Data Fetch after Save Failed entity: \(Model.DBType.entityName()), id: \(objectsIds.joined(separator: ","))")
            }
        }
    }
    
    public func update<Model: JeweledIdentifiable & JeweledPersistable>(_ objects: [Model],
                                                                        updateBlock: @escaping (inout [Model.DBType], NSManagedObjectContext) -> Void) {
        let objectsIds = objects.map({ "\($0.id)" })
        let predicate = NSPredicate(format: "\(Constants.idKey) IN %@", objectsIds)
        
        let context = persistentContainer.viewContext
        context.performAndWait {
            var managedObjects = fetchManagedObjects(Model.self, predicate: predicate)
            updateBlock(&managedObjects, context)
            
            try? context.save()
        }
    }
    
    public func replaceAll<Model: JeweledIdentifiable & JeweledPersistable> (_ objects: inout [Model]) {
        removeAll(Model.self)
        save(&objects)
    }
    
    public func remove<Model: JeweledIdentifiable & JeweledPersistable>(_ object: Model) {
        remove(Model.self, id: "\(object.id)")
    }
    
    public func remove<Model: JeweledIdentifiable & JeweledPersistable>(_ modelType: Model.Type, id: String) {
        let context = contextForCurrentThread()
        let predicate = NSPredicate(format: "\(Constants.idKey) == %@", id)

        context.applyStackChangesAndWait {
            self.removeAll(Model.self, with: predicate, in: context)
        }
    }
    
    public func remove<Model: JeweledIdentifiable & JeweledPersistable>(_ objects: [Model]) {
        let context = contextForCurrentThread()
        
        let batches = objects.split(batchSize: Constants.removeBatchSize)
        for batch in batches {
            let objectsIds = batch.map({ $0.id })
            let predicate = NSPredicate(format: "\(Constants.idKey) IN %@", objectsIds)
            
            context.applyStackChangesAndWait {
                self.removeAll(Model.self, with: predicate, in: context)
            }
        }
    }
    
    // MARK: — Private
    
    private func fetchManagedObjects<Model>(_ modelType: Model.Type,
                                            predicate: NSPredicate? = nil,
                                            sortDescriptors: [NSSortDescriptor]? = nil,
                                            context: NSManagedObjectContext? = nil )
        -> [Model.DBType] where Model: JeweledIdentifiable & JeweledPersistable {
            
        let fetchRequest = NSFetchRequest<Model.DBType>(entityName: Model.DBType.entityName())
        fetchRequest.predicate = predicate
        fetchRequest.sortDescriptors = sortDescriptors
        fetchRequest.returnsObjectsAsFaults = false
        
        var result: [NSManagedObject] = []
        let context = context ?? contextForCurrentThread()
        context.performAndWait {
            do {
                result = try context.fetch(fetchRequest)
            } catch {
                print(error)
            }
        }
        
        return result as? [Model.DBType] ?? []
    }
    
    private func removeAll<Model: JeweledIdentifiable & JeweledPersistable>(_ entityType: Model.Type,
                                                                            with predicate: NSPredicate? = nil,
                                                                            in context: NSManagedObjectContext? = nil) {
        let objects = fetchManagedObjects(entityType, predicate: predicate, context: context)
        
        let context = context ?? contextForCurrentThread()
        context.applyStackChangesAndWait {
            for object in objects {
                context.delete(object)
            }
        }
    }
    
    private func contextForCurrentThread() -> NSManagedObjectContext {
        let concurrencyType: NSManagedObjectContextConcurrencyType =
            Thread.isMainThread ? .mainQueueConcurrencyType : .privateQueueConcurrencyType
        
        let context = NSManagedObjectContext(concurrencyType: concurrencyType)
        context.undoManager = nil
        context.parent = persistentContainer.viewContext
        
        return context
    }
}

extension NSManagedObjectContext {
    
    /// Асинхронно применяет изменения и сохраняет стек контекстов
    @objc func applyStackChanges(_ closure: @escaping () -> Void) {
        perform {
            closure()
            self.saveContextsStack()
        }
    }
    
    /// Синхронно применяет изменения и сохраняет стек контекстов
    @objc func applyStackChangesAndWait(_ closure: @escaping () -> Void) {
        performAndWait {
            closure()
            self.saveContextsStack()
        }
    }
    
    /// Сохраняет стек контекстов
    @objc func saveContextsStack() {
        var contextToSave: NSManagedObjectContext? = self
        
        while let currentContext = contextToSave {
            currentContext.performAndWait {
                do {
                    try currentContext.save()
                } catch {
                    print("Context saving failure: \(error)")
                }
            }
            
            contextToSave = currentContext.parent
        }
    }
}

extension Array {
    
    /// Разбивает массив на массивы с указанным размером.
    /// [1, 2, 3, 4, 5] -> [[1, 2], [3, 4], [5]]
    func split(batchSize: Int) -> [[Element]] {
        var batches: [[Element]] = []
        var batch: [Element] = []
        
        for element in self {
            batch.append(element)
            
            if batch.count == batchSize {
                batches.append(batch)
                batch = []
            }
        }
        
        if !batch.isEmpty {
            batches.append(batch)
        }
        
        return batches
    }
}
