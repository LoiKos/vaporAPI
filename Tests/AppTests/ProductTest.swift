//
//  ProductTest.swift
//  vaporMbao
//
//  Created by Loic LE PENN on 31/08/2017.
//
//

import XCTest
@testable import App

class ProductTest: XCTestCase {
    
    func testBaseInit() {
        let product = Product(name: "Nike", picture: nil)
        XCTAssert(product.name == "Nike")
        XCTAssertNil(product.picture)
        XCTAssertNotNil(product.creationdate)
        XCTAssertNotNil(product.refproduct)
        
        let product2 = Product(name: "Orange", picture: "orange.png")
        XCTAssert(product2.name == "Orange")
        XCTAssert(product2.picture == "orange.png")
    }
    
    func testJsonInit() {
        let json : JSON = JSON(["name":"Nike"])
        XCTAssertNoThrow(try Product(json: json))
        let json2 : JSON = JSON(["name":"Nike","picture":"test"])
        XCTAssertNoThrow(try Product(json: json2))
    }
    
    func testJsonInitFailed(){
        let json: JSON = JSON()
        XCTAssertThrowsError(try Product(json: json), "") { (error) in
            print("error \(error.localizedDescription) \(Abort.badRequest.localizedDescription)")
            XCTAssert(error.localizedDescription == Abort.badRequest.localizedDescription)
        }
        
        let json2: JSON = JSON(["salut":"loic"])
        XCTAssertThrowsError(try Product(json: json2), "") { (error) in
            XCTAssert(error is Abort)
        }

    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
    
}
