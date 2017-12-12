//
//  sibTransaction.swift
//  sib-lite
//
//  Created by Иван Алексеев on 04.12.2017.
//  Copyright © 2017 NETTRASH. All rights reserved.
//

import Foundation
import UIKit
import CommonCrypto

class sibTransaction : NSObject {
	
	var version: UInt32 = 1
	var lock_time: UInt32 = 0
	
	var Input: [sibTransactionInput] = []
	var Output: [sibTransactionOutput] = []
	
	var Timestamp: Int? = nil
	var Block: String? = nil
	
	var Change: Wallet? = nil
	
	override init() {
		super.init()
		DispatchQueue.main.sync {
			let app = UIApplication.shared.delegate as! AppDelegate
			self.Change = Wallet(app)
		}
	}
	
	func addOutput(address: String, amount: Double) -> Void {
		let value = BigInteger(Int(amount * pow(10, 8)))
		let script: [UInt8] = sibAddress.spendToScript(address)
		Output.append(sibTransactionOutput(script, value))
	}
	
	func addInput(_ tx: UnspentTransaction) -> Void {
		Input.append(sibTransactionInput(tx.txid, tx.N, tx.Script, lock_time))
	}
	
	func addChange(amount summa: Double) -> Void {
		var a: Double = 0
		for o in Output {
			a += Double(o.Amount.intValue()) / pow(10, 8)
		}
		Change!.initialize("NETTRASHiOSChange\(version)\(Input.count)\(Output.count)\(a)")
		//Сохранять адрес для сдачи надо после успешной отправки в сеть
		//let app = UIApplication.shared.delegate as! AppDelegate
		//app.model!.storeWallet(Change!, false, .Change)
		addOutput(address: Change!.Address!, amount: summa)
	}
	
	func sign(_ key: Data) -> Void {
		
	}
	
	func serialize() -> Data {
		var data = [UInt8]()
		data.append(contentsOf: Convert.toByteArray(version))
		
		data.append(contentsOf: Convert.toVarIntByteArray(UInt64(Input.count)))
		for i in Input {
			data.append(contentsOf: i.outPoint.Hash.hexa2Bytes.reversed())
			data.append(contentsOf: Convert.toByteArray(UInt32(i.outPoint.Index)))
			data.append(contentsOf: Convert.toVarIntByteArray(UInt64(i.Script.count)))
			data.append(contentsOf: i.Script)
			data.append(contentsOf: Convert.toByteArray(UInt32(i.Sequence)))
		}
		
		data.append(contentsOf: Convert.toVarIntByteArray(UInt64(Output.count)))
		for o in Output {
			data.append(contentsOf: Convert.toByteArray(UInt64(o.Amount.intValue())))
			data.append(contentsOf: Convert.toVarIntByteArray(UInt64(o.ScriptedAddress.count)))
			data.append(contentsOf: o.ScriptedAddress)
		}
		
		data.append(contentsOf: Convert.toByteArray(UInt32(lock_time)))
		
		return Data(data)
	}
}
