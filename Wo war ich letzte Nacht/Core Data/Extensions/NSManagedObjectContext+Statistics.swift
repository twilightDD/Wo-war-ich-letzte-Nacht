//
//  NSManagedObjectContext+Statistics.swift
//  Landrix Handwerk Mobile
//
//  Created by Peter Hauke on 21.01.20.
//  Copyright © 2020 Landrix Software GmbH & Co. KG. All rights reserved.
//

import Foundation

import CoreData

//MARK: - Extension - Changes Statistics
extension NSManagedObjectContext {

    func insertedObjectsStatistics()
        -> NSCountedSet {
            let insertedObjectsStatistics = NSCountedSet.init()

            for insertedObject in insertedObjects {
                insertedObjectsStatistics.add(insertedObject.entity.managedObjectClassName!)
            }

            return insertedObjectsStatistics
    }


    func updatedObjectsStatistics()
        -> NSCountedSet {
            let updatedObjectsStatistics = NSCountedSet.init()

            for updatedObject in updatedObjects {
                if updatedObject.hasPersistentChangedValues == true {
                    updatedObjectsStatistics.add(updatedObject.entity.managedObjectClassName!)
                }
            }

            return updatedObjectsStatistics
    }


    func deletedObjectsStatistics()
        -> NSCountedSet {
            let deletedObjectsStatistics = NSCountedSet.init()

            for deletedObjects in deletedObjects {
                deletedObjectsStatistics.add(deletedObjects.entity.managedObjectClassName!)
            }

            return deletedObjectsStatistics
    }

}


//MARK: - Landrix specific statistics
extension NSManagedObjectContext {

    func insertedStatisticsString()
        -> String {
            let insertedStatistics = insertedObjectsStatistics()
            let insertedStatisticsString = statisticsString(fromStatistics: insertedStatistics)

            return insertedStatisticsString
    }

    func updatedStatisticsString()
        -> String {
            let updatedStatistics = updatedObjectsStatistics()
            let updatedStatisticsString  = statisticsString(fromStatistics: updatedStatistics)

            return updatedStatisticsString
    }

    func deletedStatisticsString()
        -> String {
            let deletedStatistics = deletedObjectsStatistics()
            let deletedStatisticsString  = statisticsString(fromStatistics: deletedStatistics)
            return deletedStatisticsString
    }

    private func statisticsString(fromStatistics statistics: NSCountedSet)
        -> String {
            return "statisticsString"
//            let statisticsString  = "\(statistics.count(for: Project.entityName())) Vorgänge, \(statistics.count(for: WorkOrder.entityName())) Arbeitsaufträge, \(statistics.count(for: ProjectAddress.entityName()))  Adressen, \(statistics.count(for: Document.entityName())) Dokumente, \(statistics.count(for: Picture.entityName())) Bilder, \(statistics.count(for: MaintenanceContract.entity())) Wartungsverträge"
//            return statisticsString
    }

}
