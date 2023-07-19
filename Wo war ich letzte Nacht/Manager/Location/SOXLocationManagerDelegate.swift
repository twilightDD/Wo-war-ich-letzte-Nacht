//
//  SOXLocationManagerDelegate.swift
//  Landrix Handwerk Mobile
//
//  Created by Peter Hauke on 05.08.19.
//  Copyright © 2019 Landrix Software GmbH & Co. KG. All rights reserved.
//

import Foundation
import UIKit
import CoreLocation

// MARK: - Protocol
protocol SOXLocationManagerDelegate: Any {
    func didUpdateLocation(_ location:CLLocation?)
    func locationManager(_ manager: CLLocationManager, didVisit visit: CLVisit)

}


// MARK: - Protocol stubs
extension SOXLocationManagerDelegate {

    func didUpdateLocation(_ location:CLLocation?) {
        fatalError("Needs to be implemented in concrete subclass.")
    }
    
    func locationManager(_ manager: CLLocationManager, didVisit visit: CLVisit)  {
        fatalError("Needs to be implemented in concrete subclass.")
    }

}


//protocol Identifiable {
//    associatedtype UIViewController
//    var id: UIViewController { get set }
//}
