//
//  IndexPath+Extensions.swift
//  SwiftStickyHeaderTableView
//
//  Created by Jacky Tay on 29/05/18.
//  Copyright © 2018 JackyTay. All rights reserved.
//

import Foundation

extension IndexPath {

    var description: String {
        return "[\(section),\(row)]"
    }

    static let zero = IndexPath(row: 0, section: 0)

    func advance(row: Int) -> IndexPath {
        return IndexPath(row: self.row + row, section: section)
    }
}
