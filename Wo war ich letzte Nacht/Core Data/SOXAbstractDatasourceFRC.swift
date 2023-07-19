//
//  SOXAbstractDatasourceFRC.swift
//  SwiftDemoFRC
//
//  Created by Peter Hauke on 07.05.19.
//  Copyright © 2019 Peter Hauke. All rights reserved.
//

import UIKit

import CoreData


// MARK: - SOXAbstractDatasourceFRC
class SOXAbstractDatasourceFRC: NSObject, NSFetchedResultsControllerDelegate {
    
    // MARK: Public Properties
    var supressViewUpdates = false
    weak var view: UIView?
    
    ///Optional name for debugging.
    var name: String?
    
    /**
     Schedule cell configuration synchronously if true
     
     Default value is true
     
     - Warning:
     Always use true for cells with height changes by AutoLayout.
     Don't forget this for your tableview, if true:
     
     - tableView.rowHeight = UITableViewAutomaticDimension;
     - tableView.estimatedRowHeight = your estimated height;
     */
    var configureCellsSynchronously:Bool = true
    
    private(set) var fetchedResultsController: NSFetchedResultsController<NSFetchRequestResult>?
    private(set) var reuseIdentifier: String = ""
    private(set) weak var context: NSManagedObjectContext?
    private(set) weak var delegate: SOXDatasourceManagerDelegate?
    private(set) var setupBlock: SOXDataSourceManagerCellSetupBlock?
    private(set) var updateBlock: SOXDataSourceManagerCellSetupBlock?
    private(set) var cacheName: String?
    
    
    // MARK: - Public Methods
    func indexPathForData(_ managedObject: SOXManagedObject)
        -> IndexPath? {
            let indexPathForData = fetchedResultsController?.indexPath(forObject: managedObject)
            return indexPathForData
    }


    func dataFor(IndexPath indexPath:IndexPath)
        -> SOXManagedObject {
            guard let data = dataOptionalFor(indexPath: indexPath)
                else { fatalError("No object for indexpath \(indexPath)" ) }

            return data
    }
    
    
    func dataOptionalFor(indexPath: IndexPath)
    -> SOXManagedObject? {
        guard let dataOfSection = dataOptionalFor(section: indexPath.section),
              indexPath.row < dataOfSection.count else {
                  return nil }
        
        let dataOptional = dataOfSection[indexPath.row]
        return dataOptional
    }
    
    
    func dataOptionalFor(section: Int)
    -> [SOXManagedObject]? {
        guard section <= fetchedResultsController?.sections?.count ?? -1,
              let sectionInfo: NSFetchedResultsSectionInfo = fetchedResultsController?.sections?[section] else {
            return nil }
        guard let objects = sectionInfo.objects as? [SOXManagedObject] else {
            fatalError("\(#file) \(#line) Must be [SOXManagedObject]") }
        
        return objects
    }
    
    
    func dataOptionalFor(ongoingIndex: Int)
    -> SOXManagedObject? {
        guard let fetchedObjects = fetchedResultsController?.fetchedObjects,
              fetchedObjects.count >= ongoingIndex
        else { return nil }
        
        let dataOptional = fetchedObjects[ongoingIndex] as? SOXManagedObject
        return dataOptional
    }
    
