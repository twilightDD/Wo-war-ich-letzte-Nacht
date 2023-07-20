//
//  TrackedVisit+CoreDataClass.swift
//  Wo war ich letzte Nacht
//
//  Created by Peter Hauke on 19.07.23.
//
//

import Foundation
import CoreData

@objc(TrackedVisit)
public class TrackedVisit: SOXManagedObject {

    
    static func insert(inContext context: NSManagedObjectContext,
                       arrivalDate: Date?,
                       departureDate: Date?,
                       horizontalAccuracy: Double,
                       latitude: Double,
                       longitude: Double)
    -> TrackedVisit {
        let newTrackedVisit = TrackedVisit(context: context, uuid: UUID())
        
        newTrackedVisit.arrivalDate = arrivalDate
        newTrackedVisit.departureDate = departureDate
        newTrackedVisit.horizontalAccuracy = horizontalAccuracy
        newTrackedVisit.latitude = latitude
        newTrackedVisit.longitude = longitude
        
        return newTrackedVisit
    }
    
}


//MARK: - Attributes and Relations
extension TrackedVisit {
    
    struct Attributes {
        static let arrivalDate = "arrivalDate"
    }
    
    struct Relationships {
    }
    
}
