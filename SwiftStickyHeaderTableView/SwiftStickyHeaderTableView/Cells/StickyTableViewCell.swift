//
//  StickyTableViewCell.swift
//  SwiftStickyHeaderTableView
//
//  Created by Jacky Tay on 29/05/18.
//  Copyright © 2018 JackyTay. All rights reserved.
//

import UIKit

class StickyTableViewCell: UITableViewCell {

    weak var delegate: StickyTableViewControllerDelegate?
    var indexPath: IndexPath!

    func update(indexPath: IndexPath, and delegate: StickyTableViewControllerDelegate) {
        self.indexPath = indexPath
        self.delegate = delegate
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        delegate?.layoutSubviewDidFinish(for: indexPath)
    }
}
