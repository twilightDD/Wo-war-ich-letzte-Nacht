//
//  NSManagedObject+Convenients.swift
//  Landrix Handwerk Mobile
//
//  Created by Peter Hauke on 10.07.19.
//  Copyright © 2019 Landrix Software GmbH & Co. KG. All rights reserved.
//

import Foundation
import CoreData

// MARK: - Extension - EntityName
extension SOXManagedObject {
    
    class func entityName()
    -> String {
        let entityName = String(describing: self)
        return entityName
    }

}


// MARK: - Extension - changedValues() Keys and Values
extension SOXManagedObject {
    
    func changedKeys()
    -> [String]? {
        guard let changedValues = _changedValues() else {
            return nil }
        
        let allKeys = changedValues.keys // Dictionary<String, Any>.Keys - Swift fuck up! ph
        let changedKeys = Array.init(allKeys)
        return changedKeys
    }

    
    func changedValuesValues()
    -> [Any]? {
        guard let changedValues = _changedValues() else {
            return nil }
        
        let values = changedValues.values // Dictionary<String, Any>.Keys - Swift fuck up! ph
        let changedValuesValues = Array.init(values)
        return changedValuesValues
    }

    
    private func _changedValues()
    -> [String : Any]? {
        let changedValues = self.changedValues()
        return changedValues.count > 0 ? changedValues : nil
    }
    
    
    func committedValue(forKey key: String)
    -> Any? {
        let committedValuesDict = committedValues(forKeys: nil)
        let commitedValue = committedValuesDict[key]
        return commitedValue
    }
    
}
