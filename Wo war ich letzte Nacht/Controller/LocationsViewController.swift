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

    //MARK: IBOutlets
    @IBOutlet var mapView: MKMapView!
    
    
    //MARK: - Init&Co.
    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
    }
    
    //MARK: - Setup Methods
    private func setupUI() {
        
    }
    
    
}
