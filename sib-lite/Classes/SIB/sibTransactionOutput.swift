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
	
	init(_ script: [UInt8], _ value: BigInteger) {
		ScriptedAddress = script.map { $0 }
		Amount = BigInteger("\(value.intValue())")
		super.init()
	}
}
