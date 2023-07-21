//
//  SOXLocationManager.swift
//  Landrix Handwerk Mobile
//
//  Created by Peter Hauke on 05.08.19.
//  Copyright © 2019 Landrix Software GmbH & Co. KG. All rights reserved.
//

import Foundation
import UIKit
import CoreLocation

//MARK: - LocationManager
class SOXLocationManager: NSObject {
    //MARK: Lets and Vars
    private (set) var latestLocation: CLLocation?
    
    //MARK: Private Lets and Vars
    private static let shared = SOXLocationManager()
    private var trackingDelegates = NSHashTable<NSObject>()
    private var visitsDelegates = NSHashTable<NSObject>()
    private var requestDelegates = NSHashTable<NSObject>()
    private lazy var locationManager = setupLocationManager()
    
    private var countOfLocationUpdates:Int = 0
    
    //MARK: - Init&Co
    
    
    //MARK: - Setup Methods
    private func setupLocationManager()
    -> CLLocationManager {
        let locationManager = CLLocationManager()
        locationManager.delegate = self
        
        locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        locationManager.allowsBackgroundLocationUpdates = true
        locationManager.showsBackgroundLocationIndicator = true
        locationManager.activityType = .other
        
        return locationManager
    }
    
    
    //MARK: - Public Class Methods
    class func updateLocation() {
        SOXLocationManager.shared.locationManager.startUpdatingLocation()
        print("LocationManager.startUpdatingLocation")
    }
    
    
    
    
    @discardableResult
    class func stopUpdatingLocation(force: Bool)
    -> Bool {
        var stopUpdatingLocation = true
        
        if force == true {
            SOXLocationManager.shared.locationManager.stopUpdatingLocation()
        }
        else if SOXLocationManager.shared.trackingDelegates.count == 0 {
            SOXLocationManager.shared.locationManager.stopUpdatingLocation()
        }
        else {
            stopUpdatingLocation = false
        }
        
        return stopUpdatingLocation
    }
    
    
    class func startMonitoringVisits() {
        shared.locationManager.startMonitoringVisits()
        print("LocationManager.startMonitoringVisits")
    }
    
    
    class func stopMonitoringVisits() {
        shared.locationManager.stopMonitoringVisits()
        print("LocationManager.stopMonitoringVisits")
    }
    
    
    class func latestLocation()
    -> CLLocation? {
        let latestLocation = SOXLocationManager.shared.latestLocation
        return latestLocation
    }
    
    class func registerForLocationTracking<T: SOXLocationManagerDelegate>(target delegate:T) {
        SOXLocationManager.shared.registerForLocationTracking(target: delegate)
    }
    
    class func unRegisterForLocationTracking<T: SOXLocationManagerDelegate>(target delegate:T) {
        SOXLocationManager.shared.unRegisterForLocationTracking(target: delegate)
    }
    
    class func registerForVisitTracking<T: SOXLocationManagerDelegate>(target delegate:T) {
        SOXLocationManager.shared.registerForVisitTracking(target: delegate)
    }
    
    class func unRegisterForVisitTracking<T: SOXLocationManagerDelegate>(target delegate:T) {
        SOXLocationManager.shared.unRegisterForVisitTracking(target: delegate)
    }
    
    class func requestLocation<T: SOXLocationManagerDelegate>(target delegate:T) {
        SOXLocationManager.shared.requestLocation(target: delegate)
    }
    
    
    //MARK: - Private Instance Methods
    private func registerForLocationTracking<T: SOXLocationManagerDelegate>(target delegate:T) {
        //func startLocationTracking(target delegate:SOXLocationManagerDelegate) {
        guard let delegate = delegate as? NSObject
        else { fatalError("Must be an NSObject") }
        
        trackingDelegates.add(delegate)
        
        locationManager.startUpdatingLocation()
        print("LocationManager.registerForLocationTracking: startUpdatingLocation")
    }
    
