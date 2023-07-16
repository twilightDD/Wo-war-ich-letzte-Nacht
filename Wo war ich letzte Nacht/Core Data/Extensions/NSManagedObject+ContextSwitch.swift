//
//  NSManagedObject+ContextSwitch.swift
//  Landrix Handwerk Mobile
//
//  Created by Peter Hauke on 15.07.19.
//  Copyright © 2019 Landrix Software GmbH & Co. KG. All rights reserved.
//

import Foundation
import CoreData

// MARK: - Extension: EntityName
extension SOXManagedObject {
    
    /// Secures the `context` of `self`.
    ///
    /// Remember: `self.managedObjectContext` is weak.
    ///
    /// - Returns: The guard let'ed `context`.
    func context()
    -> NSManagedObjectContext  {
        guard let objectCurrentContext = self.managedObjectContext else {
            fatalError("\(self) has no context.") }
        return objectCurrentContext
    }

    
    /// Gets `self` in given `context`.
    ///
    /// - Warning: Raises a `fatalError()` if `self` is `temporary`.
    ///
    /// - Parameter context: The `context`.
    /// - Returns: `self` in given `context`.
    func getIn(context: NSManagedObjectContext)
    -> Self {
        
        if self.context() == context {
            return self
        }
        
        if objectID.isTemporaryID {
            fatalError("This managedObject is temporary and does not exists in another context: \n\(self)")
        }
        
        let objectInContext = context.object(with: self.objectID) as! Self
        return objectInContext
    }
    
}
