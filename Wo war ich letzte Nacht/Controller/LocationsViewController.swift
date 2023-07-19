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
    @IBOutlet var mapView: MKMapView!
    
    
    //MARK: - Init&Co.
    override func viewDidLoad() {
        super.viewDidLoad()
        
        SOXLocationManager.registerForLocationTracking(target: self)
        
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
        
    }
    
    private func registerMapAnnotationViews() {
        mapView.register(MKMarkerAnnotationView.self,
                         forAnnotationViewWithReuseIdentifier: NSStringFromClass(SimpleAnnotation.self))
    }
    
    private func setupDatasourceManager() {
        datasourceManager = SOXWatchDogFRC.manager(withEntityForName: "Location",
                                                   delegate: self,
                                                   name: "watchdog for locations")
        
    }
    
    //MARK: - Map Methods
    private func updateMap() {
        guard let allLocations = datasourceManager?.fetchedObjects() as? [Location] else {
            fatalError() }
        
        var newAnnotations: [SimpleAnnotation] = []
        allLocations.forEach( { location in
            let annotaion = SimpleAnnotation(latitude: location.latitude, longitude: location.longitude,
                                           title: "title", subtitle: "subtitle")
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
            
        }
        
    }
    
}

extension LocationsViewController: SOXLocationManagerDelegate {
    
    func didUpdateLocation(_ location: CLLocation?) {
        if let location {
            centerMapOn(location: location)
            SOXLocationManager.unRegisterForLocationTracking(target: self)
        }
    }
    
}
