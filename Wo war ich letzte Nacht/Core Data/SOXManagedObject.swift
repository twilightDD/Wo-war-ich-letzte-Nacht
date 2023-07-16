//
//  SOXManagedObject.swift
//  Landrix Handwerk Mobile
//
//  Created by Peter Hauke on 27.03.21.
//  Copyright © 2021 Landrix Software GmbH & Co. KG. All rights reserved.
//

import Foundation

import CoreData


//MARK: -
//MARK: - SOXManagedObjectProtocol
protocol SOXManagedObjectProtocol {
    
    associatedtype T = SOXManagedObject
    
}


//MARK: -
//MARK: - SOXManagedObject
public class SOXManagedObject: NSManagedObject, SOXManagedObjectProtocol {
    
    //MARK: Default Keys
    public struct Attributes {
        static let uuid = "uuid"
    }
    
    //MARK: - Init&Co
    // See: https://stackoverflow.com/a/26206303/7885522 and following comment
    @objc
    private override init(entity: NSEntityDescription,
                          insertInto context: NSManagedObjectContext?) {
        super.init(entity: entity, insertInto: context)
    }
    
    
    required init(context: NSManagedObjectContext, uuid: UUID) {
        let entityDescription = Self.entity()
        super.init(entity: entityDescription, insertInto: context)
        
        setValue(uuid, forKey: SOXManagedObject.Attributes.uuid)
    }
    
}


extension SOXManagedObject{

    class func allObjects(sortByKeypaths: [String]? = nil,
                          inContext context: NSManagedObjectContext = SOXCoreDatabase.viewOnlyContext())
    -> [T] {
        let allObjects = context.fetchObjects(forEntityClass: Self.self,
                                              sortByKeypaths: sortByKeypaths)
        
        return allObjects
    }
    
}
