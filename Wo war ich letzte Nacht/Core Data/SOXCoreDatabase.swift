//
//  SOXCoreDatabase.swift
//  2sox
//
//  Created by Peter Hauke on 13.06.19.
//  Copyright © 2019 2sox. All rights reserved.
//

import Foundation
import CoreData


// MARK: - SOXCoreDatabase
class SOXCoreDatabase {
    
    //MARK: Public Lets and Vars
    private(set) static var isAlive: Bool = false
    
    // MARK: Private Lets and Vars
    private static let shared = SOXCoreDatabase()
    //MARK: - Database Setup Stuff
    private static let managedObjectModelName = "Wo_war_ich_letzte_Nacht"
    
    private var managedObjectModelName: String?
    private var persistentContainer: NSPersistentContainer? {
        didSet {
            SOXCoreDatabase.isAlive = persistentContainer != nil
        }
    }
    
    private lazy var managedObjectModel:NSManagedObjectModel = {
        guard let managedObjectModelName = managedObjectModelName
        else { fatalError("managedObjectModelName is nil") }
        
        guard let modelPath = Bundle.main.path(forResource: managedObjectModelName,
                                               ofType: "momd")
        else { fatalError("No model file in bundle") }
        
        let modelURL = URL.init(fileURLWithPath:modelPath)
        guard let managedObjectModel = NSManagedObjectModel.init(contentsOf: modelURL)
        else { fatalError("No NSManagedObjectModel") }
        
        return managedObjectModel
    }()
    
    
    // MARK: Public Methods
    class func startUp() {
        
        setupPersistentContainer(atDirectory: SOXFileManager.documentDirectoryURL(),
                                 persistentContainerName: managedObjectModelName,
                                 managedObjectModelName: managedObjectModelName)
    }
    class func setupPersistentContainer(atDirectory persistentDirectory: URL,
                                        persistentContainerName: String,
                                        managedObjectModelName: String)  {
        shared.managedObjectModelName = managedObjectModelName
        shared.persistentContainer = shared.persistentContainer(atDirectory: persistentDirectory,
                                                                persistentContainerName: persistentContainerName)
    }
    
    
    class func pulldownDatabase() {
        shared.persistentContainer = nil
    }
    
    
    // MARK: Private Methods
    private func persistentContainer(atDirectory directoryURL: URL,
                                     persistentContainerName: String)
    -> NSPersistentContainer? {
        // Register Secure Transformer Classes
        //SOXSecureUnarchiveFromDataTransformer.register()
        
        var storeURL = directoryURL.appendingPathComponent(directoryURL.lastPathComponent)
        storeURL = storeURL.appendingPathExtension("sqlite")

       
        let persistentStoreDescription = NSPersistentStoreDescription(url: storeURL)
        persistentStoreDescription.shouldMigrateStoreAutomatically = true
        persistentStoreDescription.shouldInferMappingModelAutomatically = true
        
        let persistentContainer = NSPersistentContainer(name: persistentContainerName,
                                                        managedObjectModel: managedObjectModel)

//        let oldModelVersion = versionIdentifierForPersistentStore(at: storeURL)
//        let newModelVersion = versionIdentifierForModel(managedObjectModel)
//        SOXAnalytics.trackEvent(named: "Going to load persistentStore",
//                                properties: [ "oldModelVersion": oldModelVersion ?? "<unknown>",
//                                              "newModelVersion" : newModelVersion ?? "<unknown>"])
        
        persistentContainer.persistentStoreDescriptions = [persistentStoreDescription]
        persistentContainer.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                
                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
               

//                SOXAnalytics.trackError(named: "ERROR loadPersistentStores", error: error)
              
                fatalError()
            }
        })
        
        persistentContainer.viewContext.name = "PersistentContainer Main Context (viewOnlyContext)"
        persistentContainer.viewContext.automaticallyMergesChangesFromParent = true
        self.persistentContainer = persistentContainer
        
        
        // Handle manually migration, if needed - workaround for migrationPolicy issues; 21092022, ph
