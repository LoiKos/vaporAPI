import Vapor
import HTTP
import FluentProvider

final class Store: Model, NodeInitializable{
    
    let storage = Storage()
    
    static let idKey : String = "refstore"
    static let idType : IdentifierType = .custom("varchar(255) primary key")
    var id: Identifier? = ""
    
    let refstore : String
    var name : String
    var picture : String?
    var vat : Int?
    var currency : String?
    var merchantkey : String?
    
    init(name:String,picture:String?, vat:Int?, currency:String?, merchantkey:String?){
        self.refstore = Reference.sharedInstance.generateRef()
        self.name = name
        self.picture = picture
        self.vat = vat
        self.currency = currency
        self.merchantkey = merchantkey
        self.id? = Identifier(self.refstore)
    }
    
    init(row:Row) throws {
        self.refstore = try row.get("refstore")
        self.name = try row.get("name")
        self.picture = try row.get("picture")
        self.vat = try row.get("vat")
        self.currency = try row.get("currency")
        self.merchantkey = try row.get("merchantkey")
        self.id? = Identifier(self.refstore)
    }
    
    init(node:Node) throws {
        self.refstore = try node.get("refstore")
        self.name = try node.get("name")
        self.picture = try node.get("picture")
        self.vat = try node.get("vat")
        self.currency = try node.get("currency")
        self.merchantkey = try node.get("merchantkey")
        self.id? = Identifier(self.refstore)
    }
    
    func makeRow() throws -> Row {
        var row = Row()
        try row.set("refstore", refstore)
        try row.set("name", name)
        try row.set("picture", picture)
        try row.set("vat", vat)
        try row.set("currency", currency)
        try row.set("merchantkey", merchantkey)
        return row
    }
    
}

// MARK: Fluent
// Fluent Compliance
// Allow Vapor to create database from the model
extension Store: Preparation{
    
    static func prepare(_ database: Database) throws {
        try database.create(self) { builder in
            builder.id()
            builder.string("name")
            builder.string("picture",optional: true)
            builder.int("vat" ,optional: true)
            builder.string("currency" ,optional: true)
            builder.string("merchantkey", optional: true)
        }
    }
    
    static func revert(_ database: Database) throws {
        try database.delete(self)
    }
}


// MARK: JSON
extension Store: JSONConvertible {
    convenience init(json: JSON) throws {
        
        guard let keys = json.object?.keys else {
            throw Abort(.badRequest)
        }
        
        for key in keys {
            if !["name","picture","vat","currency","merchantkey"].contains(key) {
                throw Abort(.badRequest)
            }
        }
        
        try self.init(
            name: json.get("name"),
            picture: json.get("picture"),
            vat: json.get("vat"),
            currency: json.get("currency"),
            merchantkey: json.get("merchantkey")
        )
    }
    
    func makeJSON() throws -> JSON {
        var json = JSON()
        try json.set("refstore", refstore)
        try json.set("name", name)
        try json.set("picture", picture)
        try json.set("vat", vat)
        try json.set("currency", currency)
        try json.set("merchantkey", merchantkey)
        return json
    }
}

// MARK: HTTPsou
// this allow to return Product directly in route closures
extension Store: ResponseRepresentable {}
