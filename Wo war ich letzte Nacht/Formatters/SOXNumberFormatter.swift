//
//  SOXNumberFormatter.swift
//  Landrix Handwerk Mobile
//
//  Created by Peter Hauke on 24.09.21.
//  Copyright © 2021 Landrix Software GmbH & Co. KG. All rights reserved.
//

import Foundation


class SOXNumberFormatter {
    
    static internal let shared = SOXNumberFormatter()
    
    lazy var numberFormatter: NumberFormatter = {
        let numberFormatter = NumberFormatter()
        numberFormatter.usesSignificantDigits = true
        return numberFormatter
    }()
    
}

extension SOXNumberFormatter {
    
    class func stringOf(_ double: Double)
    -> String {
        guard let string = SOXNumberFormatter.shared.numberFormatter.string(from: NSNumber.init(value: double)) else {
            return "" }
        return string
    }
    
}

extension Double {
    
    func string()
    -> String {
        let string = SOXNumberFormatter.stringOf(self)
        return string
    }
    
}
