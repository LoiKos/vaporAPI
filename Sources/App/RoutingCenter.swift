//
//  RoutingCenter.swift
//  vaporMbao
//
//  Created by Loic LE PENN on 22/05/2017.
//
//

import Vapor

final class RoutingCenter: RouteCollection, EmptyInitializable {
    func build(_ builder: RouteBuilder) throws {
        try builder.resource("api/v1/products", ProductsController.self)
    }
}

extension Request {
    func product() throws -> Product {
        guard let json = json else { throw Abort.badRequest }
        let product = try Product(json: json)
        return product
    }
}
