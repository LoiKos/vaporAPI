//
//  SetupTests.swift
//  vaporMbao
//
//  Created by Loic LE PENN on 24/08/2017.
//
//

import XCTest
import Vapor
@testable import App

class SetupTests: XCTestCase {

    func testConfig() {
        XCTAssertNoThrow(try Config())
    }
    
    func testSetupConfig() {
        XCTAssertNoThrow(try Config().setup())
    }
    
    func testDroplet(){
        guard let config : Config = try? Config(),
            ((try? config.setup()) != nil) else {
            XCTFail("impossible to set config")
            return
        }
        
        XCTAssertNoThrow(try Droplet(config).setup())
    }

    func testConfigPerformance() {
        self.measure {
            self.testConfig()
        }
    }
    
    func testSetupPerformance() {
        self.measure {
            self.testSetupConfig()
        }
    }
    
    func testDropletPerformance() {
        self.measure {
            self.testDroplet()
        }
    }
    
    static var allTests : [(String, (SetupTests) -> () throws -> Void)] {
        return [
            ("testConfig", testConfig),
            ("testSetupConfig", testSetupConfig),
            ("testDroplet", testDroplet),
            ("testConfigPerformance", testConfigPerformance),
            ("testSetupPerformance", testSetupPerformance),
            ("testDropletPerformance", testDropletPerformance)
        ]
    }

}
