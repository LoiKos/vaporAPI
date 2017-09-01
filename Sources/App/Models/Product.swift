import Vapor
import HTTP
import FluentProvider

final class Product: Model,NodeInitializable {
    
    let storage = Storage()
    
    static let idKey: String = "refproduct"
    static let foreignIdKey = "refproduct"
    static let idType: IdentifierType = .custom("varchar(255) primary key")
    var id: Identifier? = ""
    
    var refproduct: String
    var name: String
    var picture: String?
    var creationdate: Date
    
    init(name:String,picture:String?){
        self.refproduct = Reference.sharedInstance.generateRef()
        self.name = name
        self.picture = picture
        self.creationdate = Date()
        self.id? = Identifier(self.refproduct)
    }
    
    init(row:Row) throws {
        refproduct = try row.get("refproduct")
        name = try row.get("name")
        picture = try row.get("picture")
        creationdate = try row.get("creationdate")
        self.id? = Identifier(self.refproduct)
    }
    
    init(node:Node) throws {
        if node.isNull{
            throw Abort(.notFound)
        }
        refproduct = try node.get("refproduct")
        name = try node.get("name")
        picture = try node.get("picture")
        creationdate = try node.get("creationdate")
        self.id? = Identifier(self.refproduct)
    }

    
    func makeRow() throws -> Row {
        var row = Row()
        try row.set("refproduct", refproduct)
        try row.set("name", name)
        try row.set("picture", picture)
        try row.set("creationdate", creationdate)
        return row
    }
}

// MARK: Fluent
// Fluent Compliance
// Allow Vapor to create database from the model
extension Product: Preparation{
   
    static func prepare(_ database: Database) throws {
        try database.create(self) { builder in
            builder.id()
            builder.string("name")
            builder.string("picture",optional: true)
            builder.date("creationdate")
        }
    }
    
    static func revert(_ database: Database) throws {
        try database.delete(self)
    }
}

// MARK: JSON
extension Product: JSONConvertible {
    convenience init(json: JSON) throws {
        guard let keys = json.object?.keys,
            !keys.isEmpty else { throw Abort(.accepted) }
    
        for key in keys {
            if !["name","picture"].contains(key) {
                throw Abort(.accepted)
            }
        }
        try self.init(name: json.get("name"), picture: json.get("picture"))
    }
    
    func makeJSON() throws -> JSON {
        var json = JSON()
        try json.set("refproduct", refproduct)
        try json.set("name", name)
        try json.set("picture", picture)
        try json.set("creationdate", creationdate)
        return json
    }
}

// MARK: HTTP
// this allow to return Product directly in route closures
extension Product: ResponseRepresentable {}

