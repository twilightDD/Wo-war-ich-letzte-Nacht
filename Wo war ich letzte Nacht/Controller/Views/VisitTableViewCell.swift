//
//  VisitTableViewCell.swift
//  Wo war ich letzte Nacht
//
//  Created by Peter Hauke on 20.07.23.
//

import UIKit

//MARK: - VisitTableViewCell
class VisitTableViewCell: SOXTableViewCell {

    //MARK: IBOutlets
    @IBOutlet var visitedLocationLabel: UILabel!
    @IBOutlet var arrivalDateLabel: UILabel!
    @IBOutlet var departureDateLabel: UILabel!
    @IBOutlet var trackingTypeView: UIView!
    
    
    //MARK: - Life cycle
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    
    func configure(forVisit visit: TrackedVisit) {
        
        // Location
        if let placemark = visit.placemark {
            visitedLocationLabel.text = placemark
        }
        else {
            let coordinateString = "\(visit.latitude), \(visit.longitude)"
            visitedLocationLabel.text = coordinateString
        }
        
        
        // Dates
        arrivalDateLabel.text = visit.arrivalDate != nil ?
                SOXDateFormatter.dayMonthYearHourMinutesStringFor(date: visit.arrivalDate!)
                : "???"
        departureDateLabel.text = visit.departureDate != nil ?
                SOXDateFormatter.dayMonthYearHourMinutesStringFor(date: visit.departureDate!)
                : "???"
        
        // View
        trackingTypeView.subviews.forEach( { $0.removeFromSuperview() } )
        let trackingType = TrackedVisit.TrackingType(rawValue: visit.trackingType)!
        let annotationView = TrackedVisit.TrackingType.annotationView(forTrackingType: trackingType)
        trackingTypeView.addSubview(annotationView)
        annotationView.frame = CGRect(origin: CGPoint(x: 0, y: 0),
                                      size: annotationView.frame.size)
        
    }
    
}
