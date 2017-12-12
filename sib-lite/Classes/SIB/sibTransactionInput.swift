//
//  sibTransactionInput.swift
//  sib-lite
//
//  Created by Иван Алексеев on 04.12.2017.
//  Copyright © 2017 NETTRASH. All rights reserved.
//

import Foundation

class sibTransactionInput : NSObject {
	
	var outPoint: sibTransactionInputOutpoint
	var Script: [UInt8]
	var Sequence: UInt64
	
	init(_ hash: String, _ index: UInt32, _ script: String, _ lockTime: UInt32) {
		outPoint = sibTransactionInputOutpoint(hash, index)
		Script = script.hexa2Bytes
		Sequence = lockTime == 0 ? 4294967295 : 0
		super.init()
	}
}
