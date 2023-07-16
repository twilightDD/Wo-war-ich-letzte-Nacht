//
//  NSManagedObjectContext+Filters.swift
//  Landrix Handwerk Mobile
//
//  Created by Peter Hauke on 28.10.19.
//  Copyright © 2019 Landrix Software GmbH & Co. KG. All rights reserved.
//

import Foundation
import CoreData

extension NSManagedObjectContext {
    func filterDeletedObjects<T: Hashable>(forEntityClass entityClass:T.Type)
        -> [T] {
            var filterDeletedObjects = [T]()

            for deletedObject in deletedObjects {
                if let deletedType = deletedObject as? T {
                    filterDeletedObjects.append(deletedType)
                }
            }

            return filterDeletedObjects
    }


}
