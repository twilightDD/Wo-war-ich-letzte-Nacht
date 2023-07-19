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
    
}

//MARK: - Extension - Private Methods
private extension CoreDataLocationManager {
    
    private func addNewLocation(_ location: CLLocation) {
        
        SOXCoreDatabase.performAndSaveInUIEditContext(
            workingBlock:  { context in
                let newLocation = Location(context: context)
                newLocation.latitude = location.coordinate.latitude
                newLocation.longitude = location.coordinate.longitude
                newLocation.timeStamp = Date()
            },
            completionBlock: {
                print("did add a new CoreData.Location")
            })
    }
    
}


//MARK: - Extension - SOXLocationManagerDelegate
extension CoreDataLocationManager: SOXLocationManagerDelegate {
    
    func didUpdateLocation(_ location: CLLocation?) {
        if let location {
            addNewLocation(location)
        }
    }
    
}
