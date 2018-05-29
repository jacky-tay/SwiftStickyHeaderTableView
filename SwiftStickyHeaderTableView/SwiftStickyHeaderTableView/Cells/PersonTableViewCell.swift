//
//  PersonTableViewCell.swift
//  SwiftStickyHeaderTableView
//
//  Created by Jacky Tay on 28/05/18.
//  Copyright © 2018 JackyTay. All rights reserved.
//

import UIKit

class PersonTableViewCell: StickyTableViewCell {

    @IBOutlet weak var icon: UIImageView!
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var detail: UILabel!

    func bind(data: PersonRow) {
        icon.image = UIImage(named: data.person)
        title.text = data.title
        detail.text = data.detail
    }
}
