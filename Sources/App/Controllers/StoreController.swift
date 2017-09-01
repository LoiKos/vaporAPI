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
import Foundation

final class StoresController: ResourceRepresentable, EmptyInitializable{

    func index(request: Request) throws -> ResponseRepresentable {
        let offset = request.query?["offset"]?.int ?? 0
        let limit = request.query?["limit"]?.int ?? 0
        
        guard let db = Store.database else {
            throw Abort.serverError
        }
        var json = JSON()
        
        json["limit"] = JSON(limit)
        json["offset"] = JSON(offset)
        
        return try db.transaction(){ conn in
            if limit == 0 && offset == 0 {
                let stores = try Store.makeQuery(conn).all()
                json["total"] = JSON(stores.count)
                json["data"] = try stores.makeJSON()
            } else {
                json["total"] = JSON(try Store.makeQuery(conn).count())
                json["data"] = try Store.makeQuery(conn).limit(raw: "\(limit > 0 ? "\(limit)" : "all") OFFSET \(offset)").all().makeJSON()
            }
            return json
        }
    }

    func create(request: Request) throws -> ResponseRepresentable {
        let store = try request.store()
        try store.save()
        let response = try Response(status: .created, json: store.makeJSON())
        return response
    }

    func show(request: Request, store:Store) throws -> ResponseRepresentable {
        return store
    }

    func delete(request: Request, store:Store) throws -> ResponseRepresentable {
        try store.delete()
        return store
    }

    func update(request: Request, store:Store) throws -> ResponseRepresentable {
        if request.json?["name"] == nil {
            try request.json?.set("name", store.name)
        }
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
