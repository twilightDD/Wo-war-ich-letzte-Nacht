//
//  NSManagedObject+Debugging.swift
//  Landrix Handwerk Mobile
//
//  Created by Peter Hauke on 19.10.19.
//  Copyright © 2019 Landrix Software GmbH & Co. KG. All rights reserved.
//
import Foundation
import CoreData


// MARK: - Extension: Debugging
extension SOXManagedObject {
    
    //MARK: Debug Descriptions
    func debugDesciption(withObjectID: Bool = false)
    -> String {
        var debugDesciption = ""
        debugDesciption.append(attributesDescription())
        debugDesciption.append("-------------------------\n")
        debugDesciption.append(relationshipsDescription())
        if withObjectID {
            debugDesciption.append("-------------------------\n")
            debugDesciption.append(objectIDDescription())
        }
        
        return debugDesciption
    }

    
    /// Returns description of `attributes` and extended description of `relationships.
    /// - Returns: A string.
    func debugDesciptionExtended()
    -> String {
        var debugDesciptionExtended = ""
        debugDesciptionExtended.append(attributesDescription())
        debugDesciptionExtended.append("-------------------------\n")
        debugDesciptionExtended.append(relationshipsExtendedDescription(except: [self]))
        
        return debugDesciptionExtended
    }

    
    func attributesDescription()
    -> String {
        var attributesDescription = "### Attributes:\n"
        
        for attributeAndValue in attributesAndValues() {
            let key = attributeAndValue.keys.first!
            let value = attributeAndValue.values.first ?? "-"
            attributesDescription.append("\(key): \(value)\n")
        }
        
        return attributesDescription
    }

    
    func relationshipsDescription()
    -> String {
        var relationshipsDescription = "### Relationships (count / uuids of related objects):\n"
        
        for relationshipAndCount in relationshipsAndCount() {
            if let relationshipName = relationshipAndCount["relationship"] as? String {
                relationshipsDescription.append("\(relationshipName)\n")
            }
            if let uuids = relationshipAndCount["uuids"] as? [String] {
                let uuidString = uuids.joined(separator: "\n")
                relationshipsDescription.append("\(uuidString)\n")
            }
        }
        
        return relationshipsDescription
    }

    
    func objectIDDescription()
    -> String {
        let objectIDDescription = "objectID: \(objectID)"
        return objectIDDescription
    }


    func relationshipsExtendedDescription(except objectsNotToDescribe: [SOXManagedObject])
    -> String {
        var relationshipsExtendedDescription = "......\n extDesc: \(type(of: self))\n"
        
        let relationshipNames = sortedRelationshipsByName()
        
        for relationshipName in relationshipNames {
            // Relationship information
            guard let relationshipDescription = entity.relationshipsByName[relationshipName] else {
                fatalError("relationshipDescription not found for: \(relationshipName).") }
            
            //                guard let inverseRelationshipDescription = relationshipDescription.inverseRelationship
            //                    else { fatalError("reverserEntity not found.")}
            
            var relatedObjects = Set<SOXManagedObject>()

            // to one
            if relationshipDescription.isToMany == false,
               let relatedObject = self.value(forKey: relationshipName) as? SOXManagedObject {
                relatedObjects.insert(relatedObject)
            }
            // to many
            else if let objects = self.value(forKey: relationshipName) as? Set<SOXManagedObject> {
                relatedObjects.formUnion(objects)
            }
            
            for relatedObject in relatedObjects {
                if objectsNotToDescribe.contains(relatedObject) == false {
                    relationshipsExtendedDescription.append("~~~")
                    var newObjectsNotToDescribe = objectsNotToDescribe
                    newObjectsNotToDescribe.append(self)
                    let relatedObjectRelationshipsExtendedDescription = relatedObject.relationshipsExtendedDescription(except: newObjectsNotToDescribe)
                    relationshipsExtendedDescription.append(relatedObjectRelationshipsExtendedDescription)
                    relationshipsExtendedDescription.append("\n")
                    relationshipsExtendedDescription.append("~~~")
                }
            }
        }
        
        return relationshipsExtendedDescription
    }


    func attributesAndValues()
    -> [[String : Any]] {
        var attributesAndValues = [[String : Any]]()
        
        let attributes = entity.attributesByName.keys.sorted()
        for attribute in attributes {
            attributesAndValues.append([attribute : value(forKey: attribute) ?? "value is nil"])
        }
        
        return attributesAndValues
    }
    
    
    func relationshipsAndCount()
    -> [[String : Any]] {
        var relationshipsAndCount = [[String : Any]]()
        let relationshipNames = sortedRelationshipsByName()
        
        for relationshipName in relationshipNames {
            // Relationship information
            guard let relationshipDescription = entity.relationshipsByName[relationshipName] else {
                fatalError("relationshipDescription not found for: \(relationshipName).") }
            guard let destinationEntityName = relationshipDescription.destinationEntity?.name,
                  let destinationEntityType = NSClassFromString(destinationEntityName) as? SOXManagedObject.Type else {
                fatalError("destinationEntity or destinationEntityType not found for: \(relationshipName).")}
            guard let inverseRelationship = relationshipDescription.inverseRelationship else {
                fatalError("inverseRelationship not found for: \(relationshipName).")}
            
           
            // Count of related objects
            var predicate: NSPredicate?
            if inverseRelationship.isToMany == false { // to one
                predicate = NSPredicate.init(format: "%K == %@", inverseRelationship.name, self)
            }
            else { // to many
                predicate = NSPredicate.init(format: "%@ IN %K", self, inverseRelationship.name)
            }
            
            let count = context().countOfObjects(forEntityClass: destinationEntityType,
                                                       predicate: predicate)
            relationshipsAndCount.append(["relationship" : "\(relationshipName) \(count)"])
            
            
            // If there are related objects show their uuids
            if count > 0 {
                var uuidStrings = [String]()
                
                // To one
                if relationshipDescription.isToMany == false {
                    let relatedObject = self.value(forKey: relationshipName) as! SOXManagedObject
                    if let uuid = relatedObject.value(forKeyPath: SOXManagedObject.Attributes.uuid) as? UUID {
                        uuidStrings.append("     \(uuid.uuidString)")
                    }
                    else {
                        uuidStrings.append("     <Keine UUID>")
                    }
                    relationshipsAndCount.append(["uuids" : uuidStrings])
                }
                // to many
                else {
                    let relatedObjects = self.value(forKey: relationshipName) as! Set<SOXManagedObject>
                    
                    for relatedObject in relatedObjects {
                        if let uuid = relatedObject.value(forKeyPath: SOXManagedObject.Attributes.uuid) as? UUID {
                            uuidStrings.append("     \(uuid.uuidString)")
                        }
                        else {
                            uuidStrings.append("     <Keine UUID>")
                        }
                    }
                    
                    uuidStrings.sort()
                    relationshipsAndCount.append(["uuids" : uuidStrings])
                }
            }
        }
        
        return relationshipsAndCount
    }

    
    func sortedRelationshipsByName()
    -> [String] {
        let sortedRelationShips = entity.relationshipsByName.keys.sorted()
        return sortedRelationShips
    }
    
}
