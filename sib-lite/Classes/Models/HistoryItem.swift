//
//  HistoryItem.swift
//  sib-lite
//
//  Created by Иван Алексеев on 18.10.2017.
//  Copyright © 2017 NETTRASH. All rights reserved.
//

import Foundation

public class HistoryItem: NSObject {
	
	var type: HistoryItemType = .Incoming
	var date: Date = Date()
	var amount: Double = 0
	
	override init() {
		super.init()
	}
	
	init(type itemType: HistoryItemType, date itemDate: Date, amount itemAmount: Double) {
		super.init()
		type = itemType
		date = itemDate
		amount = itemAmount
	}
	
	func getDate() -> String {
		let cal: Calendar = Calendar(identifier: Calendar.Identifier.gregorian)
		let d = Date()
		
		let dateFormatter = DateFormatter()
		if (cal.compare(date, to: d, toGranularity: Calendar.Component.day) == ComparisonResult.orderedSame) {
			dateFormatter.dateFormat = "hh:mm"
		} else if (cal.compare(date, to: d, toGranularity: Calendar.Component.month) == ComparisonResult.orderedSame) {
			dateFormatter.dateFormat = "dd MMMM"
		} else if (cal.compare(date, to: d, toGranularity: Calendar.Component.year) == ComparisonResult.orderedSame) {
			dateFormatter.dateFormat = "dd MMMM"
		} else {
			dateFormatter.dateFormat = "dd-MM-yyyy"
		}
		return dateFormatter.string(from: date)
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
