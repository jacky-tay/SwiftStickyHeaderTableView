//
//  Section.swift
//  SwiftStickyHeaderTableView
//
//  Created by Jacky Tay on 25/05/18.
//  Copyright © 2018 JackyTay. All rights reserved.
//

import Foundation

class Section {
    var header: String?
    var rows = [Row]()
    var footer: String?

    init(json: [String : Any]) {
        header = json["header"] as? String
        if let items = json["rows"] as? [[String : Any]] {
            rows = items.map { Row.getObject(json: $0) }
        }
        footer = json["footer"] as? String
    }


    /// Calculate the total numbers of Row object in a flatten dimension
    ///
    /// - Returns: The total numbers of Row object
    func numberOfFlattenRows() -> Int {
        return rows.reduce(0) { $0 + $1.numberOfFlattenRows() }
    }


    /// Find the Row object in a flatten dimension
    ///
    /// - Parameter index: The index
    /// - Returns: The Row object
    func get(flattenRowAt index: Int) -> Row {
        var row = 0
        var offset = 0 // use offset as reference point when viewing children in a flatten dimension
        // increment row count when the number of flatten rows is smaller than the index
        for i in 1 ..< rows.count where offset < index {
            offset += rows[i - 1].numberOfFlattenRows()
            row += 1
        }
        // decrement the row if the index is smaller than the offset reference
        if row > 0 && index < offset {
            row -= 1
            offset -= rows[row].numberOfFlattenRows()
        }

        return rows[row].get(flattenRowAt: index - offset)
    }
}
