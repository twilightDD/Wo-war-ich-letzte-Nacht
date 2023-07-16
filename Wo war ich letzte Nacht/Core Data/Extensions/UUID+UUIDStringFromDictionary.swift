//
//  UUID+UUIDStringFromDictionary.swift
//  Landrix Handwerk Mobile
//
//  Created by Peter Hauke on 20.01.20.
//  Copyright © 2020 Landrix Software GmbH & Co. KG. All rights reserved.
//

import Foundation

//MARK: - Extension - UUID extraction from dictionary
extension UUID {

    /// Parses given dictionary for string for key `uuid` and returns a UUID.
    /// - Parameter dictionary: The dictionary.
    /// - Returns: The UUID.
    static func uuidFromDictionary(_ dictionary: [AnyHashable: Any])
    -> UUID {
        guard let uuid = optionalString(dictionary[SOXManagedObject.Attributes.uuid] as? String) else {
            if let dictionary = dictionary as? [String : String] {
//                SOXAnalytics.trackEvent(named: "UUID.uuidFromDictionary", properties: dictionary)
            }
            fatalError("uuidString must not be nil.") }
        return uuid
    }

}

//MARK: - Extension - UUID String handling
extension UUID {

    static func optionalString(_ optionalString: String?)
    -> UUID? {
        guard let string = optionalString,
              let uuid = UUID.init(uuidString: string) else {
            return nil }
        
        return uuid
    }
    
    
    /// Extracts first part of given UUID.
    /// - Parameter uuid: The UUID
    /// - Returns: I.E. 13611452-D99E-4DB2-8490-524A6F3B0CFA -> 13611452
    static func uuidStringFirstPart(ofUUID uuid: UUID)
    -> String {
        let firstUUIDPart = uuidStringFirstPart(ofUUIDString: uuid.uuidString)
        return firstUUIDPart
    }
    
    
    /// Extracts first part of given uuidString.
    /// - Parameter uuidString: The uuidString.
    /// - Returns: I.E. 13611452-D99E-4DB2-8490-524A6F3B0CFA -> 13611452
    static func uuidStringFirstPart(ofUUIDString uuidString: String)
    -> String {
        let uuidParts = uuidString.split(separator: "-")
        let firstUUIDPart = String(uuidParts[0])
        return firstUUIDPart
    }

}
