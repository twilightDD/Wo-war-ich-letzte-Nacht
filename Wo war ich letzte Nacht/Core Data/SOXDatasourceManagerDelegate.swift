//
//  SOXDatasourceManagerDelegate.swift
//  Landrix Handwerk Mobile
//
//  Created by Peter Hauke on 13.07.19.
//  Copyright © 2019 Landrix Software GmbH & Co. KG. All rights reserved.
//

import Foundation
import CoreData
import UIKit

// MARK: - Protocol
protocol SOXDatasourceManagerDelegate: AnyObject {
    
    func insertedIndexPath(_ indexPath:IndexPath)
    func insertedIndexPaths(_ indexPaths:[IndexPath])
    func insertedIndexPaths(_ indexPaths:[IndexPath],forDatasourceManager datasourceManager:SOXAbstractDatasourceFRC)
    
    func updatedIndexPath(_ indexPath:IndexPath)
    func updatedIndexPaths(_ indexPaths:[IndexPath])
    func updatedIndexPaths(_ indexPaths:[IndexPath],forDatasourceManager datasourceManager:SOXAbstractDatasourceFRC)
    
    func deletedIndexPath(_ indexPath:IndexPath)
    func deletedIndexPaths(_ indexPaths:[IndexPath])
    func deletedIndexPaths(_ indexPaths:[IndexPath],forDatasourceManager datasourceManager:SOXAbstractDatasourceFRC)
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>)
    func controllerDidChangeContent(_ datasourceManager: SOXAbstractDatasourceFRC)
    
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String?
    func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String?
    
    
    func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration?
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration?
}


// MARK: - Protocol stubs
extension SOXDatasourceManagerDelegate {
    
    func insertedIndexPath(_ indexPath:IndexPath) {}
    func insertedIndexPaths(_ indexPaths:[IndexPath]) {}
    func insertedIndexPaths(_ indexPaths:[IndexPath], forDatasourceManager datasourceManager:SOXAbstractDatasourceFRC) {}
    
    func updatedIndexPath(_ indexPath:IndexPath) {}
    func updatedIndexPaths(_ indexPaths:[IndexPath]) {}
    func updatedIndexPaths(_ indexPaths:[IndexPath], forDatasourceManager datasourceManager:SOXAbstractDatasourceFRC) {}
    
    func deletedIndexPath(_ indexPath:IndexPath) {}
    func deletedIndexPaths(_ indexPaths:[IndexPath]) {}
    func deletedIndexPaths(_ indexPaths:[IndexPath], forDatasourceManager datasourceManager:SOXAbstractDatasourceFRC) {}
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {}
    func controllerDidChangeContent(_ datasourceManager: SOXAbstractDatasourceFRC) {}
    
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return nil }
    func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        return nil }
    
    func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        return nil }
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        return nil }
    
}
