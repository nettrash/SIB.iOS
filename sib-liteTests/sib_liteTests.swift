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
	
	func testWalletInitialize_isCorrect() {
		let w = Wallet()
		w.initialize("test")
		XCTAssert(w.Address == "SRcxum6SzkCLkgC3W8vzSeiVtdiPrbH9zB")
		XCTAssert(w.WIF == "Kz45ruVNX4YRYobW6nqjCjFnjDw67rRV2ZJoq3akysBX9qQNWHNC")
	}
	
	func testBitPayInvoiceDeserialize_isCorrect() {
		let expectation = XCTestExpectation.init(description: "testBitPayInvoiceDeserialize")

		let url = URL(string: "https://bitpay.com/invoices/ShvPHvxLuwARmnLisSmnBg")
		let urlRequest: URLRequest = URLRequest(url: url!)
		let session = URLSession.shared
		let task = session.dataTask(with: urlRequest) {
			(data, response, error) -> Void in
				
			if error == nil {
				let json = String(data: data!, encoding: .utf8)
				let invoice = bitpayInvoice(json!)
				XCTAssert(invoice.valid)
			} else {
				XCTAssert(false)
			}
			expectation.fulfill()
			
		}
		task.resume()
		self.wait(for: [expectation], timeout: 10.0)
	}
	
    /*
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }*/
    
}
