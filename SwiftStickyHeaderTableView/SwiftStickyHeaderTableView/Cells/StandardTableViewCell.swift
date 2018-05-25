//
//  StandardTableViewCell.swift
//  SwiftStickyHeaderTableView
//
//  Created by Jacky Tay on 25/05/18.
//  Copyright © 2018 JackyTay. All rights reserved.
//

import UIKit

class StandardTableViewCell: UITableViewCell {

    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var detail: UILabel!

    func bind(data: StandardRow) {
        title.text = data.title
        detail.text = data.detail
    }
}
