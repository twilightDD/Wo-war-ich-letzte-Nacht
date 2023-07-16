//
//  NSManagedObjectContext+Delete.swift
//  Landrix Handwerk Mobile
//
//  Created by Peter Hauke on 13.11.19.
//  Copyright © 2019 Landrix Software GmbH & Co. KG. All rights reserved.
//

import Foundation
import CoreData


// MARK: - Extension - Forget
extension NSManagedObjectContext {
    
    //MARK: - Public Instance Methods
    func forgetAllObjects(forEntityWithName entityName: String)
        -> Bool {

            let fetchRequest: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest()
            fetchRequest.entity = NSEntityDescription.entity(forEntityName: entityName,
                                                             in: self)
            do {
                let objectsForEntity = try self.fetch(fetchRequest) as? [SOXManagedObject]
                objectsForEntity?.forEach( { $0.forget() })
            }
            catch let fetchError {
                fatalError("\(fetchError.localizedDescription)")
            }

            return true
    }

    /// Managed objects of all entities, except the Account object.
    func forgetAllDatabaseObjects()
    -> Bool {
        var success = false
        
        // All entities, except the Account object
        let entityNamesToRemove = SOXCoreDatabase.entityNames()
        
        // forget all objects
        for entityNameToRemove in entityNamesToRemove {
            success = self.forgetAllObjects(forEntityWithName: entityNameToRemove)
        }
        
        return success
    }

    
    func cleanupDatabaseObjects<T: SOXManagedObject>(ofEntityClass entityClass: T.Type,
                                                     predicate: NSPredicate? = nil,
                                                     keep objectsToKeep: Set<T>) {
        
        let fetchedObjectsAsSet = fetchObjectsAsSet(forEntityClass: entityClass,
                                                    predicate: predicate)

        let objectsToRemove = fetchedObjectsAsSet.subtracting(objectsToKeep)
        
        objectsToRemove.forEach( { $0.forget() })
    }
    
}
