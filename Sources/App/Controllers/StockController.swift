//
//  StockController.swift
//  vaporMbao
//
//  Created by Loic LE PENN on 01/06/2017.
//
//

import Vapor
import HTTP
import PostgreSQLDriver

final class StockController : RouteCollection, EmptyInitializable {

    func build(_ builder: RouteBuilder) throws {
        builder.get("/", handler: self.index)
        builder.post("/", handler: self.create)
        builder.get("/:refproduct", handler: self.show)
        builder.delete("/:refproduct", handler: self.delete)
        builder.patch("/:refproduct", handler: self.update)
    }

    func index(request: Request) throws -> ResponseRepresentable {
        guard let id : String = try request.parameters.get("refstore") else {
            throw Abort(.badRequest)
        }

        let offset = request.query?["offset"]?.int ?? 0
        let limit = request.query?["limit"]?.int ?? 0

        var query =  "select stock.*,"
                     + "products.name as product_name,"
                     + "products.picture as product_picture,"
                     + "products.creationdate as product_creationdate,"
                     + "products.refproduct as product_refproduct "
                     + "from stock inner join products on stock.refproduct = products.refproduct "
                     + "where stock.refstore = $1"

        var json = JSON()

        if limit > 0  {
            query += " limit $2"
            json["limit"] = JSON(limit)
        }
        if offset > 0  {
            query += " offset $3"
            json["offset"] = JSON(offset)
        }

        guard let db = Stock.database else {
            throw Abort(.internalServerError)
        }

        return try db.transaction({ con in
            let raw = try con.raw(query, [id,limit,offset])
            if (raw.array != nil) {
                var data = [JSON]()
                for item in raw.array! {
                    var json = try Stock(node: item).makeJSON()
                    try json.set("product_name",item.wrapped.object?["product_name"])
                    try json.set("product_picture",item.wrapped.object?["product_picture"])
                    try json.set("product_creationdate",item.wrapped.object?["product_creationdate"])
                    try json.set("product_refproduct",item.wrapped.object?["product_refproduct"])
                    data.append(json)
                }
                json["data"] = JSON(data)
            } else {
                json["data"] = try raw.converted(to: JSON.self, in: nil)
            }
            let raw2 = try con.raw("select count(*) from stock where stock.refstore = $1", [id])
            let value_count:[Int] = try JSON(node: raw2).get("count")
            json["total"] = JSON(value_count[0])
            return json
        })
    }

    func create(request: Request) throws -> ResponseRepresentable {
        guard let refstore:String = try request.parameters.get("refstore") else {
            throw Abort(.badRequest)
        }

        let (productjson,stockjson) = try split(json: request.json)

        let product = try request.product(json: productjson)

        var jsonS = stockjson
        jsonS["refstore"] = JSON(refstore)
        jsonS["refproduct"] = JSON(product.refproduct)

        let stock = try request.stock(json: jsonS)

        guard let db = Stock.database else {
            throw Abort(.internalServerError)
        }

        return try db.transaction({ con in
            try product.makeQuery(con).save()
            try stock.makeQuery(con).save()
            var stJSON = try stock.makeJSON()
            stJSON["product_refproduct"] = JSON(product.refproduct)
            stJSON["product_name"] = JSON(product.name)
            stJSON["product_picture"] = product.picture != nil ? JSON(product.picture!) : nil
            stJSON["product_creationdate"] = JSON(product.creationdate.description)
            return try Response(status: .created,json: stJSON)
        })
    }

    func show(request: Request) throws -> ResponseRepresentable {
        guard let refstore:String = try request.parameters.get("refstore") else {
            throw Abort(.badRequest)
        }
        guard let refproduct:String = try request.parameters.get("refproduct") else {
            throw Abort(.badRequest)
        }

        let query = "select stock.*, products.name as product_name, products.picture as product_picture, products.creationdate as product_creationdate, products.refproduct as product_refproduct from stock inner join products on products.refproduct = stock.refproduct where stock.refstore = $1 and stock.refproduct = $2 and products.refproduct = $2 LIMIT 1"

        let raw = try Stock.database?.raw(query, [refstore,refproduct])

        guard let node = raw?.array?.first,
              let object = node.object else {
                throw Abort(.notFound)
        }

        var json = try Stock.init(node:node).makeJSON()
        try json.set("product_name", object["product_name"])
        try json.set("product_picture", object["product_picture"])
        try json.set("product_creationdate", object["product_creationdate"])
        try json.set("product_refproduct", object["product_refproduct"])
        return json
    }

