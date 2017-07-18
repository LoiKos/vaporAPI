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
    var status: String?
    let creationdate: Date
    var lastupdate:Date?
    // Cast double to int for database storage
    private var vatDb : Int
    private var pricehtDb: Int
    
    var price : Double {
        get { return Double(pricehtDb) / 100.0 }
        set(p) { pricehtDb = Int(p * 100) }
    }
    
    var vat : Double {
        get { return Double(vatDb) / 100.0 }
        set(p) { vatDb = Int(p * 100) }
    }
    
    init(refproduct: String, refstore: String,quantity: Int,vat : Double,status: String?,priceht: Double){
        self.refproduct = refproduct
        self.refstore = refstore
        self.creationdate = Date()
        self.quantity = quantity
        self.status = status
        self.lastupdate = nil
        self.pricehtDb = Int((priceht * 100).rounded())
        self.vatDb = Int((vat * 100).rounded())
    }
    
    init(row:Row) throws {
        refproduct = try row.get("refproduct")
        refstore = try row.get("refstore")
        vatDb = try row.get("vat")
        quantity = try row.get("quantity")
        pricehtDb = try row.get("priceht")
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
        vatDb = try node.get("vat")
        quantity = try node.get("quantity")
        pricehtDb = try node.get("priceht")
        status = try node.get("status")
        creationdate = try node.get("creationdate")
        lastupdate = try node.get("lastupdate")
    }
    
    func makeRow() throws -> Row {
        var row = Row()
        try row.set("refstore", refstore)
        try row.set("refproduct", refproduct)
        try row.set("quantity", quantity)
        try row.set("vat", vatDb)
        try row.set("priceht", pricehtDb)
        try row.set("status", status)
        try row.set("creationdate", creationdate)
        try row.set("lastupdate", lastupdate)
        return row
    }
    
    // MARK: Query build
    
    func updateOn(con:Connection) throws  {
        self.lastupdate = Date()
        try con.raw("update stock set status = $1, quantity  = $2, vat  = $3, priceht = $4, lastupdate = $5 where refstore = $6 and refproduct = $7", [status, quantity, vatDb, pricehtDb, lastupdate, refstore, refproduct])
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
            vat: json.get("vat") ,
            status: json.get("status"),
            priceht: json.get("priceht")
        )}
    
    func makeJSON() throws -> JSON {
        var json = JSON()
        try json.set("refstore", refstore)
        try json.set("refproduct", refproduct)
        try json.set("quantity", quantity)
        try json.set("vat", vat)
        try json.set("status", status)
        try json.set("priceht", price)
        try json.set("creationdate", creationdate)
        try json.set("lastupdate", lastupdate)
        return json
    }
}

// MARK: HTTP
// this allow to return Product directly in route closures
extension Stock: ResponseRepresentable {}
