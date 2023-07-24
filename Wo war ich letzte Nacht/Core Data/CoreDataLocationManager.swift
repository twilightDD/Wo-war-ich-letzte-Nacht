//
//  CoreDataLocationManager.swift
//  Wo war ich letzte Nacht
//
//  Created by Peter Hauke on 19.07.23.
//

import Foundation
import CoreLocation

//MARK: - CoreDataLocationManager
class CoreDataLocationManager: NSObject {
    
    //MARK: - Singleton
    private static let shared = CoreDataLocationManager()
    
    //MARK: - Public Methods
    static func start() {
        if SOXUserDefaultsManager.bool(forKey: UserDefaultKey.permanentTracking) {
            SOXLocationManager.registerForLocationTracking(target: shared)
        }
        else {
            if SOXUserDefaultsManager.bool(forKey: UserDefaultKey.monitorVisits) {
                SOXLocationManager.registerForVisitTracking(target: shared)
            }
            if SOXUserDefaultsManager.bool(forKey: UserDefaultKey.monitorSignificantChanges) {
                SOXLocationManager.registerForSignificantLocationChanges(target: shared)
            }
        }
    }
    
    
    
    static func stop() {
        SOXLocationManager.unRegisterForLocationTracking(target: shared)
    }
    
    static func startPermanentTracking() {
        SOXLocationManager.registerForLocationTracking(target: shared)
    }
    
    static func stopPermanentTracking() {
        SOXLocationManager.unRegisterForLocationTracking(target: shared)
    }
    
    
    static func startMonitoringVisits() {
        SOXLocationManager.registerForVisitTracking(target: shared)
    }
    
    static func stopMonitoringVisits() {
        SOXLocationManager.unRegisterForVisitTracking(target: shared)
    }
    
    static func startMonitoringSignificantChanges() {
        SOXLocationManager.registerForSignificantLocationChanges(target: shared)
    }
    
    static func stopMonitoringSignificantChanges() {
        SOXLocationManager.unRegisterForSignificantLocationChanges(target: shared)
    }
    
}


//MARK: - Extension - SOXLocationManagerDelegate
extension CoreDataLocationManager: SOXLocationManagerDelegate {
    
    static func didUpdateLocation(_ location: CLLocation?) {
        shared.didUpdateLocation(location)
    }
    
    /// permanentTracking and significant change
    func didUpdateLocation(_ location: CLLocation?) {
        if let location {
            SOXCoreDatabase.performAndSaveInUIEditContext(
                workingBlock:  { context in
                    
                    var trackingType: TrackedVisit.TrackingType = .unknown
                    if SOXUserDefaultsManager.bool(forKey: UserDefaultKey.permanentTracking) {
                        trackingType = .permanent
                    }
                    else {
                        trackingType = .significantChange
                    }
                    
                    let _ = TrackedVisit.insert(inContext: context,
                                                trackingType: trackingType,
                                                arrivalDate:  location.timestamp,
                                                departureDate: nil,
                                                horizontalAccuracy: location.horizontalAccuracy,
                                                latitude: location.coordinate.latitude,
                                                longitude: location.coordinate.longitude)
                },
                completionBlock: {
                    print("did add a new CoreData.Location")
                    let allLocations = SOXCoreDatabase.viewOnlyContext().fetchObjects(forEntityClass: TrackedVisit.self)
                    print("now: \(allLocations.count)")
                })
        }
    }
    
    
    /// visit
    func locationManager(_ manager: CLLocationManager, didVisit visit: CLVisit) {
        print("CoreDataLocationManager - didVisit")
        SOXCoreDatabase.performAndSaveInUIEditContext(
            workingBlock:  { context in
                let _ = TrackedVisit.insert(inContext: context,
                                            trackingType: .visit,
                                            arrivalDate: visit.arrivalDate,
                                            departureDate: visit.departureDate,
                                            horizontalAccuracy: visit.horizontalAccuracy,
                                            latitude: visit.coordinate.latitude,
                                            longitude: visit.coordinate.longitude)
                
            },
            completionBlock: {
                let allTrackedVisits = SOXCoreDatabase.viewOnlyContext().fetchObjects(forEntityClass: TrackedVisit.self)
                print("did add a new CoreData.TrackedVisit. now: \(allTrackedVisits.count)")
            })
    }
    
}
