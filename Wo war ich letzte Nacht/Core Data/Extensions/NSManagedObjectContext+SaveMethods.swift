//
//  NSManagedObjectContext+SaveMethods.swift
//  Landrix Handwerk Mobile
//
//  Created by Peter Hauke on 16.07.19.
//  Copyright © 2019 Landrix Software GmbH & Co. KG. All rights reserved.
//

import Foundation

import CoreData
import UIKit


extension NSManagedObjectContext {
    
    // Uses performAndWait. Saves parentContext, if existing.
    func saveContext(completionBlock: CompletionBlock? = nil) {
        
        performAndWait  {
            
            // Has changes?
            guard hasChanges == true
                else {
                    print("\(#function) Don't save context named \(name ?? "no name"): has no changes.")
                    return
            }
            
            print("\(#function) Going so save context named \(name ?? "no name")")
            
            var success: Bool = true
            // Save
            do {
                try save()
            }
            catch let saveError {
                handleSaveError(saveError)
                success = false
            }
            
            if success {
                parent?.saveContext()
                
                if let completionBlock = completionBlock {
                    completionBlock()
                }
            }
        }
    }
    
}


//MARK: - Extension - Handle error and inform user
extension NSManagedObjectContext {
    
    private func handleSaveError(_ error: Error) {
        let error = error as NSError
        let userInfo = error.userInfo
        let errorCode = error.code
        
        let detailedErrorDescriptions = NSCountedSet.init()

        // Single error
        if errorCode == NSValidationMissingMandatoryPropertyError {
            detailedErrorDescriptions.add(detailedErrorDescription(userInfo: userInfo))
        }
        // Multiple errors
        else if errorCode == NSValidationMultipleErrorsError {
            let detailedErrors = userInfo[NSDetailedErrorsKey] as? [NSError]
            detailedErrors?.forEach( { detailedError in
                detailedErrorDescriptions.add(detailedErrorDescription(userInfo: detailedError.userInfo))
            })
        }
        

        // Inform user
        var message = "\n"
        detailedErrorDescriptions.forEach( { detailedErrorDescription in
            let count = detailedErrorDescriptions.count(for: detailedErrorDescription)
            message.append(contentsOf: "\(count)x \(detailedErrorDescription)\n")
        })
        
//        SOXAnalytics.trackError(named: "Error: Core Data save", error: error as NSError)
        
        let alertController = UIAlertController.init(title: "Ein Fehler beim Speichern der Datenbank ist aufgetreten (\(errorCode)).\nBitte machen Sie einen Screenshot dieser Meldung und senden Sie ihn an Landrix.",
                                                     message: message,
                                                     preferredStyle: .alert)
        
        // - Action: crash afterwards
        let crashAction = UIAlertAction.init(title: "Crash",
                                             style: .destructive,
                                             handler: { _ in
            fatalError("Ein Fehler beim Speichern der Datenbank ist aufgetreten.")
        })
        alertController.addAction(crashAction)
        
        // - Present error message
        DispatchQueue.delayOnMain(0, execute: {
            UIApplication.topViewController()?.present(alertController,
                                                       animated: true,
                                                       completion: {})
        })
    }
        
    
    private func detailedErrorDescription(userInfo: [String : Any])
    -> String {
        var detailedErrorDescription: String
        if let validationObject = userInfo[NSValidationObjectErrorKey] as? NSManagedObject,
           let entityName = validationObject.entity.name,
           let validationKey = userInfo[NSValidationKeyErrorKey] as? String {
            detailedErrorDescription = entityName + " (" + validationKey + ")"
        }
        else {
            detailedErrorDescription = "Keine Beschreibung verfügbar."
        }
        
        return detailedErrorDescription
    }
    
}
