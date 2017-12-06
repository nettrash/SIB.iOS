//
//  ModelRoot.swift
//  sib-lite
//
//  Created by Иван Алексеев on 23.09.17.
//  Copyright © 2017 NETTRASH. All rights reserved.
//

import UIKit
import CoreData
import CommonCrypto

public class ModelRoot: NSObject {

	var delegate: ModelRootDelegate?
	
	public var Addresses: [Address] = [Address]()
	
	public var AddressesForIncoming: [Address] {
		return Addresses.filter { $0.type == 0 }
	}
	
	public var AddressesForGetChange: [Address] {
		return Addresses.filter { $0.type == 1 }
	}

	public var Balance: Double = 0
	
	public var isRefresh: Bool = false
	
	public var isHistoryRefresh: Bool = false
	
	public var Dimension: BalanceDimension = .SIB
	
	public var HistoryItems: History = History()
	
	public var SIB: Wallet?
	
	public var needNewAddress: Bool = false
	
	init(_ app: AppDelegate) {
		super.init()
		SIB = Wallet(app)
		reload(app)
	}
	
	func reload(_ app: AppDelegate) {
		do {
			let moc = app.persistentContainer.viewContext
			Addresses = try moc.fetch(Address.fetchRequest()) as! [Address]
			if (AddressesForIncoming.count > 0) {
				_needNewAddressCheck()
			}
		} catch {
			Addresses = [Address]()
		}
	}
	
	func refresh() {
		//Обновляем
		NSLog("%i", Addresses.count)
		//Запрашиваем дельту по адресам
		_loadBalanceData()
	}
	
	private func _loadBalanceData() {
		DispatchQueue.global().async {
			// prepare auth data
			let ServiceName = "SIB"
			let ServiceSecret = "E0FB115E-80D8-4F4E-9701-E655AF9E84EB"
			let d = Date()
			let dateFormatter = DateFormatter()
			dateFormatter.dateFormat = "yyyyMMddhh"
			dateFormatter.timeZone = TimeZone.init(secondsFromGMT: 0)
			let md5src = "\(ServiceName)\(ServiceSecret)\(dateFormatter.string(from: d))"
			let md5digest = self.MD5(md5src)
			let ServicePassword = md5digest.map { String(format: "%02hhx", $0) }.joined()
			let base64Data = "\(ServiceName):\(ServicePassword)".data(using: String.Encoding.utf8)?.base64EncodedString(options: Data.Base64EncodingOptions.init(rawValue: 0))
		
			// prepare json data
			let json: [String:Any] = ["addresses": self.Addresses.map { (_ a: Address) -> String in
				a.address
			}]
		
			let jsonData = try? JSONSerialization.data(withJSONObject: json)
		
			// create post request
			let url = URL(string: "https://api.sib.moe/wallet/sib.svc/balance")!
			var request = URLRequest(url: url)
			request.httpMethod = "POST"
			request.addValue("application/json", forHTTPHeaderField: "Content-Type")
			request.addValue("application/json", forHTTPHeaderField: "Accept")
			request.addValue("Basic \(base64Data ?? "")", forHTTPHeaderField: "Authorization")

			// insert json data to the request
			request.httpBody = jsonData
		
			let task = URLSession.shared.dataTask(with: request) { data, response, error in
				guard let data = data, error == nil else {
					print(error?.localizedDescription ?? "No data")
					self.delegate?.stopBalanceUpdate()
					self.isRefresh = false
					return
				}
				let responseString = String(data: data, encoding: String.Encoding.utf8)
				print(responseString ?? "nil")
				let responseJSON = try? JSONSerialization.jsonObject(with: data, options: [])
				if let responseJSON = responseJSON as? [String: [String: Any]] {
					print(responseJSON)
					let value = BalanceResponse.init(json: responseJSON["BalanceResult"]!)
					self.Balance = Double(value?.Value ?? 0) / Double(100000000.00)
					self.isRefresh = false
					self.delegate?.stopBalanceUpdate()
					DispatchQueue.main.async {
						//Запрашиваем историю
						self._loadTransactionsData()
					}
				}
			}
		
			if (!self.isRefresh) {
				self.isRefresh = true
				self.delegate?.startBalanceUpdate()
			}
			
			task.resume()
		}
	}
	
