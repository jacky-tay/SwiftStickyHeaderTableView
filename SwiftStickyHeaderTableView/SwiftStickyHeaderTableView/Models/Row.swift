//
//  Row.swift
//  SwiftStickyHeaderTableView
//
//  Created by Jacky Tay on 25/05/18.
//  Copyright © 2018 JackyTay. All rights reserved.
//

import Foundation

class Row {
    var cellIdentifier: String { get { return "" } }
    var title: String!
    var detail: String!
    var children: [Row]?

    init(json: [String : Any]) {
        title = json["title"] as? String ?? "Title"
        detail = json["detail"] as? String ?? "Detail"
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


    /// Check that child is one of the child of Row object
    ///
    /// - Parameter child: The child Row object
    /// - Returns: `True` if Row object contains child, otherwise `False`
    func has(child: Row) -> Bool {
        return hasChildren() && (children?.contains(where: { $0 == child }) ?? false)
    }

    /// Check that if the Row object has children and it is not empty
    ///
    /// - Returns: `True` if Row object has children, otherwise `False`
    func hasChildren() -> Bool {
        return !(children?.isEmpty ?? true)
    }

    /// A recursive method that check the total number of rows a Row object has. A Row object itself is counted as 1.
    ///
    /// - Returns: The total number of rows a Row object has.
    func numberOfFlattenRows() -> Int {
        return 1 + (children?.reduce(0) { $0 + $1.numberOfFlattenRows() } ?? 0)
    }


    /// Find the flatten Row object from a given index. Row object may contain child which itself may contain child.
    ///
    /// - Parameter index: The index
    /// - Returns: The Row object which located in a flatten dimension.
    func get(flattenRowAt index: Int) -> Row {
        guard index > 0 else {
            return self // return Row object itself if the index is 0
        }
        // dig further
        guard let children = children, children.count > 0 else {
            return self // return Row object itself if there it has no children, this should not happen
        }
        var row = 0
        var offset = 1 // use offset as reference point when viewing children in a flatten dimension
        // increment row count when the number of flatten rows is smaller than the index
        for i in 0 ..< children.count where offset < index { // need to subtract 1 because this cell is
            offset += children[i].numberOfFlattenRows()
            row += 1
        }
        // decrement the row if the found child Row object has children and the index is smaller than the offset reference
        if row > 0 && children[row - 1].hasChildren() && index < offset  {
            row -= 1
            offset -= children[row].numberOfFlattenRows()
        }
        return children[row].get(flattenRowAt: index - offset)
    }


    /// Check that Row object is identical object
    ///
    /// - Parameters:
    ///   - lhs: The Row object
    ///   - rhs: The Row object to be compared
    /// - Returns: `True` if the cell identifier, title, and title are identical, otherwise `False`
    static func ==(lhs: Row, rhs: Row) -> Bool {
        return lhs.cellIdentifier == rhs.cellIdentifier &&
        lhs.detail == rhs.detail &&
        lhs.title == rhs.title
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
