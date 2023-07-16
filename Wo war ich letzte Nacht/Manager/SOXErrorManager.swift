//
//  SOXErrorManager.swift
//  Landrix Handwerk Mobile
//
//  Created by Peter Hauke on 10.10.19.
//  Copyright © 2019 Landrix Software GmbH & Co. KG. All rights reserved.
//

import Foundation
import UIKit


//MARK: - SOXErrorManager
class SOXErrorManager {

    //MARK: Lets and Vars

    // Private Lets and Vars
    private static let shared = SOXErrorManager()

    //MARK: - Public Class Methods
    class func presentError(title titleString: String,
                            message messageString: String?) {
        let error = SOXError()
        error.title = titleString
        error.message = messageString ?? "Ein Fehlergrund konnte nicht ermittelt werden."
        presentError(error)
    }

    class func presentError(title titleString: String, message messageString: String?, buttonTitle: String?) {
       presentError(title: titleString,
                    message: messageString,
                    buttonTitle: buttonTitle ?? "Okay",
                    buttonStyle: buttonTitle == nil ? .default : .destructive,
                    completionBlock: nil)
    }

    class func presentError(title titleString: String,
                            message messageString: String?,
                            buttonTitle: String,
                            buttonStyle: UIAlertAction.Style,
                            completionBlock: ((UIAlertAction) -> Void)?) {
        var alertActions = [UIAlertAction]()

        let userAction = UIAlertAction.init(title: buttonTitle,
                                            style: buttonStyle,
                                            handler: completionBlock
        )
        alertActions.append(userAction)

        let error = SOXError.init(title: titleString,
                                  message: messageString,
                                  alertActions: alertActions)
        presentError(error)


    }

    class func presentError(title titleString: String,
                            message messageString: String?,
                            buttonTitle: String,
                            buttonStyle:  UIAlertAction.Style,
                            completionBlock: ((UIAlertAction) -> Void)?,
                            cancelTitle: String,
                            cancelBlock:((UIAlertAction) -> Void)?) {

        var alertActions = [UIAlertAction]()

        let userAction = UIAlertAction.init(title: buttonTitle,
                                            style: buttonStyle,
                                            handler: completionBlock
        )
        alertActions.append(userAction)

        let cancelAction = UIAlertAction.init(title: cancelTitle,
                                              style: .default,
                                              handler: cancelBlock)
        alertActions.append(cancelAction)


        let error = SOXError.init(title: titleString,
                                  message: messageString,
                                  alertActions: alertActions)
        presentError(error)
    }

    class func presentNotImplementedYetError() {
        SOXErrorManager.presentError(title: "Not implemented yet",
                                     message: "This function is under development.\nBelevie me!")
    }

    class func presentError(title: String, error: Error) {
        var message = "The following errors have occurred:\n"

        let nsError = error as NSError

        if let detailedNSErrors = nsError.userInfo["NSDetailedErrors"] as? [NSError] {
            for detailedNSError in detailedNSErrors {
                if let errorKey = detailedNSError.userInfo["NSValidationErrorKey"] {
                    message.append("- \(errorKey)\n")
                }
                else {
                    message.append("- Unknown error.\n")
                }
            }
        }

        SOXErrorManager.presentError(title: title,
                                     message: message)
    }

    class func presentError(title: String, error: Error, buttonTitle: String?) {
        var message = "The following errors have occurred:\n"

        let nsError = error as NSError

        if let detailedNSErrors = nsError.userInfo["NSDetailedErrors"] as? [NSError] {
            for detailedNSError in detailedNSErrors {
                if let errorKey = detailedNSError.userInfo["NSValidationErrorKey"] {
                    message.append("- \(errorKey)\n")
                }
                else {
                    message.append("- Unknown error.\n")
                }
            }
        }

        if let buttonTitle = buttonTitle {
            SOXErrorManager.presentError(title: title,
                                         message: message,
                                         buttonTitle: buttonTitle,
                                         buttonStyle: .destructive,
                                         completionBlock: nil)
        }
        else {
            SOXErrorManager.presentError(title: title,
                                         message: message)
        }


    }

}

//MARK: - Extension - Present Errors to User
internal extension SOXErrorManager {
     private class func presentError(_ error: SOXError) {
        let alertController = UIAlertController.init(title: error.title,
                                                     message: error.message,
                                                     preferredStyle: .alert)
        if error.alertActions.count > 0 {
            for alertAction in error.alertActions {
                alertController.addAction(alertAction)
            }
        }
        else {
            alertController.addAction(confirmAction())
        }


        DispatchQueue.main.async {
            UIApplication.topViewController()?.present(alertController,
                                                       animated: true,
                                                       completion: {
                                                        
            })
        }
    }

}


internal extension SOXErrorManager {
    class func confirmAction()
        -> UIAlertAction {
            let confirmAction = UIAlertAction.init(title: "Okay",
                                                   style: .default,
                                                   handler: nil)

            return confirmAction
    }

    class func defaultCancelAction()
        -> UIAlertAction {
            let defaultCancelAction = UIAlertAction.init(title: "Abbrechen",
                                                   style: .cancel,
                                                   handler: nil)

            return defaultCancelAction
    }

}

//MARK: - SOXError
internal class SOXError {
    //MARK: Lets and Vars
    var title: String?
    var message: String?

    var alertActions = [UIAlertAction]()

    convenience init(title: String,
                     message: String? = nil,
                     alertActions: [UIAlertAction]) {
        self.init()

        self.title = title
        self.message = message
        self.alertActions = alertActions
    }
}

struct OperationDoneStatus {
    var descripton: String?
    var direction: Direction
    var errorDescripton: String? {
        didSet {
            hasError = true
        }
    }
    var hasError: Bool = false
    var uuidString: String?


    init(descripton: String? = nil,
         direction: Direction,
         errorDescripton: String? = nil,
         hasError: Bool? = false,
         uuidString: String? = nil) {
        self.descripton = descripton
        self.direction = direction
        self.errorDescripton = errorDescripton
        self.hasError = hasError ?? false
        self.uuidString = uuidString

        if hasError == false
            && errorDescripton?.isNotEmpty ?? false {
            self.hasError = true
        }

    }

    enum Direction {
        case dataProcessing
        case delete
        case download
        case status
        case upload
    }

}


//struct MyStatus {
//    var errorDescription: String? = nil
//    var hasError: Bool = false
//
//    init(errorDescription: String? = nil,
//         hasError: Bool? = false) {
//        self.errorDescription = errorDescription
//        self.hasError = hasError
//
//        if errorDescription?.isNotEmpty() == true {
//            self.hasError = true
//        }
//    }
//
//}
