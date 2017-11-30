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
		let addrs = addresses.map { (_ a: Address) -> String in
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
				
				for out in OutSorted! {
					let o = out as? [String: Any]
					let oa = o!["Addresses"] as? [String]
					let os = o!["Amount"] as? Double
					for oai in oa! {
						if addrs.contains(oai) {
							return HistoryItem(type: .Incoming, date: txDate, amount: os! / Double(100000000))
						}
					}
				}
			}
			
			//let In = tx?["In"] as? [Any]
			
			return HistoryItem(type: .Outgoing, date: txDate, amount: txAmount)
		})
	}
}
