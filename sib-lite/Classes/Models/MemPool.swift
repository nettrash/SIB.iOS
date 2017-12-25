//
//  MemPool.swift
//  sib-lite
//
//  Created by Иван Алексеев on 19.12.2017.
//  Copyright © 2017 NETTRASH. All rights reserved.
//

import Foundation

public class MemPool: NSObject {

	var Items: [MemPoolItem] = []
	
	override init() {
		super.init()
	}
	
	func load(_ mempool: [Any], addresses: [Address]) {
		let addrs = addresses.map { (_ a: Address) -> String in
			a.address
		}
		Items = mempool.map({ (_ t: Any) -> MemPoolItem in
			
			let mp = t as? [String: Any]
			let mpi = MemPoolItem()
			mpi.address = mp?["Address"] as? String
			mpi.txid = mp?["TransactionId"] as? String
			mpi.N = mp?["N"] as? Int
			mpi.value = mp?["Value"] as? Int64
			mpi.seconds = mp?["Seconds"] as? Int64
			mpi.prev_txid = mp?["PrevTransactionId"] as? String
			mpi.prev_N = mp?["PrevN"] as? Int
			mpi.isInput = mpi.value ?? 0 > 0//addrs.contains(mpi.address ?? "")

			return mpi
		})
	}

}
