//
//  SOXUserDefaultsManager.swift
//  Wo war ich letzte Nacht
//
//  Created by Peter Hauke on 24.07.23.
//

import Foundation

enum UserDefaultKey: String, CaseIterable {
    
    ///boool
    case trackingShouldBeActive = "Tracking_shouldBeActive"
    /// bool
    case monitorVisits = "Tracking_monitorVisits"
    /// bool
    case monitorSignificantChanges = "Tracking_monitorSignificantChanges"
    /// bool
    case permanentTracking = "Tracking_permanentTracking"
    /// bool
    case autoGeolocate = "Interweb_autoGeolocate"
}


//MARK: - SOXUserDefaultsManager
class SOXUserDefaultsManager: NSObject {
    
    //MARK: Private Lets and Vars
    private static let shared = SOXUserDefaultsManager()
    
    
    //MARK: - Remove Values
    static func removeValue(forKey key: UserDefaultKey) {
        UserDefaults.standard.removeObject(forKey: key.rawValue)
    }
    
    static func removeAllUserDefaults() {
        let dictionaryRepresentation = dictionaryRepresentation()
        dictionaryRepresentation.keys.forEach( { key in
            UserDefaults.standard.removeObject(forKey: key)
        })
    }
    
    //MARK: - Update Values
    
    static func update(_ key: UserDefaultKey, value: Any?) {
        UserDefaults.standard.set(value, forKey: key.rawValue)
    }
    
    
    //MARK: - Get Valies
    static func dictionaryRepresentation()
    -> [String : Any] {
        return UserDefaults.standard.dictionaryRepresentation()
    }
    
    static func object(forKey key: UserDefaultKey)
    -> Any? {
        let object = UserDefaults.standard.object(forKey: key.rawValue)
        return object
    }
    
    static func array(forKey key: UserDefaultKey) -> [Any]? {
        return UserDefaults.standard.array(forKey: key.rawValue)
    }
    
    static func bool(forKey key: UserDefaultKey)
    -> Bool {
        return UserDefaults.standard.bool(forKey: key.rawValue)
    }
    
    static func data(forKey key: UserDefaultKey)
    -> Data? {
        return UserDefaults.standard.data(forKey: key.rawValue)
    }
    
    static func double(forKey key: UserDefaultKey)
    -> Double {
        return UserDefaults.standard.double(forKey: key.rawValue)
    }
    
    static func dictionary(forKey key: UserDefaultKey)
    -> [String : Any]? {
        return UserDefaults.standard.dictionary(forKey: key.rawValue)
    }
    
    static func float(forKey key: UserDefaultKey)
    -> Float {
        return UserDefaults.standard.float(forKey: key.rawValue)
    }
    
    static func integer(forKey key: UserDefaultKey)
    -> Int {
        return UserDefaults.standard.integer(forKey: key.rawValue)
    }
    
    static func string(forKey key: UserDefaultKey)
    -> String? {
        return UserDefaults.standard.string(forKey: key.rawValue)
    }
    
    static func stringArray(forKey key: UserDefaultKey)
    -> [String]? {
        return UserDefaults.standard.stringArray(forKey: key.rawValue)
    }
    
    static func url(forKey key: UserDefaultKey)
    -> URL? {
        return UserDefaults.standard.url(forKey: key.rawValue)
    }
    
}
