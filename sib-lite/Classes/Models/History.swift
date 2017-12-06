//
//  TransactionHistory.swift
//  sib-lite
//
//  Created by Иван Алексеев on 18.10.2017.
//  Copyright © 2017 NETTRASH. All rights reserved.
//

import Foundation

public class History: NSObject {
	
	var Items: [HistoryItem] = []
	
	override init() {
		super.init()
		//Items.append(HistoryItem(type: .Incoming, date: Date.init(timeIntervalSinceNow: -1000), amount: 100))
		//Items.append(HistoryItem(type: .Outgoing, date: Date.init(timeIntervalSinceNow: -500), amount: 25))
		//Items.append(HistoryItem(type: .Outgoing, date: Date.init(timeIntervalSinceNow: -100), amount: 75))
	}
	
	func load(_ txs: [Any], addresses: [Address]) {
		let addrsIn = addresses.filter { $0.type == 0 }.map { (_ a: Address) -> String in
			a.address
		}
		let addrsChange = addresses.filter { $0.type == 1 }.map { (_ a: Address) -> String in
			a.address
		}
		Items = txs.map({ (_ t: Any) -> HistoryItem in
			
			let tx = t as? [String: Any]
			var txDate: Date = Date()
			let txAmount: Double = 0
			
			//let confirmations = tx?["Confirmations"] as? UInt32
			let transactionDate = tx?["TransactionDate"] as? String
			let formatter = DateFormatter()
			formatter.dateFormat = "yyyy-MM-dd HH:mm:ss Z"
			txDate = formatter.date(from: transactionDate!)!
			
			let Out = tx?["Out"] as? [Any]
			
			if (Out != nil) {
				let OutSorted = Out?.sorted(by: { (_ a: Any, _ b: Any) -> Bool in
					((a as? [String: Any])!["OrderN"] as! UInt32) < ((b as? [String: Any])!["OrderN"] as! UInt32)
					})
				
				var outInAmount: Double = 0
				var outChangeAmount: Double = 0
				var outExternalAmount: Double = 0
				
				for out in OutSorted! {
					let o = out as? [String: Any]
					let oa = o!["Addresses"] as? [String]
					let os = o!["Amount"] as? Double
					for oai in oa! {
						if addrsIn.contains(oai) {
							outInAmount += os!
							continue
						}
						if addrsChange.contains(oai) {
							outChangeAmount += os!
							continue
						}
						outExternalAmount += os!
					}
				}
				
				return HistoryItem(type: (outInAmount == 0 ? .Outgoing : .Incoming), date: txDate, amount: (outInAmount == 0 ? outExternalAmount : outInAmount) / Double(100000000))
			}
			
			//let In = tx?["In"] as? [Any]
			
			return HistoryItem(type: .Unknown, date: txDate, amount: txAmount)
		})
	}
}
