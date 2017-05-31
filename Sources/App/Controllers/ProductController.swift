import Vapor
import HTTP
import PostgreSQLDriver

final class ProductsController: ResourceRepresentable, EmptyInitializable{
    
    func index(request: Request) throws -> ResponseRepresentable {
        let offset = request.query?["offset"]?.int ?? 0
        var json : JSON = JSON()
        if let limit = request.query?["limit"]?.int {
            json["data"] = try Product.makeQuery().limit(limit, offset: offset).all().makeJSON()
            json["limit"] = JSON(limit)
            json["offset"] = JSON(offset)
        } else if offset > 0 {
            let products = try Product.database?.raw("Select * from products offset $1", [offset])
            var result = [Product]()
            try products?.array?.forEach({ node in
                result.append(try node.converted(to: Product.self))
            })
            json["data"] = try result.makeJSON()
            json["offset"] = JSON(offset)
        } else {
            json["data"] = try Product.all().makeJSON()
        }
        json["total"] = JSON(try Product.count())
        return json
    }
    
    func create(request: Request) throws -> ResponseRepresentable {
        let product = try request.product()
        try product.save()
        return product
    }
    
    func show(request: Request, product: Product) throws -> ResponseRepresentable {
        return product
    }
    
    func delete(request: Request, product: Product) throws -> ResponseRepresentable {
        try product.delete()
        return product
    }
    
    func update(request: Request, product: Product) throws -> ResponseRepresentable {
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
