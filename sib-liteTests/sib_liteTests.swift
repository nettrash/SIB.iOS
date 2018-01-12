//
//  sib_liteTests.swift
//  sib-liteTests
//
//  Created by Иван Алексеев on 23.09.17.
//  Copyright © 2017 NETTRASH. All rights reserved.
//

import XCTest
@testable import sib_lite

class sib_liteTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testSIBAddressVerify_isCorrect() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
		XCTAssert(sibAddress.verify("SNmdtyvBJ88kg1r7vPSYMzt7yV4tkvdeFp") == true);
		XCTAssert(sibAddress.verify("16TFkJYqK73JPbdwMeteGbNbMddVWJP5rG") == false);
    }
    /*
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }*/
    
}
