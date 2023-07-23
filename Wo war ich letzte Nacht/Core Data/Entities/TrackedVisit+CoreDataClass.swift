//
//  TrackedVisit+CoreDataClass.swift
//  Wo war ich letzte Nacht
//
//  Created by Peter Hauke on 19.07.23.
//
//

import Foundation

import CoreData

import CoreLocation
import UIKit

@objc(TrackedVisit)
public class TrackedVisit: SOXManagedObject {

    typealias CompletionBlock = () -> ()
    
    var datesDescription: String { datesDescriptionMethod() }
    
    var trackingColor: UIColor {
        let t = TrackedVisit.TrackingType.init(rawValue: self.trackingType) ?? .unknown
        let color = TrackingType.color(forTrackingType: t)
        return color
    }
    
    static func insert(inContext context: NSManagedObjectContext,
                       trackingType: TrackingType,
                       arrivalDate: Date?,
                       departureDate: Date?,
                       horizontalAccuracy: Double,
                       latitude: Double,
                       longitude: Double)
    -> TrackedVisit {
        let newTrackedVisit = TrackedVisit(context: context, uuid: UUID())
        
        newTrackedVisit.arrivalDate = arrivalDate
        newTrackedVisit.creationDate = Date()
        newTrackedVisit.departureDate = departureDate
        newTrackedVisit.horizontalAccuracy = horizontalAccuracy
        newTrackedVisit.latitude = latitude
        newTrackedVisit.longitude = longitude
        newTrackedVisit.trackingType = trackingType.rawValue
        
        return newTrackedVisit
    }
    
    /// Updates visit object and saves it in context
    func updateAndSaveWith(placemark: CLPlacemark,
                           inContext context: NSManagedObjectContext = SOXCoreDatabase.newEditContext(forUI: true),
                           completionBlock: CompletionBlock? = nil) {
        
        
        var placemarkElements: [String] = []
        
        let areasOfInterest = placemark.areasOfInterest     // AOIs
        let name = placemark.name                           // Name or Street+Number
        let thoroughfare = placemark.thoroughfare           // Street
        let subThoroughfare = placemark.subThoroughfare     // Number
        let locality = placemark.locality                   // City
        
        // Area Of Interest or "Name"
        if let areasOfInterest,
            let firstAOI = areasOfInterest.first {
            placemarkElements.append(firstAOI)
            pointOfInterest = firstAOI
        }
        else if let name {
            placemarkElements.append(name)
            pointOfInterest = name
        }
        
        // Street + Number - may be same as "name". If so, don't add it
        if let thoroughfare {
            if let subThoroughfare {
                let streetAndNumber = thoroughfare + " " + subThoroughfare
                if let name,
                   name != streetAndNumber {
                    placemarkElements.append(streetAndNumber)
                }
            }
        }
        
        if let locality {
            placemarkElements.append(locality)
        }
        
        let placemarkString = placemarkElements.joined(separator: ", ")
      
        
        if placemarkString.count > 0 {
            context.performAndSave(
                { [weak self] context in
                    let visitInContext = self?.getIn(context: context)
                    visitInContext?.placemark = placemarkString
                },
                completionBlock: {
                    completionBlock?()
                })
        }
    }
    
    
    static func importVisits(_ importDicts: [[String : Any]])
    -> Bool {
        let editContext = SOXCoreDatabase.newEditContext(forUI: true)
        editContext.performAndWaitAndSave( { editContext in
            importDicts.forEach( { importDict in
                guard let horizontalAccuracy = importDict[Attributes.horizontalAccuracy] as? Double,
                      let latitude = importDict[Attributes.latitude] as? Double,
                      let longitude = importDict[Attributes.longitude] as? Double,
                      let uuidString = importDict[Attributes.uuid] as? String,
                      let uuid = UUID(uuidString: uuidString)
                
                else { return }
                
                let importedVisit = TrackedVisit(context: editContext, uuid: uuid)
                // Required attributes
                var creationDate: Date
                if let creationDateFromImport = SOXDateFormatter.dateFromRFC(string: importDict[Attributes.creationDate] as? String) {
                    creationDate = creationDateFromImport
                }
                else {
                    creationDate = Date.distantPast
                }
                importedVisit.creationDate = creationDate
                importedVisit.horizontalAccuracy = horizontalAccuracy
                importedVisit.latitude = latitude
                importedVisit.longitude = longitude
                // Optional attributes
                importedVisit.arrivalDate = SOXDateFormatter.dateFromRFC(string: importDict[Attributes.arrivalDate] as? String)
                importedVisit.departureDate = SOXDateFormatter.dateFromRFC(string: importDict[Attributes.departureDate] as? String)
                importedVisit.placemark = importDict[Attributes.placemark] as? String
                importedVisit.trackingType = importDict[Attributes.trackingType] as? Int16 ?? 0
                importedVisit.pointOfInterest = importDict[Attributes.pointOfInterest] as? String
                
            })
        })
       
        
        return true
    }
    
