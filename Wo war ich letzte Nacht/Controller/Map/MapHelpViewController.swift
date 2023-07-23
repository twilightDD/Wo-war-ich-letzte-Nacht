//
//  MapHelpViewController.swift
//  Wo war ich letzte Nacht
//
//  Created by Peter Hauke on 23.07.23.
//

import UIKit

import MapKit

//MARK: - MapHelpViewController
class MapHelpViewController: UIViewController {

    //MARK: - IBOutlets
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var annotationHelpStackView: UIStackView!
    
    
    //MARK: - Init&Co.
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        setupAnnotationHelpStackView()
    }
    
    
    //MARK: - Setup Methods
    private func setupAnnotationHelpStackView() {
        annotationHelpStackView.spacing = 30
        annotationHelpStackView.alignment = .fill
        annotationHelpStackView.distribution = .fillEqually
        TrackedVisit.TrackingType.allCases.forEach( { trackingType in
            // Row stack
            let rowStack = UIStackView()
            rowStack.axis = .horizontal
            rowStack.spacing = 10
            rowStack.alignment = .fill
            rowStack.distribution = .fillEqually
            
            // Annotation
            let markerTintColor = TrackedVisit.TrackingType.color(forTrackingType: trackingType)
            let annotation = SimpleAnnotation(latitude: 0, longitude: 0, markerTintColor: markerTintColor)
            let annotationView = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: "something")
            annotationView.markerTintColor = markerTintColor
            rowStack.addArrangedSubview(annotationView)
            
            // Label
            let descriptionLabel = UILabel()
            descriptionLabel.text = TrackedVisit.TrackingType.title(forTrackingType: trackingType)
            rowStack.addArrangedSubview(descriptionLabel)
            
            annotationHelpStackView.addArrangedSubview(rowStack)
        })
        
    }
    
    
}
