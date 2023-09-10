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
    
    static func updateGeocode(forVisitWithUUID uuid: UUID) {
        shared.updateGeocode(forVisitWithUUID: uuid)
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
            
            var newTrackedVisit: TrackedVisit?
            
            SOXCoreDatabase.performAndSaveInUIEditContext(
                workingBlock:  { context in
                    
                    var trackingType: TrackedVisit.TrackingType = .unknown
                    if SOXUserDefaultsManager.bool(forKey: UserDefaultKey.permanentTracking) {
                        trackingType = .permanent
                    }
                    else {
                        trackingType = .significantChange
                    }
                    
                    newTrackedVisit = TrackedVisit.insert(inContext: context,
                                                          trackingType: trackingType,
                                                          arrivalDate:  location.timestamp,
                                                          departureDate: nil,
                                                          horizontalAccuracy: location.horizontalAccuracy,
                                                          latitude: location.coordinate.latitude,
                                                          longitude: location.coordinate.longitude)
                },
                completionBlock: { [weak self] in
                    print("did add a new CoreData.Location")
                    let allLocations = SOXCoreDatabase.viewOnlyContext().fetchObjects(forEntityClass: TrackedVisit.self)
                    print("now: \(allLocations.count)")
                    
                    // Automatically geolocate, if enabled
                    if let newTrackedVisit,
                       SOXUserDefaultsManager.bool(forKey: UserDefaultKey.autoGeolocate) {
                        self?.updateGeocode(forVisitWithUUID: newTrackedVisit.uuid)
                    }
                })
        }
    }
    
    
    /// visit
    func locationManager(_ manager: CLLocationManager, didVisit visit: CLVisit) {
        print("CoreDataLocationManager - didVisit")
        var newTrackedVisit: TrackedVisit?
        SOXCoreDatabase.performAndSaveInUIEditContext(
            workingBlock:  { context in
                newTrackedVisit = TrackedVisit.insert(inContext: context,
                                                      trackingType: .visit,
                                                      arrivalDate: visit.arrivalDate,
                                                      departureDate: visit.departureDate,
                                                      horizontalAccuracy: visit.horizontalAccuracy,
                                                      latitude: visit.coordinate.latitude,
                                                      longitude: visit.coordinate.longitude)
                
            },
            completionBlock: { [weak self] in
                
                // Automatically geolocate, if enabled
                if let newTrackedVisit,
                   SOXUserDefaultsManager.bool(forKey: UserDefaultKey.autoGeolocate) {
                    self?.updateGeocode(forVisitWithUUID: newTrackedVisit.uuid)
                }
                   
            })
    }
    
}


extension CoreDataLocationManager {
    
    private func updateGeocode(forVisitWithUUID uuid: UUID) {
        let editContext = SOXCoreDatabase.newEditContext(forUI: true)
        guard let visit = TrackedVisit.fetch(withUUID: uuid, inContext: editContext) else {
            return }
        
        let clLocation = CLLocation(latitude: visit.latitude, longitude: visit.longitude)
        
        let geoCoder = CLGeocoder()
        Task {
            do {
                let placemarks = try await geoCoder.reverseGeocodeLocation(clLocation)
                if let placemark = placemarks.first {
                    visit.updateAndSaveWith(placemark: placemark,
                                            inContext: editContext,
                                            completionBlock: nil)
                    print("Placemarks found for \(visit.uuid.uuidString)")
                    
                }
                else {
                    print("Placemarks not found for \(visit.uuid.uuidString)")
                }
            }
            catch let geoCoderError {
                print(geoCoderError.localizedDescription)
            }
        }
    }
        
    
}
