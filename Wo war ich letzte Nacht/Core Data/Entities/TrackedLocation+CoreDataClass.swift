//
//  TrackedLocation+CoreDataClass.swift
//  Wo war ich letzte Nacht
//
//  Created by Peter Hauke on 19.07.23.
//
//

import Foundation
import CoreData

@objc(TrackedLocation)
public class TrackedLocation: SOXManagedObject {

    static func insert(in context: NSManagedObjectContext,
                       latitude: Double, longitude: Double)
    -> TrackedLocation {
        
        let newTrackedLocation = TrackedLocation(context: context, uuid: UUID())
        newTrackedLocation.latitude = latitude
        newTrackedLocation.longitude = longitude
        newTrackedLocation.timeStamp = Date()
        
        return newTrackedLocation
    }
    
}
