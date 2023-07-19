//
//  SOXWatchDogFRC.swift
//  Landrix Handwerk Mobile
//
//  Created by Peter Hauke on 06.07.21.
//  Copyright © 2021 Landrix Software GmbH & Co. KG. All rights reserved.
//

import UIKit

import CoreData


class SOXWatchDogFRC: SOXTableViewDatasourceFRC {

    class func manager(withEntityForName entityName: String,
                       context: NSManagedObjectContext = SOXCoreDatabase.viewOnlyContext(),
                       predicateString: String? = nil,
                       arguments: [Any]? = nil,
                       predicate: NSPredicate? = nil,
                       delegate: SOXDatasourceManagerDelegate,
                       name: String?)
    -> SOXWatchDogFRC {
        let manager = SOXWatchDogFRC()
        manager.supressViewUpdates = true
        
        var predicate = predicate
        if let predicateString = predicateString, predicateString.count > 0,
           let arguments = arguments, arguments.count > 0 {
            predicate = NSPredicate.init(format: predicateString, argumentArray: arguments)
        }
        
        manager.setupFetchedResultsController(withEntityForName: entityName,
                                              sortedByAttribute: nil,
                                              managedObjectContext: context,
                                              delegate: delegate,
                                              predicate: predicate)
        
        return manager
    }
    
    
}
