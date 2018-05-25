import Foundation
import UIKit

class Section {
    var header: String?
    var rows: [Row]?
    var footer: String?

    init(_ header: String?, _ footer: String?, _ rows: [Row]? = []) {
        self.header = header
        self.footer = footer
        self.rows = rows
    }

    func toJSON() -> [String : Any] {
        var dict = [String : Any]()
        dict["header"] = header
        dict["rows"] = rows?.map { $0.toJSON() }
        dict["footer"] = footer
        return dict
    }
}
class Row {
    var isSubCategoryHeader: Bool
    var title: String!
    var detail: String!
    var children: [Row]?

    init(_ title: String, _ detail: String, _ header: Bool = false) {
        self.title = title
        self.detail = detail
        isSubCategoryHeader = header
    }

    func toJSON() -> [String : Any] {
        var dict = [String : Any]()
        dict["title"] = title
        dict["detail"] = detail
        dict["type"] = "default"
        dict["subHeader"] = isSubCategoryHeader
        dict["children"] = children?.map { $0.toJSON() }
        return dict
    }
}

class VehicleRow: Row {
    var rego: String!
    var vehicle: String!

    init(_ title: String, _ detail: String, _ header: Bool = false, _ rego: String, _ vehicle: String) {
        super.init(title, detail, header)
        self.rego = rego
        self.vehicle = vehicle
    }

    override func toJSON() -> [String : Any] {
        var dict = super.toJSON()
        dict["type"] = "vehicle"
        dict["rego"] = rego
        dict["vehicle"] = vehicle
        return dict
    }
}

class PersonRow: Row {
    var person: String!

    init(_ title: String, _ detail: String, _ header: Bool = false, _ person: String) {
        super.init(title, detail, header)
        self.person = person
    }

    override func toJSON() -> [String : Any] {
        var dict = super.toJSON()
        dict["type"] = "person"
        dict["person"] = person
        return dict
    }
}

let section1 = Section("Event", nil)
section1.rows?.append(Row("Description", "This is a test event"))
section1.rows?.append(Row("Where", "At Advanger's Head Quater, the new one not Stark's Tower"))
section1.rows?.append(Row("Floor", "The secret floor"))
section1.rows?.append(Row("Room", "The meeting room where Ultron and Jarvis had a fight"))
section1.rows?.append(Row("Time", "Not too sure at this stage, because everyone just watched the Avanger 3, and you know the ending of it. We don't want to spoiler it to those who haven't watch it. So just give those who has watched to have some time to calm down."))
let setcion2 = Section("Vechicle 1", "Do tell any one about this yet, becuase we don't want others to know that ** is here")
let v1 = VehicleRow("This is an invisible car by that superhero you know, but it wasn't showing in the movie", "I hope we can hop on it", true, "WONDER", "car")
v1.children = [Row]()
v1.children?.append(Row("Where is it", "I can't see it"))
v1.children?.append(Row("Location", "unknown"))
v1.children?.append(Row("Colour", "Transparent"))
v1.children?.append(Row("Where is it", "I can't see it"))

let c = [section1, setcion2]
if let data = (try? JSONSerialization.data(withJSONObject: c, options: .prettyPrinted)),
    let string = String(data: data, encoding: .utf8) {
    print(string)
}

