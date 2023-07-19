//
//  SettingsMainViewController.swift
//  Wo war ich letzte Nacht
//
//  Created by Peter Hauke on 16.07.23.
//

import UIKit

//MARK: - SettingsMainViewController
class SettingsMainViewController: UIViewController {

    
    //MARK: Lets&Vars
    
    //MARK: - IBOutlets
    @IBOutlet var startVisitTrackingButton: UIButton!
    @IBOutlet var stopTrackingButton: UIButton!
    @IBOutlet var deleteLocationStoreButton: UIButton!
    
    //MARK: - Init&Co.
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    

    //MARK: - Action Methods
    @IBAction func startVisitTrackingButtonAction(_ sender: UIButton) {
        CoreDataLocationManager.startMonitoringVisits()
    }
    
    
    @IBAction func stopTrackingButtonAction(_ sender: UIButton) {
        SOXLocationManager.stopUpdatingLocation(force: true)
        
        CoreDataLocationManager.stopMonitoringVisits()
    }
    
    
    @IBAction func deleteLocationStoreButtonAction(_ sender: UIButton) {
        let alertView = UIAlertController.init(title: "Sollen alle Visits gelöscht werden?",
                                               message: nil,
                                               preferredStyle: .alert)
        alertView.addAction(UIAlertAction.init(title: "Niemand soll was wissen!",
                                               style: .destructive,
                                               handler:  { alertAction in
            SOXCoreDatabase.performAndSaveInUIEditContext(workingBlock:  { context in
                let _ = context.forgetAllDatabaseObjects()
            })
        }))
        
        alertView.addAction(UIAlertAction.init(title: "Nö, lieber nicht",
                                               style: .cancel))
        
        present(alertView, animated: true)
    }
   
}
