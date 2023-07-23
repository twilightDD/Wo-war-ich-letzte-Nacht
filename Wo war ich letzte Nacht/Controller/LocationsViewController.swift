//
//  LocationsViewController.swift
//  Wo war ich letzte Nacht
//
//  Created by Peter Hauke on 16.07.23.
//

import UIKit
import MapKit

//MARK: - LocationsViewController
class LocationsViewController: UIViewController {
    
    //MARK: Lets & Vars
    private var datasourceManager: SOXWatchDogFRC?
    
    private var allAnnotations: [MKAnnotation]?
    private var displayedAnnotations: [MKAnnotation]? {
        willSet {
            if let currentAnnotations = displayedAnnotations {
                mapView.removeAnnotations(currentAnnotations)
            }
        }
        didSet {
            if let newAnnotations = displayedAnnotations {
                mapView.addAnnotations(newAnnotations)
            }
            //centerMapOnSanFrancisco()
        }
    }
    
    
    
    
    //MARK: IBOutlets
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var addCurrentLocationButton: UIButton!
    @IBOutlet var mapView: MKMapView!
    
    
    //MARK: - Init&Co.
    override func viewDidLoad() {
        super.viewDidLoad()
        
      //  SOXLocationManager.registerForLocationTracking(target: self)
       // SOXLocationManager.requestLocation(target: self)
        registerMapAnnotationViews()
        setupUI()
        setupDatasourceManager()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        updateMap()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
    }
    
    //MARK: - Setup Methods
    private func setupUI() {
        mapView.userTrackingMode = .follow
    }
    
    private func registerMapAnnotationViews() {
        mapView.register(MKMarkerAnnotationView.self,
                         forAnnotationViewWithReuseIdentifier: NSStringFromClass(SimpleAnnotation.self))
    }
    
    private func setupDatasourceManager() {
        datasourceManager = SOXWatchDogFRC.manager(withEntityForName: TrackedVisit.entityName(),
                                                   delegate: self,
                                                   name: "watchdog for TrackedVisit")
    }
    
    //MARK: - Action Methods
    @IBAction func addCurrentLocationButtonAction(_ sender: UIButton) {
        var newTrackedVisit: TrackedVisit?
        
        let currentCoordinates = mapView.userLocation.coordinate
        SOXCoreDatabase.performAndSaveInUIEditContext(
            workingBlock:  { context in
                newTrackedVisit = TrackedVisit.insert(inContext: context,
                                                      trackingType: .manually,
                                                      arrivalDate: Date(),
                                                      departureDate: nil,
                                                      horizontalAccuracy: 0,
                                                      latitude: currentCoordinates.latitude,
                                                      longitude: currentCoordinates.longitude)
            }, completionBlock:  { [weak self] in
                
                if let newTrackedVisit,
                   let arrivalDate = newTrackedVisit.arrivalDate {
                    // Local Notification
                    let content = UNMutableNotificationContent()
                    content.title = "Manual Visit added 📌"
                    content.body = "Arrival: \(SOXDateFormatter.dayMonthYearStringFor(date: arrivalDate))"
                    content.sound = UNNotificationSound.default
                    let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: false)
                    let request = UNNotificationRequest(identifier: arrivalDate.description,
                                                        content: content, trigger: trigger)
                    
                    UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
                }
                else {
                    let title = "An error occured."
                    let message  = "Could not create a Visit."
                    let alertView = UIAlertController(title: title,
                                                      message: message,
                                                      preferredStyle: .alert)
                    alertView.addAction(UIAlertAction(title: "Okay",
                                                      style: .default))
                    
                    self?.present(alertView, animated: true)
                }
            })
    }
    
}


//MARK: - Extension - Map Methods
extension LocationsViewController {
    
    private func updateMap() {
        print("updateMap")
        guard let allTrackedVisits = datasourceManager?.fetchedObjects() as? [TrackedVisit] else {
            fatalError() }
        
        var newAnnotations: [SimpleAnnotation] = []
        allTrackedVisits.forEach( { visit in
            let annotaion = SimpleAnnotation(latitude: visit.latitude, longitude: visit.longitude,
                                             title: visit.pointOfInterest,
                                             subtitle: visit.datesDescription)
            newAnnotations.append(annotaion)
        })
        
        displayedAnnotations = newAnnotations
    }
    
    
    private func centerMapOn(location: CLLocation) {
        let center = CLLocationCoordinate2D(latitude: location.coordinate.latitude,
                                            longitude: location.coordinate.longitude)
        //let span = MKCoordinateSpan(latitudeDelta: 0.15, longitudeDelta: 0.15)
        let coordinateRegion =  MKCoordinateRegion(center: center,
                                                   latitudinalMeters: 1500, longitudinalMeters: 1500)
        mapView.setRegion(coordinateRegion, animated: true)
    }
    
}


extension LocationsViewController: SOXDatasourceManagerDelegate {
    
    func controllerDidChangeContent(_ datasourceManager: SOXAbstractDatasourceFRC) {
        
        if datasourceManager == self.datasourceManager {
            updateMap()
        }
        
    }
    
}

extension LocationsViewController: SOXLocationManagerDelegate {
    
    func didUpdateLocation(_ location: CLLocation?) {
        if let location {
            centerMapOn(location: location)
            //SOXLocationManager.unRegisterForLocationTracking(target: self)
        }
    }
    
}
