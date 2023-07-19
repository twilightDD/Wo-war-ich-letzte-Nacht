//
//  TrackedLocation+CoreDataProperties.swift
//  Wo war ich letzte Nacht
//
//  Created by Peter Hauke on 19.07.23.
//
//

import Foundation
import CoreData


extension TrackedLocation {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<TrackedLocation> {
        return NSFetchRequest<TrackedLocation>(entityName: "TrackedLocation")
    }

    @NSManaged public var latitude: Double
    @NSManaged public var longitude: Double
    @NSManaged public var resolvedAddress: String?
    @NSManaged public var timeStamp: Date?
    @NSManaged public var trackedPlace: TrackedPlace?

}

extension TrackedLocation : Identifiable {

}
