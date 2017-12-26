//
//  sibTransactionOutput.swift
//  sib-lite
//
//  Created by Иван Алексеев on 04.12.2017.
//  Copyright © 2017 NETTRASH. All rights reserved.
//

import Foundation

class sibTransactionOutput : NSObject {

	var Amount: BigInteger
	var ScriptedAddress: [UInt8]
	var Satoshi: UInt64
	
	init(_ script: [UInt8], _ value: BigInteger, _ satoshi: UInt64) {
		ScriptedAddress = script.map { $0 }
		Amount = value
		Satoshi = satoshi
		super.init()
	}
}
