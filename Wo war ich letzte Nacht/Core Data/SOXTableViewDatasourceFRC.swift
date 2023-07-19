//
//  SOXTableViewDatasourceFRC.swift
//  SwiftDemoFRC
//
//  Created by Peter Hauke on 08.05.19.
//  Copyright © 2019 Peter Hauke. All rights reserved.
//

import UIKit
import CoreData

// MARK: - IORDatasourceIndexPathMove
 class SOXDatasourceIndexPathMove: NSObject {
    
    // MARK: Public Properties
    let sourceIndexPath: IndexPath
    let destinationIndexPath: IndexPath
    
    init(fromIndexPath: IndexPath, toIndexPath: IndexPath) {
        self.sourceIndexPath = fromIndexPath
        self.destinationIndexPath = toIndexPath
    }
    
}

// MARK: - 
// MARK: - IORTableViewDatasourceFRC
class SOXTableViewDatasourceFRC: SOXAbstractDatasourceFRC, UITableViewDataSource {

    
    
    // MARK: Public Properties
    var sectionDeletionAnimation:UITableView.RowAnimation = .fade
    var sectionInsertionAnimation:UITableView.RowAnimation = .fade
    var rowInsertionAnimation:UITableView.RowAnimation = .fade
    var rowDeletionAnimation:UITableView.RowAnimation = .fade
    var rowUpdateAnimation:UITableView.RowAnimation = .fade
    
    var showSectionIndex:Bool = false
    var sectionIndexLength:Int8 = 1
    var sectionIndexUsesUppercase:Bool = true
    
    // MARK: Private Properties
    private var insertedIndexPath:IndexPath = IndexPath()
    private var deletedIndexPath:IndexPath = IndexPath()
    private var updatedIndexPath:IndexPath = IndexPath()
    
    private var insertedIndexPaths:Array = [IndexPath]()
    private var deletedIndexPaths:Array = [IndexPath]()
    private var updatedIndexPaths:Array = [IndexPath]()
    private var movedIndexPaths:Array = [SOXDatasourceIndexPathMove]()
    
    private var deletedSectionIndexes:IndexSet = IndexSet()
    private var insertedSectionIndexes:IndexSet = IndexSet()
    
    // MARK: - Public Class Methods
    class func managerFor(tableView:UITableView, tableViewDelegate:UITableViewDelegate) -> SOXTableViewDatasourceFRC {
        let manager = SOXTableViewDatasourceFRC()
        manager.view = tableView
        tableView.dataSource = manager
        tableView.delegate = tableViewDelegate
        
        return manager
    }
    
    class func managerAsWatchdog()
        -> SOXTableViewDatasourceFRC {
            let manager = SOXTableViewDatasourceFRC()
            manager.supressViewUpdates = true

            return manager
    }
}
    
// MARK: - Extenstion UITableViewDataSource
extension SOXTableViewDatasourceFRC {
    
    func numberOfSections(in tableView: UITableView)
    -> Int {
        return numberOfSections()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int)
    -> Int {
        return numberOfRowsInSection(section)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath)
        -> UITableViewCell {
            let cell:UITableViewCell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath)
            
            guard let datasourceManagerCell = cell as? SOXDatasourceManagerCell  else {
                fatalError("no datasourceManagerCell") }
            
            let data: SOXManagedObject = dataFor(IndexPath: indexPath)
            
            if configureCellsSynchronously {
                configureCell(datasourceManagerCell, withData: data, atIndexPath: indexPath)
            }
            else {
                DispatchQueue.main.async { [weak self] in
                    self?.configureCell(datasourceManagerCell, withData: data, atIndexPath: indexPath)
                }
            }
            
            guard let cellForRowAtIndexPath = datasourceManagerCell as? UITableViewCell else {
                fatalError() }
            
            return cellForRowAtIndexPath
    }
    
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int)
    -> String? {
        let headerTitle = delegate?.tableView(tableView, titleForHeaderInSection: section)
        return headerTitle
    }
    
    
    func tableView(_ tableView: UITableView, titleForFooterInSection section: Int)
    -> String? {
        let footerTitle = delegate?.tableView(tableView, titleForFooterInSection: section)
        return footerTitle
    }
    
    
    func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath)
    -> UISwipeActionsConfiguration? {
        let leadingSwipeActionsConfiguration = delegate?.tableView(tableView, leadingSwipeActionsConfigurationForRowAt: indexPath)
        return leadingSwipeActionsConfiguration
    }
    
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath)
    -> UISwipeActionsConfiguration? {
        let trailingSwipeActionsConfiguration = delegate?.tableView(tableView, trailingSwipeActionsConfigurationForRowAt: indexPath)
        return trailingSwipeActionsConfiguration
    }
    
}


    // MARK: - NSFetchedResultsControllerDelegate