    func fetchedObjects()
    -> [SOXManagedObject] {
        guard let fetchedObjects = fetchedResultsController?.fetchedObjects as? [SOXManagedObject] else {
            return [SOXManagedObject]() }
        
        return fetchedObjects
    }
    
    
    func countOfFetchedObjects()
    -> Int {
        guard let countOfFetchedObjects = fetchedResultsController?.fetchedObjects?.count
        else { return 0 }
        return countOfFetchedObjects
    }
    
    
    func numberOfSections()
    -> Int {
        guard let sections = self.fetchedResultsController?.sections else {
            return 0 }
        
        let numbersOfSection = sections.count
        return numbersOfSection
    }
    
    
    func numberOfRowsInSection(_ sectionIndex: Int)
    -> Int {
        guard let sections = fetchedResultsController?.sections,
              sectionIndex <= sections.count else {
                  return 0 }
        
        let sectionInfo = sections[sectionIndex]
        let numberOfRowsInSection = sectionInfo.numberOfObjects
        return numberOfRowsInSection
    }
    
    
    //MARK: Configure Cells
    func configureCell(_ cell: SOXDatasourceManagerCell,
                       withData data: SOXManagedObject,
                       atIndexPath indexPath: IndexPath) {
        if  cell.cellIsReadyForReuse() == false
            && setupBlock != nil {
            setupBlock!(cell, data, indexPath)
        }
        
        if updateBlock != nil {
            updateBlock!(cell, data, indexPath)
        }
    }
    
    
    //MARK: Register Cells
    func registerCellReuseIdentifier(_ reuseIdentifier: String,
                                     setupBlock: SOXDataSourceManagerCellSetupBlock?,
                                     updateBlock: SOXDataSourceManagerCellSetupBlock?) {
        registerNib(named: nil,
                    forCellReuseIdentifier: reuseIdentifier,
                    setupBlock: setupBlock,
                    updateBlock: updateBlock)
    }
    
    func registerNib(named nibName: String,
                     forCellReuseIdentifier reuseIdentifier: String,
                     setupBlock: SOXDataSourceManagerCellSetupBlock?,
                     updateBlock: SOXDataSourceManagerCellSetupBlock?) {
        let nib = UINib.init(nibName: nibName, bundle: nil)
        
        registerNib(named: nib,
                    forCellReuseIdentifier: reuseIdentifier,
                    setupBlock: setupBlock,
                    updateBlock: updateBlock)
    }
    
    func registerNib(named nib: UINib?,
                     forCellReuseIdentifier reuseIdentifier: String,
                     setupBlock: SOXDataSourceManagerCellSetupBlock?,
                     updateBlock: SOXDataSourceManagerCellSetupBlock?) {
        
        if nib != nil {
            if let tableView: UITableView = view as? UITableView {
                tableView.register(nib, forCellReuseIdentifier:reuseIdentifier)
            }
            else if let collectionView: UICollectionView = view as? UICollectionView {
                collectionView.register(nib, forCellWithReuseIdentifier: reuseIdentifier)
            }
        }
        
        self.reuseIdentifier = reuseIdentifier
        self.setupBlock = setupBlock
        self.updateBlock = updateBlock
    }
    
    
    //MARK: Predicate
    
    /// Updates predicate of NSFetchedResultsController. Fetches afterwards.
    /// - Parameter predicate: The new predicate.
    func updatePredicate(_ predicate: NSPredicate?) {
        if cacheName != nil {
            NSFetchedResultsController<NSFetchRequestResult>.deleteCache(withName: cacheName)
        }
        
        fetchedResultsController?.fetchRequest.predicate = predicate
        
        performFetch()
    }


    //MARK: Fetch
    func performFetch() {
        do {
            try fetchedResultsController?.performFetch()
        } catch let error {
            print(error)
           // SOXAnalytics.trackError(named: "performFetch()", error: error as NSError)
        }
    }

}


// MARK: - Extension - SetupFetchedResultsController
extension SOXAbstractDatasourceFRC {
    
