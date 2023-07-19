//
//  SOXDatasourceManagerCellProtocol.swift
//  SwiftDemoFRC
//
//  Created by Peter Hauke on 08.05.19.
//  Copyright © 2019 Peter Hauke. All rights reserved.
//


import CoreData

// MARK: - Typealias
typealias SOXDataSourceManagerCellSetupBlock = (_ cell: SOXDatasourceManagerCell, _ data: SOXManagedObject, _ indexPath: IndexPath) -> Void

typealias SOXDataSourceManagerHeaderFooterSetupBlock = (_ headerView: SOXDatasourceManagerCell, _ indexPath: IndexPath) -> Void

protocol SOXDatasourceManagerCell:Any {
    
    func cellIsReadyForReuse () -> Bool
    
}
