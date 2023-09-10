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
    
    fileprivate enum TimeFilter: Int {
        case oneDay = 0
        case twoDays = 1
        case all = 2
        
        static func predicate(forTimeFilter timeFilter: TimeFilter)
        -> NSPredicate? {
            var predicate: NSPredicate?
            
            switch timeFilter {
                case .oneDay:
                    let nowMinus24Hours = Date().addingTimeInterval(-24*60*60)
                    predicate = NSPredicate(format: "%K > %@",
                                                  argumentArray: [TrackedVisit.Attributes.arrivalDate, nowMinus24Hours])
                case .twoDays:
                    let nowMinus48Hours = Date().addingTimeInterval(-48*60*60)
                    predicate = NSPredicate(format: "%K > %@",
                                                  argumentArray: [TrackedVisit.Attributes.arrivalDate, nowMinus48Hours])
                case .all:
                    predicate = nil
            }
            
            return predicate
        }
    }
    
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
    @IBOutlet var helpButton: UIButton!
    @IBOutlet var timeFilterSegmentControl: UISegmentedControl!
    @IBOutlet var mapView: MKMapView!
    
    
    //MARK: - Init&Co.
    override func viewDidLoad() {
        super.viewDidLoad()
        
      //  SOXLocationManager.registerForLocationTracking(target: self)
        SOXLocationManager.requestLocation(target: self)
        
        mapView.delegate = self
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
        mapView.showsUserLocation = true
        mapView.showsCompass = true
        mapView.showsScale = true
        let config = MKStandardMapConfiguration()
        config.pointOfInterestFilter = MKPointOfInterestFilter(including: [
            .atm, .bank, .beach, .brewery, .cafe, .foodMarket, .gasStation, .hospital, .hotel,
            .movieTheater, .museum, .nightlife, .parking, .police, .publicTransport, .restaurant,
            .restroom, .winery])
        mapView.preferredConfiguration = config
    }
    
    private func registerMapAnnotationViews() {
        mapView.register(MKMarkerAnnotationView.self,
                         forAnnotationViewWithReuseIdentifier: NSStringFromClass(SimpleAnnotation.self))
    }
    
    private func setupDatasourceManager() {
        let predicate = TimeFilter.predicate(forTimeFilter: .oneDay)
        datasourceManager = SOXWatchDogFRC.manager(withEntityForName: TrackedVisit.entityName(),
                                                   predicate: predicate,
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
                    
                    CoreDataLocationManager.updateGeocode(forVisitWithUUID: newTrackedVisit.uuid)
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
    

    @IBAction func timeFilterSegmentControlAction(_ sender: UISegmentedControl) {
        guard let timeFilter = TimeFilter(rawValue: sender.selectedSegmentIndex) else {
            fatalError() }
        
        let filterPredicate = TimeFilter.predicate(forTimeFilter: timeFilter)
        datasourceManager?.updatePredicate(filterPredicate)
        updateMap()
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
                                             title: visit.placemark,
                                             subtitle: visit.datesDescription,
                                             markerTintColor: visit.trackingColor,
                                             id: visit.uuid)
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


//MARK: - Extension - MKMapViewDelegate
extension LocationsViewController: MKMapViewDelegate {
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation)
    -> MKAnnotationView? {
        
        // UserLocation will be shown as default blue bubble
        if let _ = annotation as? MKUserLocation {
            return nil
        }
        
        let annotationView = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: "something")
        if let simpleAnnotation = annotation as? SimpleAnnotation {
            annotationView.markerTintColor = simpleAnnotation.markerTintColor
        }
        annotationView.displayPriority = .required
        return annotationView
    }
    
}


//MARK: - Extension - SOXDatasourceManagerDelegate
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
