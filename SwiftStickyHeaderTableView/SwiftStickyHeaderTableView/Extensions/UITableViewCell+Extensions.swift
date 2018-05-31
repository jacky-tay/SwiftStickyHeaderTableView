//
//  UITableViewCell+Extensions.swift
//  SwiftStickyHeaderTableView
//
//  Created by Jacky Tay on 29/05/18.
//  Copyright © 2018 JackyTay. All rights reserved.
//

import Foundation
import UIKit

extension UITableViewCell {

    class func getDefaultSeparatorInsets() -> UIEdgeInsets {
        return UITableViewCell().separatorInset
    }

    func setSeperatorToZero() {
        setSeperator(edge: UIEdgeInsets.zero)
    }

    func setSeperator(edge: UIEdgeInsets) {
        separatorInset = edge
        layoutMargins = edge
    }
}