    func delete(request: Request) throws -> ResponseRepresentable {
        guard let refstore:String = try request.parameters.get("refstore") else {
            throw Abort(.badRequest)
        }
        guard let refproduct:String = try request.parameters.get("refproduct") else {
            throw Abort(.badRequest)
        }

        let stock_delete = "delete from stock where stock.refstore = $1 and stock.refproduct = $2 returning *"
        let product_delete = "delete from products where products.refproduct = $1 returning *"

        guard let db = Stock.database else {
            throw Abort(.internalServerError)
        }

        return try db.transaction({ con in
            if let stock = try con.raw(stock_delete, [refstore,refproduct]).array?.first,
                let product = try con.raw(product_delete, [refproduct]).array?.first {
                var json = try Stock(node: stock).makeJSON()

                json["product_refproduct"] = try product.get("refproduct")
                json["product_name"] = try product.get("name")
                json["product_picture"] = try product.get("picture")
                json["product_creationdate"] = try product.get("creationdate")

                return json
            } else {
                throw Abort(.notFound)
            }
        })
    }

    func update(request: Request) throws -> ResponseRepresentable {
        guard let refstore:String = try request.parameters.get("refstore") else {
            throw Abort(.badRequest)
        }
        guard let refproduct:String = try request.parameters.get("refproduct") else {
            throw Abort(.badRequest)
        }

        guard let db = Stock.database else {
            throw Abort(.internalServerError)
        }

        return try db.transaction({ con in
            let stock = try Stock(node: try con.raw("select * from stock where refstore = $1 and refproduct = $2",[refstore,refproduct]).array?.first)

            guard let product = try Product.makeQuery(con).find(refproduct) else { throw Abort(.notFound) }

            let (productjson,stockjson) = try split(json: request.json)

            if let name = productjson.object?["name"]?.wrapped.string {
                product.name = name
            }
            if let picture = productjson.object?["picture"]?.wrapped.string {
                product.picture = picture
            }
            try product.makeQuery(con).save()

            var modified = false

            if let status = stockjson.object?["status"]?.wrapped.string {
                stock.status = status
                modified = true
            }

            if let quantity = stockjson.object?["quantity"]?.wrapped.int {
                stock.quantity = quantity
                modified = true
            }

            if let priceht = stockjson.object?["priceht"]?.wrapped.double {
                stock.price = priceht
                modified = true
            }

            if let vat = stockjson.object?["vat"]?.wrapped.double {
                stock.vat = vat
                modified = true
            }

            if modified {
                try stock.updateOn(con: con)
            }

            var response = try stock.makeJSON()
            response["product_name"] = JSON(product.name)
            if let pict = product.picture {
                response["product_picture"] = JSON(pict)
            }
            response["product_creationdate"] = JSON(product.creationdate.description)
            response["product_refproduct"] = JSON(product.refproduct)
            return response
        })
    }

    private func split(json:JSON?) throws -> (JSON,JSON){
        guard let keys = json?.object?.keys else {
            throw Abort(.badRequest)
        }

        var product = [String:StructuredData]()
        var stock = [String:StructuredData]()

        for key in keys{
            if ["product_name","product_picture"].contains(key){
                product[key.replacingOccurrences(of: "product_", with: "")] = try json?.get(key)
            } else if ["status","priceht","vat","quantity"].contains(key){
                stock[key] = try json?.get(key)
            } else {
                throw Abort(.badRequest)
            }
        }
        if product.count > 2 {
            throw Abort(.badRequest)
        }

        return(JSON(product),JSON(stock))
    }
}
