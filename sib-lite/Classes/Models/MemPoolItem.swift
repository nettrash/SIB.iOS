//
//  MemPoolItem.swift
//  sib-lite
//
//  Created by Иван Алексеев on 19.12.2017.
//  Copyright © 2017 NETTRASH. All rights reserved.
//

import Foundation

public class MemPoolItem: NSObject {
	
	var address: String?
	var txid: String?
	var N: Int?
	var value: Int64?
	var seconds: Int64?
	var prev_txid: String?
	var prev_N: Int?
	var isInput: Bool = false
	
	func getAmount(_ dimension: BalanceDimension) -> String {
		var amount: Double = Double(value ?? 0) / pow(10,8)
		if amount < 0 { amount = -amount }
		switch dimension {
		case .SIB:
			return String(format: "%.2f", amount)
		case .mSIB:
			return String(format: "%.2f", amount * 1000)
		case .µSIB:
			return String(format: "%.2f", amount * 1000 * 1000)
		case .ivans:
			return String(format: "%.0f", amount * 1000 * 1000 * 100)
		}
	}
	
	func getSeconds() -> String {
		return NSLocalizedString("InMemoryPool", comment: "in memory")
	}
}
