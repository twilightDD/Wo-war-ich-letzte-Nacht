//
//  SOXTableViewCell.swift
//  SwiftDemoFRC
//
//  Created by Peter Hauke on 08.05.19.
//  Copyright © 2019 Peter Hauke. All rights reserved.
//

import UIKit
typealias SOXTableViewCell = SOXTableViewAbstractCell & SOXDatasourceManagerCell

class SOXTableViewAbstractCell: UITableViewCell  {
    
    // MARK: Public Properties
    static let rowHeight: CGFloat = UITableView.automaticDimension
    static let estimatedRowHeight: CGFloat = 44
    
    // MARK: Private Properties
    private var setupDone: Bool = false
    

    //MARK: - Public class methods
    class func nibName() -> String {
        let typeString:String = String(describing: self)
        return typeString
    }
    
    class func nib() -> UINib {
        let nib = UINib.init(nibName: nibName(), bundle: nil)
        return nib
    }
    
    class func reuseIdentifier() -> String {
        let cellNibName = nibName() + "Identifier"
        return cellNibName
    }


    // MARK: - UITableViewCell Methods
    override func prepareForReuse() {
        super.prepareForReuse()
        self.setupDone = true
    }
    

    //MARK: - SOXDatasourceManagerCell

    func cellIsReadyForReuse() -> Bool {
        return self.setupDone
    }

}
