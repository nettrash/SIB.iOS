//
//  UnspentTransaction.swift
//  sib-lite
//
//  Created by Иван Алексеев on 06.12.2017.
//  Copyright © 2017 NETTRASH. All rights reserved.
//

import Foundation

class UnspentTransaction : NSObject {
	
	var txid: String
	var amount: Double
	var address: String
	var N: UInt32
	var Script: String
	
	init(_ id: String, _ summa: Double, _ addr: String, _ n: UInt32, _ script: String) {
		txid = id
		amount = summa
		address = addr
		N = n
		Script = script
		super.init()
	}
}