//        var manuallyMigrationHappend = false
//        var manuallyMigrationHappendSuccessfully = false
//        if let oldModelVersion, let newModelVersion,
//           let oldVersion = Double(string: oldModelVersion),
//           let newVersion = Double(string: newModelVersion) {
//            manuallyMigrationHappend = true
//
//            if oldVersion < newVersion {
//                let success = ManualMigrations.migrate(from: oldVersion, to: newVersion)
//                manuallyMigrationHappendSuccessfully = success
//            }
//        }
//
//        if manuallyMigrationHappend {
//            if manuallyMigrationHappendSuccessfully {
//                SOXErrorManager.presentError(title: "Die Datenbank wurde erfolgreich migriert.",
//                                             message: "Um alle neuen Funktionen nutzen zu können, müssen Sie Landrix Handwerk Mobile mit dem Server neu synchronisieren.")
//            }
//        }
        // --- END
        
        return persistentContainer
    }
    
    
    private func versionIdentifierForPersistentStore(at storeURL: URL)
    -> String? {
        do {
            let metadata = try NSPersistentStoreCoordinator.metadataForPersistentStore(ofType: "sqlite",
                                                                                       at: storeURL,
                                                                                       options: nil)
            let storeModelVersionIdentifiers = metadata["NSStoreModelVersionIdentifiers"] as? Array<Any>
            let versionIdentifier = storeModelVersionIdentifiers?.first as? String
            return versionIdentifier
        }
        catch {
            return nil
        }
    }
    
    
    private func versionIdentifierForModel(_ model: NSManagedObjectModel)
    -> String? {
        let modelVersionIdentifiers = model.versionIdentifiers
        let versionIdentifier = modelVersionIdentifiers.first as? String
        return versionIdentifier
    }
    
}


// MARK: - Extension - Convenient Contexts Methods
extension SOXCoreDatabase {
    
    /**
     The managed object context associated with the persistentContainer on main queue.
     
     - Returns: The context.
     */
    class func viewOnlyContext()
    -> NSManagedObjectContext {
        guard let persistentContainer = shared.persistentContainer
        else { fatalError("viewOnlyContext(): No valid persistentContainer") }
        
        let viewOnlyContext = persistentContainer.viewContext
        return viewOnlyContext
    }
    
    
    /**
     Creates a new context for editing:
     
     - Parameter forUI: `true` for concurrencyType: `.mainQueueConcurrencyType` || `false` for concurrencyType: `.privateQueueConcurrencyType`
     
     - Returns: The new context.
     */
    class func newEditContext(forUI isContextForUI:Bool)
    -> NSManagedObjectContext {
     
        var newEditContext:NSManagedObjectContext
        
        let persistentStoreCoordinator = viewOnlyContext().persistentStoreCoordinator
        let newPersistingContext = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        newPersistingContext.persistentStoreCoordinator = persistentStoreCoordinator
        newPersistingContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        
        if isContextForUI == true {
            newPersistingContext.name = "Persisting Context"
            newEditContext = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
            newEditContext.name = "Edit Context on Main Queue";
            newEditContext.parent = newPersistingContext;
        }
        else {
            newEditContext = newPersistingContext
            newEditContext.name = "Edit Context on Private Queue"
        }
        
        return newEditContext
    }
    
    
    class func newBackgroundTaskContext()
    -> NSManagedObjectContext {
        
        // Create a private queue context.
        guard let taskContext = shared.persistentContainer?.newBackgroundContext()
        else { fatalError() }
        
        taskContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        
        // Set unused undoManager to nil for macOS (it is nil by default on iOS)
        // to reduce resource requirements.
        taskContext.undoManager = nil
        
        taskContext.name = "newBackgroundTaskContext"
        return taskContext
    }
    
}


//MARK: - Extension - Convenient Fetch Methods
extension SOXCoreDatabase {
    
    
    /// Fetch Objects in **viewOnlyContext**
    ///   - Use `ManagedObjectContext` implementation to fetch objects on a seperate context.
    /// - Parameters:
    ///   - entityClass: Managed Object Type
    ///   - sortDescriptors: Array of sort descriptors
    ///   - sortKeyPath: KeyPath to sort ascending
    ///   - sortKeyPaths: Array of keyPaths to sort ascending
    ///   - reverseSortKeypath: KeyPath to sort descending
    ///   - predicate: Predicate
    ///   - predicateString: Predicate String
    ///   - predicateArguments: Arguments used for Predicate String
    ///   - returnsObjectsAsFaults: Returns objects as fault (**default is** `false` )
    ///
    /// - Returns:
    ///   - Array of fetched objects.
    class func fetchObjects <T: SOXManagedObject>(forEntityClass entityClass:T.Type,
                                                  sortDescriptors: [NSSortDescriptor]? = nil,
                                                  sortByKeypath sortKeyPath: String? = nil,
                                                  sortByKeypaths sortKeyPaths: [String]? = nil,
                                                  reverseSortByKeypath reverseSortKeypath: String? = nil,
                                                  predicate: NSPredicate? = nil,
                                                  predicateString: String? = nil,
                                                  predicateArguments: [Any]? = nil,
                                                  returnsObjectsAsFaults: Bool = false)
    -> [T] {
        let fetchedObjects = viewOnlyContext().fetchObjects(forEntityClass: entityClass,
                                                            sortDescriptors: sortDescriptors,
                                                            sortByKeypath: sortKeyPath,
                                                            sortByKeypaths: sortKeyPaths,
                                                            reverseSortByKeypath: reverseSortKeypath,
                                                            predicate: predicate,
                                                            predicateString: predicateString,
                                                            predicateArguments: predicateArguments,
                                                            returnsObjectsAsFaults: returnsObjectsAsFaults)
        return fetchedObjects
    }
    
    
    
