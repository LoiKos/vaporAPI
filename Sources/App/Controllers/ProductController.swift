import Vapor
import HTTP
import PostgreSQLDriver

final class ProductsController: ResourceRepresentable, EmptyInitializable{

    func index(request: Request) throws -> ResponseRepresentable {
        let offset = request.query?["offset"]?.int ?? 0
        let limit = request.query?["limit"]?.int ?? 0
        
        guard let db = Product.database else {
            throw Abort.serverError
        }
        
        return try db.transaction(){ conn in
            var json = JSON()
            json["data"] = try Product.makeQuery(conn).limit(raw: "\(limit > 0 ? "\(limit)" : "all") OFFSET \(offset)").all().makeJSON()
            json["limit"] = JSON(limit)
            json["offset"] = JSON(offset)
            json["total"] = JSON(try Product.makeQuery(conn).count())
            return json
        }
    }

    func create(request: Request) throws -> ResponseRepresentable {
        let product = try request.product()
        try product.save()
        return try Response(status: .created,json: product.makeJSON())
    }

    func show(request: Request, product: Product) throws -> ResponseRepresentable {
        return product
    }

    func delete(request: Request, product: Product) throws -> ResponseRepresentable {
        try product.delete()
        return product
    }

    func update(request: Request, product: Product) throws -> ResponseRepresentable {
        if request.json?["name"] == nil {
            try request.json?.set("name", product.name)
        }
        let new = try request.product()
        product.name = new.name
        if new.picture != nil || new.picture != ""{
            product.picture = new.picture
        }
        try product.save()
        return product
    }

    func makeResource() -> Resource<Product> {
        return Resource(
            index: index,
            store: create,
            show: show,
            update: update,
            destroy: delete
        )
    }
}
