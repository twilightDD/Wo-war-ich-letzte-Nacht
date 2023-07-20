//
//  SOXEurekaFormatters.swift
//  Landrix Handwerk Mobile
//
//  Created by Peter Hauke on 02.11.21.
//  Copyright © 2021 Landrix Software GmbH & Co. KG. All rights reserved.
//

import Foundation

//MARK: -
//MARK: - SOXEurekaStringMaxLengthFormatter
class SOXEurekaStringMaxLengthFormatter: Formatter {
    
    //MARK: Lets and Vars
    let maxLength: Int
    
    
    //MARK: Init&CO
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    
    init(maxLength: Int) {
        self.maxLength = maxLength
        super.init()
    }
    
    
    //MARK: Overriden Methods
    override func string(for obj: Any?)
    -> String? {
        if let string = obj as? String {
            return String(string.prefix(maxLength))
        }
        return nil
    }
    
    
    override func getObjectValue(_ obj: AutoreleasingUnsafeMutablePointer<AnyObject?>?,
                                 for string: String,
                                 errorDescription error: AutoreleasingUnsafeMutablePointer<NSString?>?)
    -> Bool {
        if let obj = obj {
            obj.pointee = self.string(for: string) as AnyObject?
        }
        return true
    }
    
}
