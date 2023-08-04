//
//  SimpleAnnotation.swift
//  Wo war ich letzte Nacht
//
//  Created by Peter Hauke on 19.07.23.
//

import MapKit
import SwiftUI

class SimpleAnnotation: NSObject, MKAnnotation, Identifiable {
    
    // This property must be key-value observable, which the `@objc dynamic` attributes provide.
    @objc dynamic var coordinate = CLLocationCoordinate2D(latitude: 37.779_379, longitude: -122.418_433)
    
    // Required if you set the annotation view's `canShowCallout` property to `true`
    var title: String? = NSLocalizedString("SAN_FRANCISCO_TITLE", comment: "SF annotation")
    
    // This property defined by `MKAnnotation` is not required.
    var subtitle: String? = NSLocalizedString("SAN_FRANCISCO_SUBTITLE", comment: "SF annotation")
    
    var markerTintColor: UIColor
    
    var id: UUID
    
    init(latitude: Double, longitude: Double,
         title: String? = nil, subtitle: String? = nil,
         markerTintColor: UIColor,
         id: UUID) {
        self.coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        self.title = title
        self.subtitle = subtitle
        self.markerTintColor = markerTintColor
        self.id = id
    }
    
}
