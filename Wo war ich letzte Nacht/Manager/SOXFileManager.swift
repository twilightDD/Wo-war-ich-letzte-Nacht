//
//  SOXFileManager.swift
//  Landrix Handwerk Mobile
//
//  Created by Peter Hauke on 18.06.19.
//  Copyright © 2019 Landrix Software GmbH & Co. KG. All rights reserved.
//

import Foundation


// MARK: - SOXFileManager
class SOXFileManager: FileManager {
    
    // MARK: Singleton and statics
    static let sharedFileManager = SOXFileManager()
    static let fileManager: FileManager = FileManager.default

    
    // MARK: - Public Class Functions
    class func documentDirectoryURL()
    -> URL {
        let homeDirs:[URL] = fileManager.urls(for: .documentDirectory,
                                              in: .userDomainMask)
        guard let documentDirectoryURL = homeDirs.first else {
            fatalError("no documentDirectory found") }
        return documentDirectoryURL
    }

    
    class func contentsOfFile(url: URL)
    -> Data? {
        var fileData: Data?
        
        do {
            fileData = try Data(contentsOf: url)
        } catch let readError {
            print("\(readError.localizedDescription)")
        }
        
        return fileData
    }
    
    
    /// Size of file at given `file url`.
    /// - Parameter url: The file url.
    /// - Returns: Returns the `size` or `nil`.
    class func fileSize(atURL url: URL)
    -> Int64? {
        let path = url.path
        
        guard let attributesOfItem = try? sharedFileManager.attributesOfItem(atPath: path) else {
            return nil }
        
        let fileSize = attributesOfItem[.size] as? Int64
        return fileSize
    }

}

