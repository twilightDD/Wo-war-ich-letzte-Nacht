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
    static let VisitDetailsViewControllerSegueKey = "VisitDetailsViewControllerSegue"
    
    private var visits: [TrackedVisit] = []
    
    //MARK: - IBOutlets
    @IBOutlet var shareBarButtonItem: UIBarButtonItem!
    @IBOutlet var importBarButtonItem: UIBarButtonItem!
    @IBOutlet var retrieveGeocodedPlacemarks: UIBarButtonItem!
    
    
    //MARK: - Init&Co.
    override func viewDidLoad() {
        super.viewDidLoad()
      
        tableView.register(VisitTableViewCell.nib(), forCellReuseIdentifier: VisitTableViewCell.reuseIdentifier())
        
        setupUI()
       
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        updateUI()
    }
    
    //MARK: - Segue handling
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == VisitsTableViewController.VisitDetailsViewControllerSegueKey {
            guard let visit = sender as? TrackedVisit else {
                fatalError("Theres no TrackedVisit to show.")}
            guard let destination = segue.destination as? VisitDetailsViewController else {
                fatalError("Destination must be a VisitDetailsViewController.")}
            
            destination.visit = visit
        }
    }
    
    
    //MARK: - Setup Methods
    private func setupUI() {
        tableView.refreshControl = UIRefreshControl()
        tableView.refreshControl?.addTarget(self, action: #selector(callPullToRefresh), for: .valueChanged)
    }
    
    
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
    @IBAction func shareBarButtonItemAction(_ sender: UIBarButtonItem) {
        let allVisits = SOXCoreDatabase.fetchObjects(forEntityClass: TrackedVisit.self,
                                                     sortByKeypath: TrackedVisit.Attributes.arrivalDate)
        let exportDicts = allVisits.map( { $0.exportDictionary() })
        var jsonString: String!
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: exportDicts,
                                                      options: .prettyPrinted)
            jsonString = String(data: jsonData, encoding: .utf8)
        }
        catch let jsonError {
            print(jsonError.localizedDescription)
            fatalError()
        }
        
        let activityViewController = UIActivityViewController(activityItems: [jsonString ?? "No data available."],
                                                              applicationActivities: nil)
        present(activityViewController, animated: true)
    }
    
    @IBAction func importBarButtonItemAction(_ sender: UIBarButtonItem) {
        let alertView = UIAlertController.init(title: "Import", message: nil, preferredStyle: .alert)
        
        alertView.addTextField(configurationHandler:  { textField in
            print("configurationHandler")
        })
        
        alertView.addAction(UIAlertAction.init(title: "Importiere", style: .default, handler:  { [weak self] action in
            guard let textField = alertView.textFields?.first,
                  let importText = textField.text,
                  let importData = importText.data(using: .utf8) else {
                return }
            
            do {
                if let jsonDict = try JSONSerialization.jsonObject(with: importData) as? [[String : Any]] {
                    let _ = TrackedVisit.importVisits(jsonDict)
                    self?.updateUI()
                }
                else {
                    print("IMPORT ERROR")
                }
                
            }
            catch let jsonError {
                print(jsonError.localizedDescription)
            }
            
        }))
        
        alertView.addAction(UIAlertAction.init(title: "Abbrechen", style: .cancel))
        
        present(alertView, animated: true)
    }
    
    @IBAction func retrieveGeocodedPlacemarksAction(_ sender: UIBarButtonItem) {
        Task { @MainActor in
            await retrieveGeocodedPlacemarks()
        }
    }
    
    
    //MARK: - Private Methods
    private func retrieveGeocodedPlacemarks() async {
        let geoCoder = CLGeocoder()
        let editContext = SOXCoreDatabase.newEditContext(forUI: true)
        
        for visit in visits {
            guard visit.placemark == nil else {
                print("Placemark already set for \(visit.uuid.uuidString)")
                continue }
            
            let clLocation = CLLocation(latitude: visit.latitude, longitude: visit.longitude)
            
            do {
                let placemarks = try await geoCoder.reverseGeocodeLocation(clLocation)
                if let placemark = placemarks.first {
                    visit.updateAndSaveWith(placemark: placemark,
                                            inContext: editContext,
                                            completionBlock: { [weak self] in
                        self?.updateUI()
                    })
                    print("Placemarks found for \(visit.uuid.uuidString)")
                }
                else {
                    print("Placemarks not found for \(visit.uuid.uuidString)")
                }
            }
            catch let geoCoderError {
                print(geoCoderError.localizedDescription)
            }
        }
        
        callPullToRefresh()
    }
    
    @objc
    private func callPullToRefresh(){
        updateUI()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self] in
            self?.tableView.refreshControl?.endRefreshing()
            self?.tableView.reloadData()
        }
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
    override func tableView(_ tableView: UITableView,
                            commit editingStyle: UITableViewCell.EditingStyle,
                            forRowAt indexPath: IndexPath) {
        let selectedVisit = visits[indexPath.row]
        if editingStyle == .delete {
            SOXCoreDatabase.performAndSaveInUIEditContext(
                workingBlock: { context in
                    let visitInContext = selectedVisit.getIn(context: context)
                    visitInContext.forget()
            }, completionBlock: { [weak self] in
                self?.updateUI()
            })
            
            
        }
    }
    
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedVisit = visits[indexPath.row]
        performSegue(withIdentifier: VisitsTableViewController.VisitDetailsViewControllerSegueKey, sender: selectedVisit)
    }

}
