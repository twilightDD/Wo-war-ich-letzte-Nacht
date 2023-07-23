//
//  TrackedVisit+CoreDataProperties.swift
//  Wo war ich letzte Nacht
//
//  Created by Peter Hauke on 19.07.23.
//
//

import Foundation
import CoreData


extension TrackedVisit {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<TrackedVisit> {
        return NSFetchRequest<TrackedVisit>(entityName: "TrackedVisit")
    }

    @NSManaged public var arrivalDate: Date?
    @NSManaged public var creationDate: Date
    @NSManaged public var departureDate: Date?
    @NSManaged public var horizontalAccuracy: Double
    @NSManaged public var latitude: Double
    @NSManaged public var longitude: Double
    @NSManaged public var pointOfInterest: String?
    @NSManaged public var placemark: String?
    @NSManaged public var trackingType: Int16
    @NSManaged public var uuid: UUID

}

extension TrackedVisit : Identifiable {

}
