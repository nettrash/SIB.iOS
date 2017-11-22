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
			
			var directionInput: Bool = true
			
			let In = tx?["In"] as? [Any]
			directionInput = (In?.contains(where: ({ (_ i: Any) -> Bool in
				((i as? [String: Any])!["VType"] as! UInt8) == 0
			})))!
			let Out = tx?["Out"] as? [Any]
			
			if (Out != nil) {
				let OutSorted = Out?.sorted(by: { (_ a: Any, _ b: Any) -> Bool in
					((a as? [String: Any])!["OrderN"] as! UInt32) < ((b as? [String: Any])!["OrderN"] as! UInt32)
					})
				let Out0 = OutSorted![0] as? [String: Any]
				let Out0Addresses = Out0!["Addresses"] as? [String]
				let Out0Address = Out0Addresses?.first
				let Out0Amount = Out0!["Amount"] as? Double
				
				let Out1 = OutSorted![1] as? [String: Any]
				let Out1Addresses = Out1!["Addresses"] as? [String]
				let Out1Address = Out1Addresses?.first
				let Out1Amount = Out1!["Amount"] as? Double
				
				let addr = directionInput ? Out0Address : Out1Address
				let amount = directionInput ? Out0Amount : Out1Amount
				if addrs.contains(addr!) {
					return HistoryItem(type: .Incoming, date: txDate, amount: amount! / Double(100000000))
				} else {
					//if addrs.contains(Out1Address!) {
					//	return HistoryItem(type: .Incoming, date: txDate, amount: Out1Amount! / Double(100000000))
					//} else {
						return HistoryItem(type: .Outgoing, date: txDate, amount: amount! / Double(100000000))
					//}
				}
			}
			
			return HistoryItem(type: .Outgoing, date: txDate, amount: txAmount)
		})
	}
}
