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
        // left margin is 20 for 6/7 plus device
        let leftMargin: CGFloat = UIScreen.main.scale == 3 ? 20 : 16
        return UIEdgeInsetsMake(0, leftMargin, 0, 0)
    }
}
