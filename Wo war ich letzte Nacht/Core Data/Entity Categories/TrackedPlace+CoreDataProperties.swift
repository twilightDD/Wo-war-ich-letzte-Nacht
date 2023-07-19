//
//  TrackedPlace+CoreDataProperties.swift
//  Wo war ich letzte Nacht
//
//  Created by Peter Hauke on 19.07.23.
//
//

import Foundation
import CoreData


extension TrackedPlace {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<TrackedPlace> {
        return NSFetchRequest<TrackedPlace>(entityName: "TrackedPlace")
    }

    @NSManaged public var uuid: UUID
    
    @NSManaged public var address: String?
    @NSManaged public var trackedLocations: TrackedLocation?

}

extension TrackedPlace : Identifiable {

}
