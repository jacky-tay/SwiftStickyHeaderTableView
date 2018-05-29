//
//  VehicleTableViewCell.swift
//  SwiftStickyHeaderTableView
//
//  Created by Jacky Tay on 25/05/18.
//  Copyright © 2018 JackyTay. All rights reserved.
//

import UIKit

class VehicleTableViewCell: StickyTableViewCell {

    @IBOutlet weak var icon: UIImageView!
    @IBOutlet weak var rego: UILabel!
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var detail: UILabel!

    func bind(data: VehicleRow) {
        icon.image = UIImage(named: data.vehicle)
        rego.text = data.rego
        title.text = data.title
        detail.text = data.detail
    }
}
