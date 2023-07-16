//
//  NSManagedObjectContext+Perform.swift
//  Landrix Handwerk Mobile
//
//  Created by Peter Hauke on 30.12.20.
//  Copyright © 2020 Landrix Software GmbH & Co. KG. All rights reserved.
//

import UIKit

import CoreData

//MARK: - Extension - Perform with blocks
extension NSManagedObjectContext {
    
    //MARK: - Typealiases
    typealias WorkingBlock = (_ context: NSManagedObjectContext) -> ()
    typealias WorkingBlockWithResult = (_ context: NSManagedObjectContext) -> (WorkingBlockResult)
    typealias CompletionBlock = () -> ()
    
    
    //MARK: - Public Methods
    func performAndSave(_ workingBlock: @escaping WorkingBlock,
                        completionBlock: CompletionBlock? = nil) {
        perform { [weak self] in
            guard let strongSelf = self else {
                return }
            workingBlock(strongSelf)
            strongSelf.saveContext()
        }
        
        if completionBlock != nil {
            completionBlock!()
        }
        
    }
    
    
    func performAndWaitAndSave(_ workingBlock: WorkingBlock,
                               completionBlock: CompletionBlock? = nil) {
        performAndWait { [weak self] in
            guard let strongSelf = self else {
                return }
            workingBlock(strongSelf)
            strongSelf.saveContext()
        }
        
        completionBlock?()
    }
    
   
    /// Performs given `workingBlock` on the receiver context. Merges changes into the `mergeTargetContexts` afterwards.
    ///
    /// - Warning: **Saves** neither the receiver context nor the `mergeTargetContexts`.
    ///
    /// * Sets `automaticallyMergesChangesFromParent` on `mergeTargetContexts` to `false` and restores
    /// its former setting after the `workingBlock`, the merge into the `mergeTargetContexts`
    /// and the `completionBlock`.
    /// * `CompletionBlock` is executed after merges into `mergeTargetContexts`.
    ///
    /// - Parameters:
    ///   - mergeTargetContexts: Array of `contexts` to merge changes made in `workingBlock` into.
    ///   - workingBlock: The `workingBlock`.
    ///   - completionBlock: The `completionBlock`.
    func performAndWaitAndMerge(toTargetContexts mergeTargetContexts: [NSManagedObjectContext],
                                workingBlock: WorkingBlockWithResult,
                                completionBlock: CompletionBlock? = nil) {
        
        // Disabled automaticallyMergesChangesFromParent on merge target contexts.
        var contextsWithAutomaticallyMerge: Set<NSManagedObjectContext> = []
        mergeTargetContexts.forEach { context in
            if context.automaticallyMergesChangesFromParent == true {
                context.automaticallyMergesChangesFromParent = false
                contextsWithAutomaticallyMerge.update(with: context)
            }
        }
        
        // WorkingBlock
        performAndWait {
            let workingBlockResult = workingBlock(self)
            
            // update target contexts
            let changeNotificationData = workingBlockResult.changeNotificationData
            NSManagedObjectContext.mergeChanges(fromRemoteContextSave: changeNotificationData,
                                                into: mergeTargetContexts)
        }
        
        // CompletionBlock
        completionBlock?()
        
        // Enabled automaticallyMergesChangesFromParent on merge target contexts, if needed.
        contextsWithAutomaticallyMerge.forEach { $0.automaticallyMergesChangesFromParent = true }
    }
    
    
    //MARK: -
    struct WorkingBlockResult {
        var insertedObjectIDs: [NSManagedObjectID] = []
        var updatedObjectsIDs: [NSManagedObjectID] = []
        var deletedObjectsIDs: [NSManagedObjectID] = []
        
        var changeNotificationData: [AnyHashable : Any] {
            [NSInsertedObjectsKey: insertedObjectIDs,
             NSUpdatedObjectsKey: updatedObjectsIDs,
             NSDeletedObjectsKey: deletedObjectsIDs]
        }
    }
    
    
    
}
