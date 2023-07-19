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
        SOXLocationManager.registerForLocationTracking(target: shared)
    }
    
    static func stop() {
        SOXLocationManager.unRegisterForLocationTracking(target: shared)
    }
    
    static func startMonitoringVisits() {
        SOXLocationManager.registerForVisitTracking(target: shared)
    }
    
    static func stopMonitoringVisits() {
        SOXLocationManager.unRegisterForVisitTracking(target: shared)
    }
    
}

//MARK: - Extension - Private Methods
private extension CoreDataLocationManager {
    
    private func addNewLocation(_ location: CLLocation) {
        
     
    }
    
}


//MARK: - Extension - SOXLocationManagerDelegate
extension CoreDataLocationManager: SOXLocationManagerDelegate {
    
    static func didUpdateLocation(_ location: CLLocation?) {
        shared.didUpdateLocation(location)
    }
    
    func didUpdateLocation(_ location: CLLocation?) {
        if let location {
            SOXCoreDatabase.performAndSaveInUIEditContext(
                workingBlock:  { context in
                    let _ = TrackedLocation.insert(in: context,
                                                   latitude: location.coordinate.latitude,
                                                   longitude: location.coordinate.longitude)
                },
                completionBlock: {
                    print("did add a new CoreData.Location")
                    let allLocations = SOXCoreDatabase.viewOnlyContext().fetchObjects(forEntityClass: TrackedLocation.self)
                    print("now: \(allLocations.count)")
                })
        }
    }
    
    static func locationManager(_ manager: CLLocationManager, didVisit visit: CLVisit) {
        shared.locationManager(manager, didVisit: visit)
    }
    
    func locationManager(_ manager: CLLocationManager, didVisit visit: CLVisit) {
        
    }
    
}