    private func unRegisterForLocationTracking<T: SOXLocationManagerDelegate>(target delegate:T) {
        guard let delegate = delegate as? NSObject
        else { fatalError("Must be an NSObject") }
        trackingDelegates.remove(delegate)
        
        if trackingDelegates.count < 1 {
            locationManager.stopUpdatingLocation()
            print("LocationManager.unRegisterForLocationTracking: stopUpdatingLocation")
        }
    }
    
    private func registerForVisitTracking<T: SOXLocationManagerDelegate>(target delegate:T) {
        
        guard let delegate = delegate as? NSObject else {
            fatalError("Must be an NSObject") }
        
        visitsDelegates.add(delegate)
        
        locationManager.startMonitoringVisits()
    }
    
    private func unRegisterForVisitTracking<T: SOXLocationManagerDelegate>(target delegate:T) {
        guard let delegate = delegate as? NSObject else {
            fatalError("Must be an NSObject") }
        
        visitsDelegates.remove(delegate)
        
        if visitsDelegates.count < 1 {
            locationManager.stopMonitoringVisits()
        }
    }
    
    private func requestLocation<T: SOXLocationManagerDelegate>(target delegate:T) {
        guard let delegate = delegate as? NSObject
        else { fatalError("Must be an NSObject") }
        requestDelegates.add(delegate)
        
        locationManager.requestLocation()
    }
    
}


extension SOXLocationManager:CLLocationManagerDelegate {
    internal func locationManager(_ manager: CLLocationManager,
                                  didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
            case .authorizedAlways:
                // fine!
                break
            case .authorizedWhenInUse:
                // fine!
                break
            case .denied:
                // Show alert instructing them how to turn on permissions
                break
            case .notDetermined:
                locationManager.requestAlwaysAuthorization()
            case .restricted:
                // user may not change it (i.e. parental limitations)
                break
            default:
                break
        }
    }
    
    
    internal func locationManager(_ manager: CLLocationManager,
                                  didUpdateLocations locations: [CLLocation]) {
        guard let currentLocation = locations.first
        else { return }
        print("LocationManager.didUpdateLocations: \(currentLocation)")
        // Memorize latest location
        latestLocation = currentLocation
        countOfLocationUpdates = countOfLocationUpdates + 1
        
        // Tracking
        for trackingDelegate in trackingDelegates.allObjects {
            guard let trackingDelegate = trackingDelegate as? SOXLocationManagerDelegate
            else { fatalError() }
            
            trackingDelegate.didUpdateLocation(currentLocation)
        }
        
        // Request
        for requestDelegate in requestDelegates.allObjects {
            guard let requestDelegate = requestDelegate as? SOXLocationManagerDelegate
            else { fatalError() }
            
            requestDelegate.didUpdateLocation(currentLocation)
        }
        
        requestDelegates.removeAllObjects() // requestLocation is asked only once
        
        // Disable location tracking, if meaningful
        if trackingDelegates.count == 0
            && visitsDelegates.count == 0
            && countOfLocationUpdates > 4 {
            locationManager.stopUpdatingLocation()
            print("LocationManager: stopUpdatingLocation (trackingDelegates.count: \(trackingDelegates.count), countOfLocationUpdates: \(countOfLocationUpdates)")
            countOfLocationUpdates = 0
        }
    }
    
    internal func locationManager(_ manager: CLLocationManager, didVisit visit: CLVisit) {
        print("didVisit: \(visit.arrivalDate)")
        
        visitsDelegates.allObjects.forEach( { visitsDelegate in
            guard let visitsDelegate = visitsDelegate as? SOXLocationManagerDelegate else {
                fatalError() }
            
            visitsDelegate.locationManager(manager, didVisit: visit)
        })
        
        // Local Notification
        let content = UNMutableNotificationContent()
        content.title = "New Visit 📌"
        content.body = "Arrival: \(visit.arrivalDate)"
        content.sound = UNNotificationSound.default
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        let request = UNNotificationRequest(identifier: visit.arrivalDate.description,
                                            content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
    }
    
    internal func locationManager(_ manager: CLLocationManager,
                                  didFailWithError error: Error) {
        print("locationManager didFailWithError: \(error.localizedDescription)")
    }
    
}