    /// Get count of fetched objects in **viewOnlyContext**.
    /// - Use `ManagedObjectContext` implementation to get count on seperate context.
    /// - Parameters:
    ///   - entityClass: Managed Object Type
    ///   - predicate: Predicate
    ///   - predicateString: Predicate String
    ///   - predicateArguments: Arguments used for Predicate String
    ///
    /// - Warning:
    ///   - Implementation uses given `predicate` before `predicateString/Arguments`
    class func countOfObjects <T: SOXManagedObject>(forEntityClass entityClass:T.Type,
                                                    predicate: NSPredicate? = nil,
                                                    predicateString: String? = nil,
                                                    predicateArguments: [Any]? = nil)
    -> Int {
        let count = viewOnlyContext().countOfObjects(forEntityClass: entityClass,
                                                     predicate: predicate,
                                                     predicateString: predicateString,
                                                     predicateArguments: predicateArguments)
        return count
    }
    
}


//MARK: - Extension - Perform and Save in Contexts
extension SOXCoreDatabase {
    
    //TODO: Make Blocks escapeable; 10.2.20, ph
    // https://stackoverflow.com/questions/38296910/how-to-return-value-from-a-closure-in-swift
    typealias WorkingBlock = (_ context: NSManagedObjectContext) -> ()
    typealias CompletionBlock = () -> ()
    

    class func performOnViewOnlyContext(workingBlock: WorkingBlock,
                                        completionBlock: CompletionBlock? = nil) {
        performAndSave(onContext: viewOnlyContext(),
                       workingBlock: workingBlock,
                       completionBlock: completionBlock)
    }
    
    
    class func performAndSaveInUIEditContext(workingBlock: WorkingBlock,
                                             completionBlock: CompletionBlock? = nil) {
        performAndSave(onContext: newEditContext(forUI: true),
                       workingBlock: workingBlock,
                       completionBlock: completionBlock)
    }
    
    
    class func performAndSaveInBackgroundEditContext(workingBlock: WorkingBlock,
                                                     completionBlock: CompletionBlock? = nil) {
        performAndSave(onContext: newEditContext(forUI: false),
                       workingBlock: workingBlock,
                       completionBlock: completionBlock)
    }
    
    
    class func performAndSaveInBackgroundTaskContext(workingBlock: WorkingBlock,
                                                     completionBlock: CompletionBlock? = nil) {
        performAndSave(onContext: SOXCoreDatabase.newBackgroundTaskContext(),
                       workingBlock: workingBlock,
                       completionBlock: completionBlock)
    }
    
    
    /**
     Perform work on given context, save and execute completion block.
     
     Uses context.performAndWait.
     
     - Parameter workingBlock: Block working on context.
     - Parameter context: The given context.
     - Parameter completionBlock: Block exectued after saveContext().
     */
    class func performAndSave(onContext context: NSManagedObjectContext,
                              workingBlock: WorkingBlock,
                              completionBlock: CompletionBlock? = nil) {
        context.performAndWait {
            workingBlock(context)
            context.saveContext()
        }
        
        if completionBlock != nil {
            completionBlock!()
        }
    }
    
}


//MARK: - Extension - Helper Methods
extension SOXCoreDatabase {
    
    //MARK: Public Class Methods
    class func entity(named entityName: String,
                      containsAttribute attribute: String,
                      inContext context: NSManagedObjectContext = SOXCoreDatabase.viewOnlyContext())
    -> Bool {
        guard let entityDescription = NSEntityDescription.entity(forEntityName: entityName,
                                                                 in: context) else {
            return false }
        
        let containsAttribute = entityDescription.attributesByName.keys.contains(attribute)
        return containsAttribute
    }
    
    
    class func entityNames()
    -> [String] {
        let enNames = shared.entityNames()
        return enNames
    }
    
    
    //MARK: Private Instance Methods
    private func entityNames()
    -> [String] {
        let entitiesByName = managedObjectModel.entitiesByName
        let allKeys = entitiesByName.keys as Dictionary<String, NSEntityDescription>.Keys // Swift fuck up! 13.11.19; ph
        
        let entityNames = Array.init(allKeys)
        return entityNames
    }
  
}


extension SOXCoreDatabase {
    
    class func databaseFile(directoryURL: URL)
    -> Data? {
        
        var storeURL = directoryURL.appendingPathComponent(directoryURL.lastPathComponent)
        storeURL = storeURL.appendingPathExtension("sqlite")
        
        let databaseFile = FileManager.default.contents(atPath: storeURL.path)
        return databaseFile
    }
    
}