    func setupFetchedResultsController(withEntityForName entityName: String,
                                       sortedByAttribute sortKey: String?,
                                       sortAscending: Bool = true,
                                       sectionNameKeyPath: String? = nil,
                                       managedObjectContext: NSManagedObjectContext,
                                       fetchBatchSize: Int = 0,
                                       cacheName: String? = nil,
                                       delegate: SOXDatasourceManagerDelegate,
                                       predicateString: String,
                                       predicateArguments: [Any]) {
        
        let sortDescriptors = sortDescriptorsFor(sortedByAttribute: sortKey,
                                                 sortAscending: sortAscending)
        let predicate = predicateFor(predicateString: predicateString,
                                     predicateArguments: predicateArguments)
        
        setupFetchedResultsController(withEntityForName: entityName,
                                      sortDescriptors: sortDescriptors,
                                      sectionNameKeyPath: sectionNameKeyPath,
                                      managedObjectContext: managedObjectContext,
                                      fetchBatchSize: fetchBatchSize,
                                      cacheName: cacheName,
                                      delegate: delegate,
                                      predicate: predicate)
    }
    
    
    func setupFetchedResultsController(withEntityForName entityName: String,
                                       sortedByAttribute sortKey: String?,
                                       sortAscending: Bool = true,
                                       sectionNameKeyPath: String? = nil,
                                       managedObjectContext: NSManagedObjectContext,
                                       fetchBatchSize: Int = 0,
                                       cacheName: String? = nil,
                                       delegate: SOXDatasourceManagerDelegate,
                                       predicate: NSPredicate?) {

        let sortDescriptors = sortDescriptorsFor(sortedByAttribute: sortKey,
                                                 sortAscending: sortAscending)
        
        setupFetchedResultsController(withEntityForName: entityName,
                                      sortDescriptors: sortDescriptors,
                                      sectionNameKeyPath: sectionNameKeyPath,
                                      managedObjectContext: managedObjectContext,
                                      fetchBatchSize: fetchBatchSize,
                                      cacheName: cacheName,
                                      delegate: delegate,
                                      predicate: predicate)
    }
    
    
    func setupFetchedResultsController(withEntityForName entityName:String,
                                       sortDescriptors: [NSSortDescriptor],
                                       sectionNameKeyPath: String? = nil,
                                       managedObjectContext: NSManagedObjectContext,
                                       fetchBatchSize: Int = 0,
                                       cacheName: String? = nil,
                                       delegate: SOXDatasourceManagerDelegate,
                                       predicateString: String,
                                       predicateArguments: [Any]) {
        
        let predicate = predicateFor(predicateString: predicateString,
                                     predicateArguments: predicateArguments)
        
        setupFetchedResultsController(withEntityForName: entityName,
                                      sortDescriptors: sortDescriptors,
                                      sectionNameKeyPath: sectionNameKeyPath,
                                      managedObjectContext: managedObjectContext,
                                      fetchBatchSize: fetchBatchSize,
                                      cacheName: cacheName,
                                      delegate: delegate,
                                      predicate: predicate)
    }
    
    
    func setupFetchedResultsController(withEntityForName entityName:String,
                                       sortDescriptors: [NSSortDescriptor],
                                       sectionNameKeyPath: String? = nil,
                                       managedObjectContext: NSManagedObjectContext,
                                       fetchBatchSize: Int = 0,
                                       cacheName: String? = nil,
                                       delegate: SOXDatasourceManagerDelegate,
                                       predicate: NSPredicate?) {
        
        self.delegate = delegate
        
        // auto name
        if self.name == nil {
            self.name = "\(delegate.self) - \(entityName)"
        }
        
        self.context = managedObjectContext
        self.cacheName = cacheName
        
        guard let entityDescription = NSEntityDescription.entity(forEntityName: entityName,
                                                           in: managedObjectContext)
            else { fatalError() }

        let fetchRequest:NSFetchRequest<NSFetchRequestResult> = NSFetchRequest()
        fetchRequest.entity = entityDescription
        fetchRequest.fetchBatchSize = fetchBatchSize
        fetchRequest.predicate = predicate
        
        let comparatorDescriptors = check(sortDescriptors: sortDescriptors,
                                          entityDescription: entityDescription)
        fetchRequest.sortDescriptors = comparatorDescriptors
        
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest,
                                                              managedObjectContext: managedObjectContext,
                                                              sectionNameKeyPath: sectionNameKeyPath,
                                                              cacheName: cacheName)
        fetchedResultsController!.delegate = self
        
