//
//  File.swift
//  
//
//  Created by Mohamed Aglan on 4/29/24.
//

import Foundation
import CoreData


public protocol Object: NSManagedObject {
    static func fetchRequest() -> NSFetchRequest<Self>
}


public protocol CoreDataWrapping {
    func saveContext()
    func createObject<T: Object>(ofType type: T.Type) -> T
    func fetchObjects<T: Object>(ofType type: T.Type,
                                 predicate: NSPredicate?,
                                 sortDescriptors: [NSSortDescriptor]?) -> [T]
    func createRoom<T: Object>(ofType type: T.Type) -> T
    
}


public extension CoreDataWrapping {
    func fetchObjects<T: Object>(ofType type: T.Type,
                                 predicate: NSPredicate? = nil,
                                 sortDescriptors: [NSSortDescriptor]? = nil) -> [T] {
        fetchObjects(ofType: type,
                     predicate: predicate,
                     sortDescriptors: sortDescriptors)
    }
}


public final class CoreDataWrapper: CoreDataWrapping {
    
    private let persistentContainer: NSPersistentContainer

    public init(modelName: String) {
        guard let modelURL = Bundle.module.url(forResource: modelName, withExtension: "momd"),
              let model = NSManagedObjectModel(contentsOf: modelURL) else {
            fatalError("Unable to create model with name: \(modelName) in module bundle")
        }

        persistentContainer = NSPersistentContainer(name: modelName, managedObjectModel: model)
        persistentContainer.loadPersistentStores { (_, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        }
    }

    public func saveContext() {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }

    public func createObject<T: Object>(ofType type: T.Type) -> T {
        return T(context: persistentContainer.viewContext)
    }

    public func fetchObjects<T: Object>(ofType type: T.Type,
                                        predicate: NSPredicate? = nil,
                                        sortDescriptors: [NSSortDescriptor]? = nil) -> [T] {
        let fetchRequest: NSFetchRequest<T> = T.fetchRequest()
        fetchRequest.predicate = predicate
        fetchRequest.fetchLimit = .max
        fetchRequest.sortDescriptors = sortDescriptors

        do {
            return try persistentContainer.viewContext.fetch(fetchRequest)
        } catch {
            print("Fetch error: \(error)")
            return []
        }
    }
    
    
    public func createRoom<T: Object>(ofType type: T.Type) -> T {
        return T(context: persistentContainer.viewContext)
    }
    
    
}
