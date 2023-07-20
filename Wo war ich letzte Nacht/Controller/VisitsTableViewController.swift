//
//  VisitsTableViewController.swift
//  Wo war ich letzte Nacht
//
//  Created by Peter Hauke on 20.07.23.
//

import UIKit

//MARK: - VisitsTableViewController
class VisitsTableViewController: UITableViewController {
    
    //MARK: - Lets and Vars
    private var visits: [TrackedVisit] = []
    
    
    //MARK: - Init&Co.
    override func viewDidLoad() {
        super.viewDidLoad()
      
        tableView.register(VisitTableViewCell.nib(), forCellReuseIdentifier: VisitTableViewCell.reuseIdentifier())
        
       
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        setupDatasource()
        title = "\(visits.count) Visits"
        
        tableView.reloadData()
    }
    
    
    //MARK: - Setup Methods
    private func setupDatasource() {
        let allVisits = SOXCoreDatabase.viewOnlyContext().fetchObjects(forEntityClass: TrackedVisit.self,
                                                                       sortByKeypath: TrackedVisit.Attributes.arrivalDate)
        visits = allVisits
        
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
