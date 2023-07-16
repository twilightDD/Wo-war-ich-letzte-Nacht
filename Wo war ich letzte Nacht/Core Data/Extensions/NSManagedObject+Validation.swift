//
//  NSManagedObject+Validation.swift
//  Landrix Handwerk Mobile
//
//  Created by Peter Hauke on 23.10.19.
//  Copyright © 2019 Landrix Software GmbH & Co. KG. All rights reserved.
//

import Foundation
import CoreData

// MARK: - Extension: Validation
extension SOXManagedObject {

    /**
     Validates the receiver.

     Presents an alert with further information.

     - Parameter title: The title of the alert.
     - Parameter buttonTitle: Title The title of the alert button.

     - Returns: `true` if validation was successful. Otherwise `false`.
     */
    func validateSOXForUpdate(title: String? = nil, buttonTitle: String? = nil)
        -> Bool {
            if let validationError = validateUpdate() {
                var title = title
                var buttonTitle = buttonTitle

                if title  == nil {
                    title = "ValidationError on\n\(entity.managedObjectClassName ?? "Unknown managedObjectClassName")"
                }
                if buttonTitle == nil {
                    buttonTitle = "Der Vorgang wurde nicht abgeschlossen"
                }

                SOXErrorManager.presentError(title: title!,
                                             error: validationError,
                                             buttonTitle: buttonTitle!)

                return false
            }

            return true

    }


    /**
     Validates the receiver.

     Presents **no** alert with further information.

     - See: func validateSOXForUpdate()  -> Bool
     - See: func validateSOXForUpdate(title: String?, buttonTitle: String?) -> Bool

     - Returns: `true` if validation was successful. Otherwise `false`.
     */
    func validateSOXForUpdateWithoutAlert()
        -> Bool {
            let validationError = validateUpdate() == nil ? true : false
            return validationError
    }


    //MARK: - Private Methods

    /**
     Validates the receiver.

     Calls validateForUpdate()

     - Returns: An `Error` object if a validation error occurs. Otherwise `nil`.
     */
    private func validateUpdate()
        -> Error? {

            do {
                try validateForUpdate()
                return nil
            }
            catch let validationError {
                return validationError
            }
    }

}
