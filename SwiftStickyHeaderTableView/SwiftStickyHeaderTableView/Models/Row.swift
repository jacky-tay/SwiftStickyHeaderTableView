//
//  Row.swift
//  SwiftStickyHeaderTableView
//
//  Created by Jacky Tay on 25/05/18.
//  Copyright © 2018 JackyTay. All rights reserved.
//

import Foundation

protocol RowType {
    var type: CellType { get }
    var cellIdentifier: String { get }
}

class Row {
    var isSubCategoryHeader: Bool
    var cellIdentifier: String { get { return "" } }
    var title: String!
    var detail: String!
    var children: [Row]?

    init(json: [String : Any]) {
        title = json["title"] as? String ?? "Title"
        detail = json["detail"] as? String ?? "Detail"
        isSubCategoryHeader = json["subHeader"] as? Bool ?? false
        
        if let items = json["children"] as? [[String : Any]] {
            children = items.map { Row.getObject(json: $0) }
        }
    }

    static func getObject(json: [String : Any]) -> Row {
        let type = json["type"] as? String
        if type == "vehicle" {
            return VehicleRow(json: json)
        }
        else if type == "person" {
            return PersonRow(json: json)
        }
        else {
            return StandardRow(json: json)
        }
    }

    func numberOfFlattenRows() -> Int {
        return 1 + (children?.reduce(0) { $0 + $1.numberOfFlattenRows() } ?? 0)
    }

    func get(flattenRowAt index: Int) -> Row {
        guard index > 0 else {
            return self
        }
        // dig further
        guard let children = children, children.count > 0 else {
            return self
        }
        var row = 0
        var offset = 0
        for i in 1 ..< children.count where offset < index - 1 { // need to subtract 1 because this cell is
            offset += children[i].numberOfFlattenRows()
            row += 1
        }
        return children[row].get(flattenRowAt: index - 1 - (offset - children[row].numberOfFlattenRows()))
    }
}

class StandardRow: Row {
    var type: CellType { get { return .default } }
    override var cellIdentifier: String { get { return "StandardCell" } }
}

class VehicleRow: Row {
    var type: CellType { get { return .vehicle } }
    override var cellIdentifier: String { get { return "VehicleCell" } }

    var rego: String!
    var vehicle: String!

    override init(json: [String : Any]) {
        super.init(json: json)
        rego = json["rego"] as? String ?? "rego"
        vehicle = json["vehicle"] as? String ?? "car"
    }
}

class PersonRow: Row {
    var type: CellType { get { return .person } }
    override var cellIdentifier: String { get { return "PersonCell" } }

    var person: String!

    override init(json: [String : Any]) {
        super.init(json: json)
        person = json["person"] as? String ?? "man"
    }
}
