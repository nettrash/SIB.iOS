//
//  Unspent.swift
//  sib-lite
//
//  Created by Иван Алексеев on 06.12.2017.
//  Copyright © 2017 NETTRASH. All rights reserved.
//

import Foundation

class Unspent: NSObject {
	
	var Items: [UnspentTransaction] = []
	
	func load(_ txs: [Any]) -> Void {
		Items = txs.map { (_ t: Any) -> UnspentTransaction in
			
			let tx = t as? [String: Any]
			let txid = tx!["Id"] as! String
			let amount = Double(tx!["Amount"] as! Int64) / Double(100000000)
			let address = tx!["Address"] as! String
			let n = tx!["N"] as! UInt32
			let script = tx!["Script"] as! String
			return UnspentTransaction(txid, amount, address, n, script)
			
		}
	}
	
}
