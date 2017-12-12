//
//  sibTransactionInputOutpoint.swift
//  sib-lite
//
//  Created by Иван Алексеев on 09.12.2017.
//  Copyright © 2017 NETTRASH. All rights reserved.
//

import Foundation

class sibTransactionInputOutpoint : NSObject {
	
	var Hash: String
	var Index: UInt32
	
	init(_ hash: String, _ index: UInt32) {
		Hash = hash
		Index = index
		super.init()
	}
}