extension SOXTableViewDatasourceFRC {
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {

        /*
         // so all animations (incl. i.e. flash orderPositionCell will be in correct order)
         // see controllerDidChangeContent()
        if supressViewUpdates == false {
            CATransaction.begin()
        }
         */
        
        // reset all index path caches
        insertedIndexPath = IndexPath()
        deletedIndexPath = IndexPath()
        updatedIndexPath = IndexPath()
        
        insertedIndexPaths = [IndexPath]()
        deletedIndexPaths = [IndexPath]()
        updatedIndexPaths = [IndexPath]()
        movedIndexPaths = [SOXDatasourceIndexPathMove]()
        
        deletedSectionIndexes = IndexSet()
        insertedSectionIndexes = IndexSet()
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>,
                    didChange sectionInfo: NSFetchedResultsSectionInfo,
                    atSectionIndex sectionIndex: Int,
                    for type: NSFetchedResultsChangeType) {
        switch type {
        case .insert:
            insertedSectionIndexes.insert(sectionIndex)
            break
        case .delete:
            deletedSectionIndexes.insert(sectionIndex)
            break
        default:
             assert(false, "Unknown NSFetchedResultsChangeType: \(type)")
            break
        }
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>,
                    didChange anObject: Any,
                    at indexPath: IndexPath?,
                    for type: NSFetchedResultsChangeType,
                    newIndexPath: IndexPath?) {

        switch type {
        case .insert:
            insertedIndexPath = newIndexPath!
            insertedIndexPaths.append(newIndexPath!)
            break
        case.delete:
            if deletedSectionIndexes.contains(indexPath!.section) {
                break
            }
            deletedIndexPath = indexPath!
            deletedIndexPaths.append(indexPath!)
            break
        case .update:
            // if newIndexPath is different than indexPath, it's because something in front of it was deleted at the same time
            // if the deleted row was directly before the updated one, an error is reported about deleting and updating the same indexpath
            // (because newIndexPath points to the one that is being deleted)
            // solution: use indexPath instead
            /*
             if ([delegate respondsToSelector:@selector(shouldUpdateRowAtIndexPath:)]) {
                if (![delegate shouldUpdateRowAtIndexPath:indexPath]) {
                    break;
                }
             }
             */
            updatedIndexPath = indexPath!
            updatedIndexPaths.append(indexPath!)
            break
        case .move:
            let indexPathMove = SOXDatasourceIndexPathMove.init(fromIndexPath: indexPath!,
                                                                toIndexPath: newIndexPath!)
            movedIndexPaths.append(indexPathMove)
            break
            
        default:
            assert(false, "Unknown NSFetchedResultsChangeType: \(type)")
            break
        }
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {

        // Fast path if there are no changes
        if insertedIndexPaths.count +
            deletedIndexPath.count +
            updatedIndexPaths.count +
            insertedSectionIndexes.count +
            deletedSectionIndexes.count +
            updatedIndexPaths.count +
            movedIndexPaths.count
            == 0 {
            delegate?.controllerDidChangeContent(controller)
            return
        }
    
        // MARK: Update tableView
        if supressViewUpdates == false {
            if let tableView = view as? UITableView{
            
                tableView.beginUpdates()
                
                // Sections
                if deletedSectionIndexes.count > 0 {
                    tableView.deleteSections(deletedSectionIndexes, with: sectionDeletionAnimation)
                }
                if insertedSectionIndexes.count > 0 {
                    tableView.insertSections(insertedSectionIndexes, with: sectionInsertionAnimation)
                }
                
                // Rows
                if updatedIndexPaths.count > 0 {
                    tableView.reloadRows(at: updatedIndexPaths, with: rowUpdateAnimation)
                }
                
                for moveIndexPath in movedIndexPaths {
                    tableView.moveRow(at: moveIndexPath.sourceIndexPath, to: moveIndexPath.destinationIndexPath)
                }
                
                if deletedIndexPaths.count > 0 {
                    tableView.deleteRows(at: deletedIndexPaths, with: rowDeletionAnimation)
                }
                
                if insertedIndexPaths.count > 0 {
                    tableView.insertRows(at: insertedIndexPaths, with: rowInsertionAnimation)
                }
                
                tableView.endUpdates()
                
                /*
                // so all animations (incl. i.e. flash orderPositionCell will be in correct order)
                // see controllerWillChangeContent()
                CATransaction.commit()
                 */
            }
        }
        
        // MARK: Inform delegate about inserts, updates, deletions and controller change
        guard let delegate = delegate
            else { return }
        
        if insertedIndexPaths.count > 0 {
            delegate.insertedIndexPath(insertedIndexPath)
            delegate.insertedIndexPaths(insertedIndexPaths)
            delegate.insertedIndexPaths(insertedIndexPaths, forDatasourceManager: self)
        }
        
        if updatedIndexPaths.count > 0 {
            delegate.updatedIndexPath(updatedIndexPath)
            delegate.updatedIndexPaths(updatedIndexPaths)
            delegate.updatedIndexPaths(updatedIndexPaths, forDatasourceManager: self)
        }
        
        if deletedIndexPaths.count > 0 {
            delegate.deletedIndexPath(deletedIndexPath)
            delegate.deletedIndexPaths(deletedIndexPaths)
            delegate.deletedIndexPaths(deletedIndexPaths, forDatasourceManager: self)
        }
        
        delegate.controllerDidChangeContent(controller)
        delegate.controllerDidChangeContent(self)
    }
}
