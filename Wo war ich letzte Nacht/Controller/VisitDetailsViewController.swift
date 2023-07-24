//
//  VisitDetailsViewController.swift
//  Wo war ich letzte Nacht
//
//  Created by Peter Hauke on 24.07.23.
//

import UIKit

import MapKit

//MARK: - VisitDetailsViewController
class VisitDetailsViewController: UIViewController {

    //MARK: - Lets and Vars
    var visit: TrackedVisit?
    
    
    //MARK: - IBOutlets
    @IBOutlet var pointOfInterestDescriptionLabel: UILabel!
    @IBOutlet var pointOfInterestLabel: UILabel!
    @IBOutlet var placemarkDescriptionLabel: UILabel!
    @IBOutlet var placemarkLabel: UILabel!
    @IBOutlet var arrivalDateDescriptionLabel: UILabel!
    @IBOutlet var arrivalDateLabel: UILabel!
    @IBOutlet var departureDateDescriptionLabel: UILabel!
    @IBOutlet var departureDateLabel: UILabel!
    @IBOutlet var longitudeDescriptionLabel: UILabel!
    @IBOutlet var longitudeLabel: UILabel!
    @IBOutlet var latitudeDescriptionLabel: UILabel!
    @IBOutlet var latitudeLabel: UILabel!
    @IBOutlet var creationDateDescriptionLabel: UILabel!
    @IBOutlet var creationDateLabel: UILabel!
    @IBOutlet var trackingTypeDescriptionLabel: UILabel!
    @IBOutlet var trackingTypeLabel: UILabel!
    
    
    @IBOutlet var mapView: MKMapView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        updateLabels()
        updateMap()
    }
    
    
    private func updateLabels() {
        if let visit {
            pointOfInterestLabel.text = visit.pointOfInterest ?? "-"
            placemarkLabel.text = visit.placemark ?? "-"
            if let arrivalDate = visit.arrivalDate {
                arrivalDateLabel.text = SOXDateFormatter.dayMonthYearHourMinutesStringFor(date: arrivalDate)
            }
            else {
                arrivalDateLabel.text = "???"
            }
            if let departureDate = visit.departureDate {
                departureDateLabel.text = SOXDateFormatter.dayMonthYearHourMinutesStringFor(date: departureDate)
            }
            else {
                departureDateLabel.text = "???"
            }
           
            longitudeLabel.text = "\(visit.longitude)"
            latitudeLabel.text = "\(visit.latitude)"
            creationDateLabel.text = SOXDateFormatter.dayMonthYearHourMinutesStringFor(date: visit.creationDate)
            trackingTypeLabel.text = TrackedVisit.TrackingType.title(forTrackingType: visit.trackingType)
        }
        
    }
    
    private func updateMap() {
        if let visit {
            let annotaion = SimpleAnnotation(latitude: visit.latitude, longitude: visit.longitude,
                                             title: visit.placemark,
                                             subtitle: visit.datesDescription,
                                             markerTintColor: visit.trackingColor)
            mapView.addAnnotation(annotaion)
            
            let center = CLLocationCoordinate2D(latitude: visit.latitude,
                                                longitude: visit.longitude)
            //let span = MKCoordinateSpan(latitudeDelta: 0.15, longitudeDelta: 0.15)
            let coordinateRegion =  MKCoordinateRegion(center: center,
                                                       latitudinalMeters: 1500, longitudinalMeters: 1500)
            mapView.setRegion(coordinateRegion, animated: true)
        }
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
