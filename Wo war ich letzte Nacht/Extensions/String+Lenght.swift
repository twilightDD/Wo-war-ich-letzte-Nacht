//
//  String+Lenght.swift
//  Landrix Handwerk Mobile
//
//  Created by Peter Hauke on 31.08.22.
//  Copyright © 2022 Landrix Software GmbH & Co. KG. All rights reserved.
//

import Foundation

extension String {
    
    
    /// Limit length of `self` to given length.
    ///
    /// A good example for `trailing` could be "…"
    ///
    /// - Parameters:
    ///   - length: The length. If negativ, result will be `self`.
    ///   - trailing: A trailer for the `limited string`. It's count doesn't count!
    /// - Returns: The `limited string` or `self`, if given `lenght` is smaller than `self.count`.
    func limit(toLength length: Int, trailing: String? = nil) -> String {
        guard length > -1 else {
            return self }
        
        var limitedString: String
        
        if self.count <= length {
            limitedString = self
        }
        else {
            limitedString = String(self.prefix(length))
        }
        
        if let trailing = trailing {
            limitedString.append(trailing)
        }
        
        return limitedString
    }
    
}
