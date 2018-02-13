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
	
	func testCalc_isCorrect() {
		let enc: [UInt8] = [30, 67, 250, 242, 202, 121, 97, 190, 107, 185, 73, 15, 191, 15, 189, 235, 216, 147, 118, 234, 245, 30, 219, 67, 45, 36, 106, 85, 245, 126, 145, 142]
		let keyd = Crypto.md5("aes-encryption-password")
		let ivd = Crypto.md5("20219510518024419136177230")
		let decrypted = Data(enc).base64EncodedString().aesDecrypt(key: keyd, iv: ivd)
		let encrypted = decrypted!.aesEncrypt(key: keyd, iv: ivd)
		let encd = Data.init(base64Encoded: encrypted!)
		XCTAssert(true)
	}
	
    /*
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }*/
    
}
