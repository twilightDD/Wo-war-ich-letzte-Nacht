//
//  NSMangedObjectContext+FetchMethods.swift
//  Landrix Handwerk Mobile
//
//  Created by Peter Hauke on 26.06.19.
//  Copyright © 2019 Landrix Software GmbH & Co. KG. All rights reserved.
//

import Foundation
import CoreData


//MARK: - Convenient Fetch Methods
extension NSManagedObjectContext {

    func fetchObjectsAsSet <T: SOXManagedObject>(forEntityClass entityClass:T.Type,
                                                fetchLimit: Int? = 0,
                                                predicate: NSPredicate? = nil,
                                                predicateString: String? = nil,
                                                predicateArguments: [Any]? = nil,
                                                returnsObjectsAsFaults: Bool = false)
        -> Set<T> {

            let fetchedObjects: [T] = fetchObjects(forEntityClass: entityClass,
                                                   fetchLimit: fetchLimit,
                                                   predicate: predicate,
                                                   predicateString: predicateString,
                                                   predicateArguments: predicateArguments,
                                                   returnsObjectsAsFaults: returnsObjectsAsFaults)

            let fetchedObjectsAsSet = Set.init(fetchedObjects)
            return fetchedObjectsAsSet
    }


    func fetchUniqueObject <T: SOXManagedObject>(forEntityClass entityClass:T.Type,
                                                predicate: NSPredicate? = nil,
                                                predicateString: String? = nil,
                                                predicateArguments: [Any]? = nil,
                                                returnsObjectsAsFaults: Bool = false)
        -> T? {
            let fetchedObjects: [T] = fetchObjects(forEntityClass: entityClass,
                                                   predicate: predicate,
                                                   predicateString: predicateString,
                                                   predicateArguments: predicateArguments,
                                                   returnsObjectsAsFaults: returnsObjectsAsFaults)

            guard fetchedObjects.count < 2
                else { fatalError("There must be no more than one managedObject of type \(T.self) with predicate \(String(describing: predicate))") }

            let fetchedUniqueObject = fetchedObjects.first
            return fetchedUniqueObject
    }


    func fetchObjects <T: SOXManagedObject>(forEntityClass entityClass:T.Type,
                                           sortDescriptors: [NSSortDescriptor]? = nil,
                                           sortByKeypath sortKeyPath: String? = nil,
                                           sortByKeypaths sortKeyPaths: [String]? = nil,
                                           reverseSortByKeypath reverseSortKeypath: String? = nil,
                                           fetchLimit: Int? = 0,
                                           predicate: NSPredicate? = nil,
                                           predicateString: String? = nil,
                                           predicateArguments: [Any]? = nil,
                                           returnsObjectsAsFaults: Bool = false)
        -> [T] {

            let request = fetchRequestFor(forEntityClass: entityClass,
                                          sortDescriptors: sortDescriptors,
                                          sortByKeypath: sortKeyPath,
                                          sortByKeypaths: sortKeyPaths,
                                          reverseSortByKeypath: reverseSortKeypath,
                                          fetchLimit: fetchLimit,
                                          predicate: predicate,
                                          predicateString: predicateString,
                                          predicateArguments: predicateArguments,
                                          returnsObjectsAsFaults: returnsObjectsAsFaults)

            // Fetch
            do {
                let fetchedResult = try self.fetch(request)
                return fetchedResult
            }
            catch let fetchError {
                print("\(fetchError.localizedDescription)")
                fatalError()
            }
    }

}


//MARK: - Convenient Count Methods
extension NSManagedObjectContext {

    func countOfObjects <T: SOXManagedObject>(forEntityClass entityClass: T.Type,
                                             predicate: NSPredicate? = nil,
                                             predicateString: String? = nil,
                                             predicateArguments: [Any]? = nil)
    -> Int {
        let request = fetchRequestFor(forEntityClass: entityClass,
                                      predicate: predicate,
                                      predicateString: predicateString,
                                      predicateArguments: predicateArguments,
                                      returnsObjectsAsFaults: true)
        
        var count = 0
        
        performAndWait {
            do {
                count = try self.count(for: request)
            }
            catch let fetchError {
                print("\(fetchError.localizedDescription)")
                fatalError()
            }
        }
        
        return count
    }
}


