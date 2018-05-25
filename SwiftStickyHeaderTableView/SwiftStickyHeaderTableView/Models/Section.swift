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
}
