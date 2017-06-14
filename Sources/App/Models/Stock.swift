import Vapor
import HTTP
import FluentProvider

final class Stock: Model, PivotProtocol, NodeInitializable {
    
    // Conform to PivotProtocol :
    typealias Left = Store
    typealias Right = Product
    static var leftIdKey: String = "refstore"
    static var rightIdKey: String = "refproduct"
    
    // Fluent variable needed
    let storage = Storage()

    // Define Model name (Optionnal) -  Default work with the class name lowercased follow by 's' ex: stocks
    static var entity = "stock"
   
    static let idKey: String = "(refstore,refproduct)"
    
    // Model properties
    let refproduct: String
    let refstore: String
    var quantity: Int
    var vat : Int
    var status: String?
    var priceht: Int
    let creationdate: Date
    var lastupdate:Date?
    
    
    init(refproduct: String, refstore: String,quantity: Int,vat : Int,status: String?,priceht: Int){
        self.refproduct = refproduct
        self.refstore = refstore
        self.creationdate = Date()
        self.quantity = quantity
        self.vat = vat
        self.status = status
        self.priceht = priceht
        self.lastupdate = nil
    }
    
    init(row:Row) throws {
        refproduct = try row.get("refproduct")
        refstore = try row.get("refstore")
        vat = try row.get("vat")
        quantity = try row.get("quantity")
        priceht = try row.get("priceht")
        status = try row.get("status")
        creationdate = try row.get("creationdate")
        lastupdate = try row.get("lastupdate")
    }
    
    init(node:Node) throws {
        if node.isNull{
            throw Abort(.notFound)
        }
        refproduct = try node.get("refproduct")
        refstore = try node.get("refstore")
        vat = try node.get("vat")
        quantity = try node.get("quantity")
        priceht = try node.get("priceht")
        status = try node.get("status")
        creationdate = try node.get("creationdate")
        lastupdate = try node.get("lastupdate")
    }
    
    func makeRow() throws -> Row {
        var row = Row()
        try row.set("refstore", refstore)
        try row.set("refproduct", refproduct)
        try row.set("quantity", quantity)
        try row.set("vat", vat)
        try row.set("priceht", priceht)
        try row.set("status", status)
        try row.set("creationdate", creationdate)
        try row.set("lastupdate", lastupdate)
        return row
    }
}

// MARK: Fluent
// Fluent Compliance
// Allow Vapor to create database from the model
extension Stock: Preparation{
    static func prepare(_ database: Database) throws {

        try database.create(self) { builder in
            builder.string("refstore")
            builder.string("refproduct")
            builder.string("status",optional:true)
            builder.date("creationdate")
            builder.date("lastupdate",optional:true)
            builder.int("quantity")
            builder.int("vat")
            builder.int("priceht")
            builder.foreignKey("refstore", references: leftIdKey, on: Left.self)
            builder.foreignKey("refproduct", references: rightIdKey, on: Right.self)
        }
        
        try database.raw("alter table \(name) add PRIMARY KEY (refstore,refproduct); ")
    }
    
    static func revert(_ database: Database) throws {
        try database.delete(self)
    }

}

// MARK: JSON
extension Stock: JSONConvertible{
    convenience init(json: JSON) throws {
        guard let keys = json.object?.keys else {
            throw Abort(.badRequest)
        }
        
        for key in keys {
            if !["quantity","vat","status","priceht","refproduct","refstore"].contains(key){
                throw Abort(.badRequest)
            }
        }
       
        try self.init(
            refproduct: json.get("refproduct"),
            refstore: json.get("refstore"),
            quantity: json.get("quantity"),
            vat: Stock.convert(json.get("vat") as Double),
            status: json.get("status"),
            priceht: Stock.convert(json.get("priceht") as Double)
        )}
    
    func makeJSON() throws -> JSON {
        var json = JSON()
        try json.set("refstore", refstore)
        try json.set("refproduct", refproduct)
        try json.set("quantity", quantity)
        try json.set("vat", Double(vat)/100)
        try json.set("status", status)
        try json.set("priceht", Double(priceht)/100)
        try json.set("creationdate", creationdate)
        try json.set("lastupdate", lastupdate)
        return json
    }
    
    static func convert(_ double:Double) -> Int {
        return Int((StructuredData.Number.double(double).double * 100).rounded())
    }
}

// MARK: HTTP
// this allow to return Product directly in route closures
extension Stock: ResponseRepresentable {}
