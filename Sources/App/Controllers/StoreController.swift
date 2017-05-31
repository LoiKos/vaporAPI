//
//  StoreController.swift
//  vaporMbao
//
//  Created by Loic LE PENN on 31/05/2017.
//
//

import Vapor
import HTTP
import PostgreSQLDriver

final class StoresController: ResourceRepresentable, EmptyInitializable{
    
    func index(request: Request) throws -> ResponseRepresentable {
        let offset = request.query?["offset"]?.int ?? 0
        var json : JSON = JSON()
        if let limit = request.query?["limit"]?.int {
            json["data"] = try Store.makeQuery().limit(limit, offset: offset).all().makeJSON()
            json["limit"] = JSON(limit)
            json["offset"] = JSON(offset)
        } else if offset > 0 {
            let stores = try Store.database?.raw("Select * from stores offset $1", [offset])
            var result = [Store]()
            try stores?.array?.forEach({ node in
                result.append(try node.converted(to: Store.self))
            })
            json["data"] = try result.makeJSON()
            json["offset"] = JSON(offset)
        } else {
            json["data"] = try Store.all().makeJSON()
        }
        json["total"] = JSON(try Store.count())
        return json
    }
    
    func create(request: Request) throws -> ResponseRepresentable {
        let store = try request.store()
        try store.save()
        return store
    }
    
    func show(request: Request, store:Store) throws -> ResponseRepresentable {
        return store
    }
    
    func delete(request: Request, store:Store) throws -> ResponseRepresentable {
        try store.delete()
        return store
    }
    
    func update(request: Request, store:Store) throws -> ResponseRepresentable {
        let new = try request.store()
        store.name = new.name
        store.picture = new.picture ?? store.picture
        store.vat = new.vat ?? store.vat
        store.currency = new.currency ?? store.currency
        store.merchantkey = new.merchantkey ?? store.merchantkey
        try store.save()
        return store
    }
    
    func makeResource() -> Resource<Store> {
        return Resource(
            index: index,
            store: create,
            show: show,
            update: update,
            destroy: delete
        )
    }
}