        performFetch()
    }
    
    
    
    
    func setupFor(entityWithName entityName: String,
                  sortDescriptors: [NSSortDescriptor]? = nil,
                  sortedByAttribute sortKey: String? = nil,
                  sortAscending: Bool = true,
                  sectionNameKeyPath: String? = nil,
                  managedObjectContext: NSManagedObjectContext,
                  fetchBatchSize: Int = 0,
                  cacheName: String? = nil,
                  delegate: SOXDatasourceManagerDelegate,
                  predicate: NSPredicate? = nil,
                  predicateString: String? = nil,
                  predicateArguments: [Any]? = nil ) {
        self.context = managedObjectContext
        self.delegate = delegate
        self.cacheName = cacheName
        self.name = cacheName ?? "\(delegate.self) - \(entityName)"
        
        // Setup Fetch Request
        guard let entityDescription = NSEntityDescription.entity(forEntityName: entityName,
                                                                 in: managedObjectContext) else {
            fatalError("NSEntityDescription failed for \(entityName) in \(managedObjectContext.name ?? "no context name")") }
        
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest()
        fetchRequest.entity = entityDescription
        fetchRequest.fetchBatchSize = fetchBatchSize
        fetchRequest.predicate = predicate
        
        // SortDescriptor handling
        var sortKeyDescriptors = sortDescriptorsFor(sortedByAttribute: sortKey, sortAscending: sortAscending)
        if let sortDescriptors = sortDescriptors {
            sortKeyDescriptors.append(contentsOf: sortDescriptors)
        }
        let comparatorDescriptors = check(sortDescriptors: sortKeyDescriptors,
                                          entityDescription: entityDescription)
        fetchRequest.sortDescriptors = comparatorDescriptors
        
        // Setup FetchedResultsController
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest,
                                                              managedObjectContext: managedObjectContext,
                                                              sectionNameKeyPath: sectionNameKeyPath,
                                                              cacheName: cacheName)
        fetchedResultsController!.delegate = self
        
        performFetch()
    }
    
}


//MARK: - Private Extension - Helper Methods
private extension SOXAbstractDatasourceFRC {
    
    //MARK: Sort Descriptor handling
    private func sortDescriptorsFor(sortedByAttribute sortKey: String?,
                                    sortAscending: Bool = true)
    -> [NSSortDescriptor] {

        guard let sortKey = sortKey else {
            return [NSSortDescriptor]()
        }

        let sortDescriptor = NSSortDescriptor.init(key: sortKey,
                                                   ascending: sortAscending)
        return [sortDescriptor]
    }

    
    private func check(sortDescriptors: [NSSortDescriptor],
                       entityDescription: NSEntityDescription)
    -> [NSSortDescriptor] {
        guard sortDescriptors.count > 0 else {
            return [NSSortDescriptor]() }
        
        var checkedSortDescriptors: [NSSortDescriptor] = []
        
        for sortDescriptor in sortDescriptors {
            
            guard let sortKey = sortDescriptor.key,
                  let attributeDescription = entityDescription.attributesByName[sortKey]
                else { fatalError() }
            
            let attributeType = attributeDescription.attributeType
            if attributeType == NSAttributeType.stringAttributeType,
               let selector = sortDescriptor.selector,
               selector == #selector(NSString.compare(_:)) {
                let stringSortDescriptor =
                    NSSortDescriptor.init(key: sortKey,
                                          ascending: sortDescriptor.ascending,
                                          selector: #selector(NSString.localizedStandardCompare(_:)))
                checkedSortDescriptors.append(stringSortDescriptor)
            }
            else {
                checkedSortDescriptors.append(sortDescriptor)
            }
        }
        
        return checkedSortDescriptors
    }
    
    
    //MARK: Predicate handling
    private func predicateFor(predicateString: String,
                              predicateArguments: [Any])
    -> NSPredicate {
        let predicate = NSPredicate.init(format: predicateString,
                                         argumentArray: predicateArguments)
        return predicate
    }
    
}
