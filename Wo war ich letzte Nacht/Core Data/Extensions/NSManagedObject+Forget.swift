//
//  NSManagedObjectContext+Forget.swift
//  Landrix Handwerk Mobile
//
//  Created by Peter Hauke on 23.08.19.
//  Copyright © 2019 Landrix Software GmbH & Co. KG. All rights reserved.
//

import Foundation
import CoreData


// MARK: - Extension - Forget
extension SOXManagedObject {

    //MARK: - Public Class Methods
    /// Forget all `managedObjects` of this class.
    /// - Warning: Does **not save** the `context`.
    /// - Parameters:
    ///   - predicate: The `predicate`.
    ///   - context: Default is `newBackgroundTaskContext`.
    /// - Returns: `Count` of deleted objects.
    @discardableResult
    class func forgetAll(predicate: NSPredicate? = nil,
                         inContext context: NSManagedObjectContext = SOXCoreDatabase.newBackgroundTaskContext())
    -> Int {
        let objectsToDelete = context.fetchObjects(forEntityClass: self,
                                                   predicate: predicate,
                                                   returnsObjectsAsFaults: true)
        objectsToDelete.forEach { context.delete($0) }
        
        let count = objectsToDelete.count
        return count
    }

    
    //MARK: - Public Instance Methods
    /// Deletes managedObject in its context.
    /// - Returns: Success.
    @objc
    @discardableResult
    func forget()
    -> Bool {
        var isDeleted = self.isDeleted
        
        if !isDeleted {
            self.context().delete(self)
            isDeleted = self.isDeleted
        }
        
        return isDeleted
    }
    
}
 
