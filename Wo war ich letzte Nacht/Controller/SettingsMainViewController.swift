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
    @IBOutlet var stopTrackingButton: UIButton!
    
    @IBOutlet var settingsStackView: UIStackView!
    @IBOutlet var statusDescriptionLabel: UILabel!
    @IBOutlet var statusLabel: UILabel!
    @IBOutlet var permanentTrackingDescriptionLabel: UILabel!
    @IBOutlet var permanentTrackingEnergyLabel: UILabel!
    @IBOutlet var permanentTrackingSwitch: UISwitch!
    @IBOutlet var monitorVisitsDescriptionLabel: UILabel!
    @IBOutlet var monitorVisitsEnergyLabel: UILabel!
    @IBOutlet var monitorVisitsSwitch: UISwitch!
    @IBOutlet var monitorSignificantChangesDescriptionLabel: UILabel!
    @IBOutlet var monitorSignificantChangesEnergyLabel: UILabel!
    @IBOutlet var monitorSignificantChangesSwitch: UISwitch!
    
    @IBOutlet var deleteLocationStoreButton: UIButton!
    
    //MARK: - Init&Co.
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        updateUI()
    }
    
    
    //MARK: - Private Methods
    private func updateUI() {
        
        // Status
        let isRunning = SOXUserDefaultsManager.bool(forKey: UserDefaultKey.permanentTracking)
        || SOXUserDefaultsManager.bool(forKey: UserDefaultKey.monitorVisits)
        || SOXUserDefaultsManager.bool(forKey: UserDefaultKey.monitorSignificantChanges)
        if isRunning {
            statusLabel.textColor = .systemGreen
            statusLabel.text = "Active"
        }
        else {
            statusLabel.textColor = .label
            statusLabel.text = "Inactive"
        }
        
        // Switches
        let permanentTracking = SOXUserDefaultsManager.bool(forKey: UserDefaultKey.permanentTracking)
        let monitorVisits = SOXUserDefaultsManager.bool(forKey: UserDefaultKey.monitorVisits)
        let monitorSignificantChanges = SOXUserDefaultsManager.bool(forKey: UserDefaultKey.monitorSignificantChanges)
        
        if permanentTracking {
            permanentTrackingSwitch.isOn = permanentTracking
            
            monitorVisitsDescriptionLabel.isEnabled = false
            monitorVisitsEnergyLabel.isEnabled = false
            monitorVisitsSwitch.isEnabled = false
            monitorVisitsSwitch.setOn(false, animated: true)
            
            monitorSignificantChangesDescriptionLabel.isEnabled = false
            monitorSignificantChangesEnergyLabel.isEnabled = false
            monitorSignificantChangesSwitch.isEnabled = false
            monitorSignificantChangesSwitch.setOn(false, animated: true)
        }
        else {
            permanentTrackingSwitch.isOn = permanentTracking
            
            monitorVisitsDescriptionLabel.isEnabled = true
            monitorVisitsEnergyLabel.isEnabled = true
            monitorVisitsSwitch.isEnabled = true
            monitorVisitsSwitch.setOn(monitorVisits, animated: true)
            
            monitorSignificantChangesDescriptionLabel.isEnabled = true
            monitorSignificantChangesEnergyLabel.isEnabled = true
            monitorSignificantChangesSwitch.isEnabled = true
            monitorSignificantChangesSwitch.setOn(monitorSignificantChanges, animated: true)
            
        }
        
    }
    
    private func updateTrackingStatus() {
        let permanentTracking = SOXUserDefaultsManager.bool(forKey: UserDefaultKey.permanentTracking)
        
        if permanentTracking {
            CoreDataLocationManager.startPermanentTracking()
            CoreDataLocationManager.stopMonitoringVisits()
            CoreDataLocationManager.stopMonitoringSignificantChanges()
        }
        else {
            CoreDataLocationManager.stopPermanentTracking()
            
            SOXUserDefaultsManager.bool(forKey: UserDefaultKey.monitorVisits)
            ? CoreDataLocationManager.startMonitoringVisits() : CoreDataLocationManager.stopMonitoringVisits()
            
            SOXUserDefaultsManager.bool(forKey: UserDefaultKey.monitorSignificantChanges)
            ? CoreDataLocationManager.startMonitoringSignificantChanges() : CoreDataLocationManager.stopMonitoringSignificantChanges()
        }
    }
    
    private func updateMonitorVisitStatus() {
        SOXUserDefaultsManager.bool(forKey: UserDefaultKey.monitorVisits)
        ? CoreDataLocationManager.startMonitoringVisits() : CoreDataLocationManager.stopMonitoringVisits()
    }
    
    private func updateSignificantChangesStatus() {
        SOXUserDefaultsManager.bool(forKey: UserDefaultKey.monitorSignificantChanges)
        ? CoreDataLocationManager.startMonitoringSignificantChanges() : CoreDataLocationManager.stopMonitoringSignificantChanges()
    }
    

    //MARK: - Action Methods
    //MARK: Tracking Management
    @IBAction func stopTrackingButtonAction(_ sender: UIButton) {
        SOXUserDefaultsManager.update(UserDefaultKey.permanentTracking, value: false)
        SOXUserDefaultsManager.update(UserDefaultKey.monitorVisits, value: false)
        SOXUserDefaultsManager.update(UserDefaultKey.monitorSignificantChanges, value: false)
       
        updateUI()
        
        SOXLocationManager.stopAll()
    }
    
    //MARK: Switches
    @IBAction func permanentTrackingSwitchAction(_ sender: UISwitch) {
        SOXUserDefaultsManager.update(UserDefaultKey.permanentTracking, value: sender.isOn)
        updateUI()
        updateTrackingStatus()
    }
    
    @IBAction func monitorVisitsSwitchAction(_ sender: UISwitch) {
        SOXUserDefaultsManager.update(UserDefaultKey.monitorVisits, value: sender.isOn)
        updateUI()
        updateMonitorVisitStatus()
    }
    
    @IBAction func monitorSignificantChangesSwitchAction(_ sender: UISwitch) {
        SOXUserDefaultsManager.update(UserDefaultKey.monitorSignificantChanges, value: sender.isOn)
        updateUI()
        updateSignificantChangesStatus()
    }
    
    
    //MARK: Deletion
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
