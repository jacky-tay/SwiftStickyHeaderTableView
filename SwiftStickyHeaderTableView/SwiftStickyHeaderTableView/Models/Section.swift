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

    func numberOfFlattenRows() -> Int {
        return rows.reduce(0) { $0 + $1.numberOfFlattenRows() }
    }

    func get(flattenRowAt index: Int) -> Row {
        var row = 0
        var offset = 0

        for i in 1 ..< rows.count where offset < index {
            offset += rows[i - 1].numberOfFlattenRows()
            row += 1
        }
        if offset > index {
            row -= 1
            offset -= rows[row].numberOfFlattenRows()
        }

        return rows[row].get(flattenRowAt: index - offset)
    }
}
