//
//  RoutingCenter.swift
//  vaporMbao
//
//  Created by Loic LE PENN on 22/05/2017.
//
//

import Vapor

final class RoutingCenter: RouteCollection {
    
    let drop: Droplet
    
    init(droplet: Droplet){
        self.drop = droplet
    }
    
    func build(_ builder: RouteBuilder) throws {
        let v1 = builder.grouped("api/v1")
        try v1.resource("/stores", StoresController.self)
        try v1.resource("/products", ProductsController.self)
        try v1.grouped("/stores/:refstore/products").collection(StockController.self)
    }
}

extension Request {
    func product() throws -> Product {
        guard let json = json else { throw Abort.badRequest }
        let product = try Product(json: json)
        return product
    }
    
    func product(json:JSON) throws -> Product {
        let product = try Product(json: json)
        return product
    }
    
    func store() throws -> Store {
        guard let json = json else { throw Abort.badRequest }
        return try Store(json: json)
    }
    
    func stock(json:JSON) throws -> Stock {
        return try Stock(json: json)
    }
}
