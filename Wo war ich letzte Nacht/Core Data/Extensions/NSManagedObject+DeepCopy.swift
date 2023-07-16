//
//  NSManagedObject+DeepCopy.swift
//  Landrix Handwerk Mobile
//
//  Created by Peter Hauke on 20.07.20.
//  Copyright © 2020 Landrix Software GmbH & Co. KG. All rights reserved.
//

import Foundation

import CoreData

//MARK: - Protocol - Clonable
protocol Clonable {
    associatedtype ClonableType: SOXManagedObject = Self
}

//MARK: - Extension - Clonable
extension SOXManagedObject: Clonable {

    func deepCopy<T: SOXManagedObject>(withUUID uuid: UUID? = UUID())
    -> T {
        guard let clonedObject = NSEntityDescription.insertNewObject(forEntityName: entity.managedObjectClassName,
                                                                     into: context()) as? T
        else { fatalError("Somethin went wrong on the internet.") }
        
        // Copy attributes
        let attributesByName = entity.attributesByName
        for (attributeName, _) in attributesByName {
            clonedObject.setValue(value(forKey: attributeName),
                                  forKey: attributeName)
        }
        
        // Copy relationships
        let relationshipsByName = entity.relationshipsByName
        
        for (relationshipName, relationshipDescription) in relationshipsByName {
            // if relationship is not set we can skip
            guard let relatedObject = value(forKey: relationshipName) as? SOXManagedObject,
                  let inverseRelationship = relationshipDescription.inverseRelationship else {
                continue }
            
            // The relation of the relatedObject is 'toMany' to this class
            
            if inverseRelationship.isToMany == true {
                clonedObject.setValue(relatedObject,
                                      forKey: relationshipName)
            }
            else {
                // The relation of the relatedObject is 'toOne' to this class
                // it means: we need to clone the relatedObject, too
                fatalError("Well ... @Peter: u need to implement this")
                /*
                 https://medium.com/@puneet.gurtoo0/deep-copy-an-nsmanagedobject-with-one-one-relationships-2b43354b004f⁄
                 
                 https://medium.com/@shtopointo/copying-and-nsmanagedobjects-part-2-2-b90cc184e130
                 https://gist.github.com/shto/9552503
                 */
            }
            
        }
        
        // MARK: set a uuid
        clonedObject.setValue(uuid,
                              forKey: SOXManagedObject.Attributes.uuid)
        return clonedObject
    }

}
