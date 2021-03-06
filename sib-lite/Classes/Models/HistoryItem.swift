//
//  HistoryItem.swift
//  sib-lite
//
//  Created by Иван Алексеев on 18.10.2017.
//  Copyright © 2017 NETTRASH. All rights reserved.
//

import Foundation

public class HistoryItem: NSObject {
	
	var id: String = ""
	var type: HistoryItemType = .Incoming
	var date: Date = Date()
	var amount: Double = 0
	var outAddress: String = ""
	
	override init() {
		super.init()
	}
	
	init(id txid: String, type itemType: HistoryItemType, date itemDate: Date, amount itemAmount: Double, outAddress address: String) {
		super.init()
		id = txid
		type = itemType
		date = itemDate
		amount = itemAmount
		outAddress = address
	}
	
	func getDate() -> String {
		let cal: Calendar = Calendar(identifier: Calendar.Identifier.gregorian)
		let d = Date()
		var a = ""
		
		let dateFormatter = DateFormatter()
		if (cal.compare(date, to: d, toGranularity: Calendar.Component.day) == ComparisonResult.orderedSame) {
			dateFormatter.dateFormat = "HH:mm"
			a = " MSK"
		} else if (cal.compare(date, to: d, toGranularity: Calendar.Component.month) == ComparisonResult.orderedSame) {
			dateFormatter.dateFormat = "dd MMMM"
		} else if (cal.compare(date, to: d, toGranularity: Calendar.Component.year) == ComparisonResult.orderedSame) {
			dateFormatter.dateFormat = "dd MMMM"
		} else {
			dateFormatter.dateFormat = "dd-MM-yyyy"
		}
		return dateFormatter.string(from: date) + a
	}
	
	func getAmount(_ dimension: BalanceDimension) -> String {
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
}
