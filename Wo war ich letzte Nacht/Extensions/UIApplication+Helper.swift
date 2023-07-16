//
//  UIApplication+Helper.swift
//  Landrix Handwerk Mobile
//
//  Created by Peter Hauke on 11.10.19.
//  Copyright © 2019 Landrix Software GmbH & Co. KG. All rights reserved.
//

import Foundation
import UIKit

extension UIApplication {
    
    class func interfaceOrientation()
        -> UIInterfaceOrientation {
            if let interfaceOrientation = UIApplication.keyWindow()?.windowScene?.interfaceOrientation {
                return interfaceOrientation
            }
            return .unknown
    }

    class func keyWindow()
        -> UIWindow? {
            let keyWindow = UIApplication.shared.windows.first(where: { $0.isKeyWindow })
            return keyWindow
    }


    // pre-ios13: class func topViewController(controller: UIViewController? = UIApplication.shared.keyWindow?.rootViewController)
    // https://stackoverflow.com/questions/57134259/how-to-resolve-keywindow-was-deprecated-in-ios-13-0
    class func topViewController(controller: UIViewController? = UIApplication.keyWindow()?.rootViewController)
        -> UIViewController? {

            if let navigationController = controller as? UINavigationController {
                return topViewController(controller: navigationController.visibleViewController)
            }

            if let tabController = controller as? UITabBarController {
                if let selected = tabController.selectedViewController {
                    return topViewController(controller: selected)
                }
            }

            if let presented = controller?.presentedViewController {
                return topViewController(controller: presented)
            }

            return controller
    }
}
