//
//  VisitsTableViewController.swift
//  Wo war ich letzte Nacht
//
//  Created by Peter Hauke on 20.07.23.
//

import UIKit
import CoreLocation

//MARK: - VisitsTableViewController
class VisitsTableViewController: UITableViewController {
    
    //MARK: - Lets and Vars
    private var visits: [TrackedVisit] = []
    
    //MARK: - IBOutlets
    @IBOutlet var retrieveGeocodedPlacemarks: UIBarButtonItem!
    
    
    //MARK: - Init&Co.
    override func viewDidLoad() {
        super.viewDidLoad()
      
        tableView.register(VisitTableViewCell.nib(), forCellReuseIdentifier: VisitTableViewCell.reuseIdentifier())
        
       
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        updateUI()
    }
    
    
    //MARK: - Setup Methods
    private func setupDatasource() {
        let allVisits = SOXCoreDatabase.viewOnlyContext().fetchObjects(forEntityClass: TrackedVisit.self,
                                                                       sortByKeypath: TrackedVisit.Attributes.arrivalDate)
        visits = allVisits
        
    }
    
    private func updateUI() {
        setupDatasource()
        title = "\(visits.count) Visits"
        
        tableView.reloadData()
    }
    
    
    //MARK: - Action Methods
    @IBAction func retrieveGeocodedPlacemarksAction(_ sender: UIBarButtonItem) {
        print("retrieveGeocodedPlacemarksAction")
        let geoCoder = CLGeocoder()
        
        let editContext = SOXCoreDatabase.newEditContext(forUI: true)
        visits.forEach( { visit in
            if visit.placemark != nil {
                return
            }
            print("next visit")
            let clLocation = CLLocation(latitude: visit.latitude, longitude: visit.longitude)
            print("clLocation \(clLocation)")
            // Get location description
            geoCoder.reverseGeocodeLocation(clLocation,
                                            preferredLocale: Locale.current,
                                            completionHandler: { placemarks, error in
                if let error {
                    print(error.localizedDescription)
                    return
                }
                
                if let placemark = placemarks?.first {
                    visit.updateAndSaveWith(placemark: placemark, inContext: editContext)
                }
                else {
                    print("No placemark.")
                }
                
            })
        })
    }
    
}


// MARK: - Extension - UITableViewDataSource
extension VisitsTableViewController {

    override func numberOfSections(in tableView: UITableView)
    -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int)
    -> Int {
        let numberOfRowsInSection = visits.count
        return numberOfRowsInSection
    }

    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath)
    -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: VisitTableViewCell.reuseIdentifier(), for: indexPath) as? VisitTableViewCell else {
            fatalError("Must be VisitTableViewCell.") }

        let visit = visits[indexPath.row]
        cell.configure(forVisit: visit)

        return cell
    }
    

    
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    

    
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    

}
