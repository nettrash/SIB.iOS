//
//  BalanceResponse.swift
//  sib-lite
//
//  Created by Иван Алексеев on 25.10.2017.
//  Copyright © 2017 NETTRASH. All rights reserved.
//

import Foundation

struct BalanceResponse {
	
	var Received: UInt64
	var Success: UInt8
	var Value: UInt64
	
	init?(json: [String:Any]) {
		guard let received = json["Received"] as? UInt64,
			let success = json["Success"] as? UInt8,
			let value = json["Value"] as? UInt64 else {
				return nil
			}
		self.Received = received
		self.Success = success
		self.Value = value
	}
	
}