    func exportDictionary()
    -> [String: Any] {
        var exportDictionary: [String : Any] = [ : ]
        exportDictionary[TrackedVisit.Attributes.arrivalDate] = SOXDateFormatter.rfcDateStringFromDate(arrivalDate)
        exportDictionary[TrackedVisit.Attributes.creationDate] = SOXDateFormatter.rfcDateStringFromDate(creationDate)
        exportDictionary[TrackedVisit.Attributes.departureDate] = SOXDateFormatter.rfcDateStringFromDate(departureDate)
        exportDictionary[TrackedVisit.Attributes.horizontalAccuracy] = horizontalAccuracy
        exportDictionary[TrackedVisit.Attributes.latitude] = latitude
        exportDictionary[TrackedVisit.Attributes.longitude] = longitude
        exportDictionary[TrackedVisit.Attributes.pointOfInterest] = pointOfInterest
        exportDictionary[TrackedVisit.Attributes.placemark] = placemark
        exportDictionary[TrackedVisit.Attributes.trackingType] = trackingType
        exportDictionary[TrackedVisit.Attributes.uuid] = uuid.uuidString
        
        return exportDictionary
    }
    
    
    private func datesDescriptionMethod()
    -> String {
        var datesDescriptionElements: [String] = []
        
        if let arrivalDate {
            datesDescriptionElements.append(SOXDateFormatter.dayMonthYearHourMinutesStringFor(date: arrivalDate))
        }
        
        datesDescriptionElements.append(" - ")
        
        if let departureDate {
            datesDescriptionElements.append(SOXDateFormatter.dayMonthYearHourMinutesStringFor(date: departureDate))
        }
        
        let datesDescription = datesDescriptionElements.joined(separator: "")
        return datesDescription
    }
    
}

extension TrackedVisit {
    
    enum TrackingType: Int16 {
        case unknown = 0
        case manually
        case visit
        case significantChange
        case permanent
        
        
        static func color(forTrackingType type: TrackingType)
        -> UIColor {
            switch type {
                case .unknown:
                    return .darkGray
                case .manually:
                    return .systemGreen
                case .visit:
                    return .systemRed
                case .significantChange:
                    return .systemOrange
                case .permanent:
                    return .systemPurple
            }
        }
    }
    
}


//MARK: - Attributes and Relations
extension TrackedVisit {
    
    struct Attributes {
        static let arrivalDate = "arrivalDate"
        static let creationDate = "creationDate"
        static let departureDate = "departureDate"
        static let horizontalAccuracy = "horizontalAccuracy"
        static let latitude = "latitude"
        static let longitude = "longitude"
        static let pointOfInterest = "pointOfInterest"
        static let placemark = "placemark"
        static let trackingType = "trackingType"
        static let uuid = "uuid"
    }
    
    struct Relationships {
    }
    
}