//MARK: - Extension - NSManagedObjectIDs
extension NSManagedObjectContext {
    
    func fetchObjectIDs(forEntityClass entityClass: SOXManagedObject.Type,
                        predicate: NSPredicate? = nil,
                        predicateString: String? = nil,
                        predicateArguments: [Any]? = nil)
    -> [NSManagedObjectID] {
        
        let request = NSFetchRequest<NSFetchRequestResult>.init(entityName: entityClass.entityName())
        request.resultType = .managedObjectIDResultType
        
        // handle predicate
        var finalPredicate: NSPredicate?
        if let predicate = predicate {
            finalPredicate = predicate
        }
        else if let predicateString = predicateString {
            finalPredicate = NSPredicate.init(format: predicateString, argumentArray: predicateArguments)
        }
        request.predicate = finalPredicate
        
        
        // Fetch
        do {
            let fetchResult = try self.fetch(request)
            if let objectIDs = fetchResult as? [NSManagedObjectID] {
                return objectIDs
            }
            else {
                fatalError("FetchResult is not a [NSManagedObjectID] \n type is: \(fetchResult.self)")
            }
        }
        catch let fetchError {
            print("\(fetchError.localizedDescription)")
            fatalError()
        }
    }
    
}

//MARK: - Extension - NSFetchRequest
private extension NSManagedObjectContext {

    func fetchRequestFor <T: SOXManagedObject> (forEntityClass entityClass:T.Type,
                                               sortDescriptors: [NSSortDescriptor]? = nil,
                                               sortByKeypath sortKeyPath: String? = nil,
                                               sortByKeypaths sortKeyPaths: [String]? = nil,
                                               reverseSortByKeypath reverseSortKeypath: String? = nil,
                                               fetchLimit: Int? = 0,
                                               predicate: NSPredicate? = nil,
                                               predicateString: String? = nil,
                                               predicateArguments: [Any]? = nil,
                                               returnsObjectsAsFaults: Bool = false)
        -> NSFetchRequest<T> {

            // FetchRequest
            let request: NSFetchRequest<T>
            request = entityClass.fetchRequest() as! NSFetchRequest<T>
            request.returnsObjectsAsFaults = returnsObjectsAsFaults
            request.fetchLimit = fetchLimit!

            // Handle sortDescriptors
            var finalSortDescriptors: [NSSortDescriptor] = sortDescriptors ?? []

            if let sortKeyPath = sortKeyPath {
                let sortDescriptor = NSSortDescriptor.init(key: sortKeyPath, ascending: true)
                finalSortDescriptors.append(sortDescriptor)
            }
            if let sortKeyPaths = sortKeyPaths {
                for sortKeyPath in sortKeyPaths {
                    let sortDescriptor = NSSortDescriptor.init(key: sortKeyPath, ascending: true)
                    finalSortDescriptors.append(sortDescriptor)
                }
            }
            if let reverseSortKeypath = reverseSortKeypath {
                let sortDescriptor = NSSortDescriptor.init(key: reverseSortKeypath, ascending: false)
                finalSortDescriptors.append(sortDescriptor)
            }
            request.sortDescriptors = finalSortDescriptors


            // handle predicate
            var finalPredicate: NSPredicate?
            if let predicate = predicate {
                finalPredicate = predicate
            }
            else if let predicateString = predicateString {
                finalPredicate = NSPredicate.init(format: predicateString, argumentArray: predicateArguments)
            }
            request.predicate = finalPredicate

            // Return request
            return request
    }

}


// MARK: - Weblinks
/*
 https://stackoverflow.com/questions/47680199/abstracting-core-data-fetch-request
 https://codereview.stackexchange.com/questions/147005/swift-3-generic-fetch-request-extension
 */