	private func _loadTransactionsData() {
		DispatchQueue.global().async {
			// prepare auth data
			let ServiceName = "SIB"
			let ServiceSecret = "E0FB115E-80D8-4F4E-9701-E655AF9E84EB"
			let d = Date()
			let dateFormatter = DateFormatter()
			dateFormatter.dateFormat = "yyyyMMddhh"
			dateFormatter.timeZone = TimeZone.init(secondsFromGMT: 0)
			let md5src = "\(ServiceName)\(ServiceSecret)\(dateFormatter.string(from: d))"
			let md5digest = self.MD5(md5src)
			let ServicePassword = md5digest.map { String(format: "%02hhx", $0) }.joined()
			let base64Data = "\(ServiceName):\(ServicePassword)".data(using: String.Encoding.utf8)?.base64EncodedString(options: Data.Base64EncodingOptions.init(rawValue: 0))
			
			// prepare json data
			var json: [String:Any] = ["addresses": self.Addresses.map { (_ a: Address) -> String in
				a.address
				}]
			json["last"] = 3
			
			let jsonData = try? JSONSerialization.data(withJSONObject: json)
			
			// create post request
			let url = URL(string: "https://api.sib.moe/wallet/sib.svc/transactions")!
			var request = URLRequest(url: url)
			request.httpMethod = "POST"
			request.addValue("application/json", forHTTPHeaderField: "Content-Type")
			request.addValue("application/json", forHTTPHeaderField: "Accept")
			request.addValue("Basic \(base64Data ?? "")", forHTTPHeaderField: "Authorization")
			
			// insert json data to the request
			request.httpBody = jsonData
			
			let task = URLSession.shared.dataTask(with: request) { data, response, error in
				guard let data = data, error == nil else {
					print(error?.localizedDescription ?? "No data")
					self.delegate?.stopHistoryUpdate()
					self.isHistoryRefresh = false
					return
				}
				let responseString = String(data: data, encoding: String.Encoding.utf8)
				print(responseString ?? "nil")
				let responseJSON = try? JSONSerialization.jsonObject(with: data, options: [])
				if let responseJSON = responseJSON as? [String: [String: Any]] {
					print(responseJSON)
					let txsResponse = responseJSON["TransactionsResult"]!
					let txs = txsResponse["Items"] as? [Any]
					if (txs != nil) {
						self.HistoryItems.load(txs!, addresses: self.Addresses)
					}
					//Инициализируем историю
					self.delegate?.stopHistoryUpdate()
					self.isHistoryRefresh = false
				}
			}
			
			if (!self.isHistoryRefresh) {
				self.isHistoryRefresh = true
				self.delegate?.startHistoryUpdate()
			}
			
			task.resume()
		}
	}

