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
            return VehicleRow(json: json)
        }
        else {
            return StandardRow(json: json)
        }
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
