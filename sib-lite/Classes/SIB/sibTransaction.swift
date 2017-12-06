//
//  sibTransaction.swift
//  sib-lite
//
//  Created by Иван Алексеев on 04.12.2017.
//  Copyright © 2017 NETTRASH. All rights reserved.
//

import Foundation
import CommonCrypto

class sibTransaction : NSObject {
	
	var version: Int = 1
	var lock_time: Int = 0
	
	var Input: [sibTransactionInput] = []
	var Output: [sibTransactionOutput] = []
	
	var Timastamp: Int? = nil
	var Block: String? = nil
}