	private func _needNewAddressCheck() {
		DispatchQueue.global().async {
			// prepare auth data
			let ServiceName = "SIB"
			let ServiceSecret = "E0FB115E-80D8-4F4E-9701-E655AF9E84EB"
			let d = Date()
			let dateFormatter = DateFormatter()
			dateFormatter.dateFormat = "yyyyMMddhh"
			dateFormatter.timeZone = TimeZone.init(secondsFromGMT: 0)
			let md5src = "\(ServiceName)\(ServiceSecret)\(dateFormatter.string(from: d))"
			let md5digest = self.MD5(md5src)
			let ServicePassword = md5digest.map { String(format: "%02hhx", $0) }.joined()
			let base64Data = "\(ServiceName):\(ServicePassword)".data(using: String.Encoding.utf8)?.base64EncodedString(options: Data.Base64EncodingOptions.init(rawValue: 0))
			
			// prepare json data
			let json: [String:String] = ["address": self.AddressesForIncoming[self.AddressesForIncoming.count-1].address]
			
			let jsonData = try? JSONSerialization.data(withJSONObject: json)
			
			// create post request
			let url = URL(string: "https://api.sib.moe/wallet/sib.svc/hasInput")!
			var request = URLRequest(url: url)
			request.httpMethod = "POST"
			request.addValue("application/json", forHTTPHeaderField: "Content-Type")
			request.addValue("application/json", forHTTPHeaderField: "Accept")
			request.addValue("Basic \(base64Data ?? "")", forHTTPHeaderField: "Authorization")
			
			// insert json data to the request
			request.httpBody = jsonData
			
			let task = URLSession.shared.dataTask(with: request) { data, response, error in
				guard let data = data, error == nil else {
					print(error?.localizedDescription ?? "No data")
					return
				}
				let responseString = String(data: data, encoding: String.Encoding.utf8)
				print(responseString ?? "nil")
				let responseJSON = try? JSONSerialization.jsonObject(with: data, options: [])
				if let responseJSON = responseJSON as? [String: [String: Bool]] {
					print(responseJSON)
					//Обрабатываем результат
					if responseJSON["InputExistsResult"]?["Success"] ?? false {
						self.needNewAddress = responseJSON["InputExistsResult"]!["Exists"]!
					}
				}
			}
			
			task.resume()
		}
	}

	func storewallet() -> Void {
		add(self.SIB!.PrivateKey!, self.SIB!.PublicKey!, self.SIB!.Address!, self.SIB!.WIF!, self.SIB!.Compressed)
	}
	
	func add(_ privateKey: Data, _ publicKey: Data, _ address: String, _ wif: String, _ compressed: Bool, refreshAfter: Bool = true) {
		for  a in Addresses {
			if (a.address == address) { return }
		}
		let app = (UIApplication.shared.delegate as! AppDelegate)
		let moc = app.persistentContainer.viewContext
		let a = NSEntityDescription.insertNewObject(forEntityName: "Address", into: moc) as! Address
		a.privateKey = NSData.init(base64Encoded: privateKey.base64EncodedData())!
		a.publicKey = NSData.init(base64Encoded: publicKey.base64EncodedData())!
		a.address = address
		a.wif = wif
		a.compressed = compressed
		try! moc.save()
		if (refreshAfter) {
			reload(app)
			refresh()
		}
	}

	func setPIN(_ pin: String?) -> Void {
		if pin == nil { return }
		if pin!.count != 4 { return }
		let defs = UserDefaults.standard
		defs.set(pin, forKey: "PIN")
	}
	
	func existsPIN() -> Bool {
		let defs = UserDefaults.standard
		if let pin = defs.string(forKey: "PIN") {
			if pin.count == 4 {
				return true
			} else {
				return false
			}
		}
		return false
	}
	
	func checkPIN(_ epin: String) -> Bool {
		let defs = UserDefaults.standard
		if let pin = defs.string(forKey: "PIN") {
			if pin.count == 4 && pin == epin {
				return true
			} else {
				return false
			}
		}
		return false
	}

	func MD5(_ string: String) -> Data {
		let messageData = string.data(using:.utf8)!
		var digestData = Data(count: Int(CC_MD5_DIGEST_LENGTH))
		
		_ = digestData.withUnsafeMutableBytes {digestBytes in
			messageData.withUnsafeBytes {messageBytes in
				CC_MD5(messageBytes, CC_LONG(messageData.count), digestBytes)
			}
		}
		
		return digestData
	}
}

protocol ModelRootDelegate {
	func startBalanceUpdate()
	func stopBalanceUpdate()
	func startHistoryUpdate()
	func stopHistoryUpdate()
}
