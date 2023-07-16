//
//  DispatchQueue+Delay.swift
//  Landrix Handwerk Mobile
//
//  Created by Peter Hauke on 12.02.20.
//  Copyright © 2020 Landrix Software GmbH & Co. KG. All rights reserved.
//

import Foundation


extension DispatchQueue {

    static func dispatchOnMain(_ closure: @escaping ()->()) {
        DispatchQueue.main.async {
            closure()
        }
    }
    
    /// Perform given block on mainThread after delay in seconds.
    static func delayOnMain(_ delay: Double, execute closure: @escaping ()->()) {
        let when = DispatchTime.now() + delay
        DispatchQueue.main.asyncAfter(deadline: when, execute: closure)
    }

}
