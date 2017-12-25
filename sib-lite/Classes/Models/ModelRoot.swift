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
		return Addresses.filter { $0.type == sibWalletType.Incoming.rawValue }
	}
	
	public var AddressesForGetChange: [Address] {
		return Addresses.filter { $0.type == sibWalletType.Change.rawValue }
	}

	public var Balance: Double = 0
	
	public var isRefresh: Bool = false
	public var isHistoryRefresh: Bool = false
	public var isCurrentRatesRefresh: Bool = false
	
	public var Dimension: BalanceDimension = .SIB
	public var HistoryItems: History = History()
	public var MemoryPool: MemPool = MemPool()
	public var CurrentRates: Rates = Rates()
	
	public var SIB: Wallet?
	
	public var needNewAddress: Bool = false
	
	public var sellRate: Double = 0
	public var buyRate: Double = 0
	public var buyRedirectUrl: String = ""
	public var buyState: String = ""

	init(_ app: AppDelegate) {
		super.init()
		SIB = Wallet()
		reload(app)
	}
	
	func reload(_ app: AppDelegate) -> Void {
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
	
	func refresh() -> Void {
		_loadBalanceData()
	}
	
	func refreshRates() -> Void {
		_loadCurrentRatesData()
	}
	
	func refreshHistory() -> Void {
		_loadHistoryData()
	}
	
	func getSellRate(_ currency: String) -> Void {
		_getSellRate(currency)
	}
	
	func getBuyRate(_ currency: String) -> Void {
		_getBuyRate(currency)
	}

	func sell(_ currency: String, _ amountSIB: Double, _ amount: Double, _ pan: String) -> Void {
		_processSell(currency, amountSIB, amount, pan)
	}
	
	func buy(_ currency: String, _ amountSIB: Double, _ amount: Double, _ pan: String, _ exp: String, _ cvv: String) -> Void {
		_processBuy(currency, amountSIB, amount, pan, exp, cvv)
	}
	
	private func _processSell(_ currency: String, _ amountSIB: Double, _ amount: Double, _ pan: String) -> Void {
		//PaymentServicePassword 70FD2005-B198-4CE2-A5AE-CB93E4F99211
		DispatchQueue.global().async {
			// prepare auth data
			let ServiceName = "SIB"
			let ServiceSecret = "E0FB115E-80D8-4F4E-9701-E655AF9E84EB"
			let md5src = "\(ServiceName)\(ServiceSecret)"
			let md5digest = Crypto.md5(md5src)
			let ServicePassword = md5digest.map { String(format: "%02hhx", $0) }.joined()
			let base64Data = "\(ServiceName):\(ServicePassword)".data(using: String.Encoding.utf8)?.base64EncodedString(options: Data.Base64EncodingOptions.init(rawValue: 0))
			
			// prepare json data
			var json: [String:Any] = ["account": self.Addresses[0].address]
			json["pan"] = pan
			json["amountSIB"] = amountSIB
			json["amount"] = amount
			json["currency"] = currency
			
			let jsonData = try? JSONSerialization.data(withJSONObject: json)
			
			// create post request
			let url = URL(string: "https://api.sib.moe/wallet/sib.svc/registerSell")!
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
					self.isRefresh = false
					self.delegate?.sellComplete()
					return
				}
				let responseString = String(data: data, encoding: String.Encoding.utf8)
				print(responseString ?? "nil")
				let responseJSON = try? JSONSerialization.jsonObject(with: data, options: [])
				if let responseJSON = responseJSON as? [String: [String: Any]] {
					print(responseJSON)
					if responseJSON["RegisterSellResult"]?["Success"] as? Bool ?? false{
						let Address = responseJSON["RegisterSellResult"]!["Address"] as! String
						DispatchQueue.global().async {
							// prepare auth data
							let ServiceName = "SIB"
							let ServiceSecret = "E0FB115E-80D8-4F4E-9701-E655AF9E84EB"
							let md5src = "\(ServiceName)\(ServiceSecret)"
							let md5digest = Crypto.md5(md5src)
							let ServicePassword = md5digest.map { String(format: "%02hhx", $0) }.joined()
							let base64Data = "\(ServiceName):\(ServicePassword)".data(using: String.Encoding.utf8)?.base64EncodedString(options: Data.Base64EncodingOptions.init(rawValue: 0))
							
							// prepare json data
							let json: [String:Any] = ["addresses": self.Addresses.map { (_ a: Address) -> String in
								a.address
								}]
							
							let jsonData = try? JSONSerialization.data(withJSONObject: json)
							
							// create post request
							let url = URL(string: "https://api.sib.moe/wallet/sib.svc/unspentTransactions")!
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
									self.delegate?.sellComplete()
									return
								}
								let responseString = String(data: data, encoding: String.Encoding.utf8)
								print(responseString ?? "nil")
								let responseJSON = try? JSONSerialization.jsonObject(with: data, options: [])
								if let responseJSON = responseJSON as? [String: [String: Any]] {
									print(responseJSON)
									let txsResponse = responseJSON["UnspentTransactionsResult"]!
									let unspent = Unspent()
									if txsResponse["Success"] as? Bool ?? false {
										let txs = txsResponse["Items"] as? [Any]
										if (txs != nil) {
											unspent.load(txs!)
										}
										//Готовим транзакцию и отправляем ее
										let tx: sibTransaction = sibTransaction()
										//Добавляем требуемый вывод
										tx.addOutput(address: Address, amount: amountSIB)
										var spent: Double = 0
										//Добавляем непотраченные входы
										for u in unspent.Items {
											if spent < amountSIB + 0.0001 {
												spent += u.amount
												tx.addInput(u)
											} else {
												break;
											}
										}
										tx.addChange(amount: spent - amountSIB - 0.0001)
										self.storeWallet(tx.Change!, true, .Change) //В слычае неуспеха отправки надо удалять
										let sign = tx.sign(self.Addresses)
										print(sign.hexEncodedString())
										//Отправляем sign как rawtx
										self.broadcastTransaction(sign)
										self.delegate?.sellComplete()
									}
								}
							}
							task.resume()
						}
					}
				}
			}
			
			if (!self.isRefresh) {
				self.isRefresh = true
				self.delegate?.sellStart()
			}
			
			task.resume()
		}
	}
	
	private func _processBuy(_ currency: String, _ amountSIB: Double, _ amount: Double, _ pan: String, _ exp: String, _ cvv: String) -> Void {
		//PaymentServicePassword 70FD2005-B198-4CE2-A5AE-CB93E4F99211
		DispatchQueue.global().async {
			// prepare auth data
			let ServiceName = "SIB"
			let ServiceSecret = "E0FB115E-80D8-4F4E-9701-E655AF9E84EB"
			let md5src = "\(ServiceName)\(ServiceSecret)"
			let md5digest = Crypto.md5(md5src)
			let ServicePassword = md5digest.map { String(format: "%02hhx", $0) }.joined()
			let base64Data = "\(ServiceName):\(ServicePassword)".data(using: String.Encoding.utf8)?.base64EncodedString(options: Data.Base64EncodingOptions.init(rawValue: 0))
			
			// prepare json data
			var json: [String:Any] = ["account": self.Addresses[0].address]
			json["pan"] = pan
			json["exp"] = exp
			json["cvv"] = cvv
			json["amountSIB"] = amountSIB
			json["amount"] = amount
			json["currency"] = currency
			json["address"] = self.AddressesForIncoming[self.AddressesForIncoming.count - 1].address
			
			let jsonData = try? JSONSerialization.data(withJSONObject: json)
			
			// create post request
			let url = URL(string: "https://api.sib.moe/wallet/sib.svc/registerBuy")!
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
					self.isRefresh = false
					self.buyRedirectUrl = ""
					self.buyState = ""
					self.delegate?.buyComplete()
					return
				}
				let responseString = String(data: data, encoding: String.Encoding.utf8)
				print(responseString ?? "nil")
				let responseJSON = try? JSONSerialization.jsonObject(with: data, options: [])
				if let responseJSON = responseJSON as? [String: [String: Any]] {
					print(responseJSON)
					if responseJSON["RegisterBuyResult"]?["Success"] as? Bool ?? false {
						self.buyRedirectUrl = responseJSON["RegisterBuyResult"]!["RedirectUrl"] as! String
						self.buyState = responseJSON["RegisterBuyResult"]!["State"] as! String
						self.delegate?.buyComplete()
					}
				}
			}
			
			if (!self.isRefresh) {
				self.isRefresh = true
				self.delegate?.buyStart()
			}
			
			task.resume()
		}
	}
	
	private func _loadBalanceData() -> Void {
		DispatchQueue.global().async {
			// prepare auth data
			let ServiceName = "SIB"
			let ServiceSecret = "E0FB115E-80D8-4F4E-9701-E655AF9E84EB"
			let md5src = "\(ServiceName)\(ServiceSecret)"
			let md5digest = Crypto.md5(md5src)
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
					self.isRefresh = false
					self.delegate?.stopBalanceUpdate(error: error?.localizedDescription ?? "No data")
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
					self.delegate?.stopBalanceUpdate(error: nil)
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
	
	private func _loadTransactionsData() -> Void {
		DispatchQueue.global().async {
			// prepare auth data
			let ServiceName = "SIB"
			let ServiceSecret = "E0FB115E-80D8-4F4E-9701-E655AF9E84EB"
			let md5src = "\(ServiceName)\(ServiceSecret)"
			let md5digest = Crypto.md5(md5src)
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
					self._loadMemoryPoolData()
				}
			}
			
			if (!self.isHistoryRefresh) {
				self.isHistoryRefresh = true
				self.delegate?.startHistoryUpdate()
			}
			
			task.resume()
		}
	}
	
	private func _loadHistoryData() -> Void {
		DispatchQueue.global().async {
			// prepare auth data
			let ServiceName = "SIB"
			let ServiceSecret = "E0FB115E-80D8-4F4E-9701-E655AF9E84EB"
			let md5src = "\(ServiceName)\(ServiceSecret)"
			let md5digest = Crypto.md5(md5src)
			let ServicePassword = md5digest.map { String(format: "%02hhx", $0) }.joined()
			let base64Data = "\(ServiceName):\(ServicePassword)".data(using: String.Encoding.utf8)?.base64EncodedString(options: Data.Base64EncodingOptions.init(rawValue: 0))
			
			// prepare json data
			var json: [String:Any] = ["addresses": self.Addresses.map { (_ a: Address) -> String in
				a.address
				}]
			json["last"] = 1000
			
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

	private func _loadMemoryPoolData() -> Void {
		DispatchQueue.global().async {
			// prepare auth data
			let ServiceName = "SIB"
			let ServiceSecret = "E0FB115E-80D8-4F4E-9701-E655AF9E84EB"
			let md5src = "\(ServiceName)\(ServiceSecret)"
			let md5digest = Crypto.md5(md5src)
			let ServicePassword = md5digest.map { String(format: "%02hhx", $0) }.joined()
			let base64Data = "\(ServiceName):\(ServicePassword)".data(using: String.Encoding.utf8)?.base64EncodedString(options: Data.Base64EncodingOptions.init(rawValue: 0))
			
			// prepare json data
			let json: [String:Any] = ["addresses": self.Addresses.map { (_ a: Address) -> String in
				a.address
				}]
			
			let jsonData = try? JSONSerialization.data(withJSONObject: json)
			
			// create post request
			let url = URL(string: "https://api.sib.moe/wallet/sib.svc/mempool")!
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
					let mpResponse = responseJSON["MemoryPoolResult"]!
					let mempoolItems = mpResponse["Items"] as? [Any]
					if (mempoolItems != nil) {
						self.MemoryPool.load(mempoolItems!, addresses: self.Addresses)
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
	
	private func _needNewAddressCheck() -> Void {
		DispatchQueue.global().async {
			// prepare auth data
			let ServiceName = "SIB"
			let ServiceSecret = "E0FB115E-80D8-4F4E-9701-E655AF9E84EB"
			let md5src = "\(ServiceName)\(ServiceSecret)"
			let md5digest = Crypto.md5(md5src)
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

	
	private func _getSellRate(_ currency: String) -> Void {
		DispatchQueue.global().async {
			// prepare auth data
			let ServiceName = "SIB"
			let ServiceSecret = "E0FB115E-80D8-4F4E-9701-E655AF9E84EB"
			let md5src = "\(ServiceName)\(ServiceSecret)"
			let md5digest = Crypto.md5(md5src)
			let ServicePassword = md5digest.map { String(format: "%02hhx", $0) }.joined()
			let base64Data = "\(ServiceName):\(ServicePassword)".data(using: String.Encoding.utf8)?.base64EncodedString(options: Data.Base64EncodingOptions.init(rawValue: 0))
			
			// prepare json data
			let json: [String:String] = ["currency": currency]
			
			let jsonData = try? JSONSerialization.data(withJSONObject: json)
			
			// create post request
			let url = URL(string: "https://api.sib.moe/wallet/sib.svc/sellRate")!
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
				if let responseJSON = responseJSON as? [String: [String: Any]] {
					print(responseJSON)
					//Обрабатываем результат
					if responseJSON["SellRateResult"]?["Success"] as! Bool {
						self.sellRate = responseJSON["SellRateResult"]!["Rate"] as! Double
						self.delegate?.updateSellRate()
					}
				}
			}
			
			task.resume()
		}
	}
	
	private func _getBuyRate(_ currency: String) -> Void {
		DispatchQueue.global().async {
			// prepare auth data
			let ServiceName = "SIB"
			let ServiceSecret = "E0FB115E-80D8-4F4E-9701-E655AF9E84EB"
			let md5src = "\(ServiceName)\(ServiceSecret)"
			let md5digest = Crypto.md5(md5src)
			let ServicePassword = md5digest.map { String(format: "%02hhx", $0) }.joined()
			let base64Data = "\(ServiceName):\(ServicePassword)".data(using: String.Encoding.utf8)?.base64EncodedString(options: Data.Base64EncodingOptions.init(rawValue: 0))
			
			// prepare json data
			let json: [String:String] = ["currency": currency]
			
			let jsonData = try? JSONSerialization.data(withJSONObject: json)
			
			// create post request
			let url = URL(string: "https://api.sib.moe/wallet/sib.svc/buyRate")!
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
				if let responseJSON = responseJSON as? [String: [String: Any]] {
					print(responseJSON)
					//Обрабатываем результат
					if responseJSON["BuyRateResult"]!["Success"] as! Bool {
						self.buyRate = responseJSON["BuyRateResult"]?["Rate"] as! Double
						self.delegate?.updateBuyRate()
					}
				}
			}
			
			task.resume()
		}
	}

	public func getUnspentData() -> Void {
		DispatchQueue.global().async {
			// prepare auth data
			let ServiceName = "SIB"
			let ServiceSecret = "E0FB115E-80D8-4F4E-9701-E655AF9E84EB"
			let md5src = "\(ServiceName)\(ServiceSecret)"
			let md5digest = Crypto.md5(md5src)
			let ServicePassword = md5digest.map { String(format: "%02hhx", $0) }.joined()
			let base64Data = "\(ServiceName):\(ServicePassword)".data(using: String.Encoding.utf8)?.base64EncodedString(options: Data.Base64EncodingOptions.init(rawValue: 0))
			
			// prepare json data
			let json: [String:Any] = ["addresses": self.Addresses.map { (_ a: Address) -> String in
				a.address
				}]
			
			let jsonData = try? JSONSerialization.data(withJSONObject: json)
			
			// create post request
			let url = URL(string: "https://api.sib.moe/wallet/sib.svc/unspentTransactions")!
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
					self.delegate?.unspetData(Unspent()) //Надо подумать над методом ошибки получения непотраченных
					return
				}
				let responseString = String(data: data, encoding: String.Encoding.utf8)
				print(responseString ?? "nil")
				let responseJSON = try? JSONSerialization.jsonObject(with: data, options: [])
				if let responseJSON = responseJSON as? [String: [String: Any]] {
					print(responseJSON)
					let txsResponse = responseJSON["UnspentTransactionsResult"]!
					let unspent = Unspent()
					if txsResponse["Success"] as? Bool ?? false {
						let txs = txsResponse["Items"] as? [Any]
						if (txs != nil) {
							unspent.load(txs!)
						}
					}
					self.delegate?.unspetData(unspent)
				}
			}
			task.resume()
		}
	}

	public func broadcastTransaction(_ data: Data) -> Void {
		DispatchQueue.global().async {
			// prepare auth data
			let ServiceName = "SIB"
			let ServiceSecret = "E0FB115E-80D8-4F4E-9701-E655AF9E84EB"
			let md5src = "\(ServiceName)\(ServiceSecret)"
			let md5digest = Crypto.md5(md5src)
			let ServicePassword = md5digest.map { String(format: "%02hhx", $0) }.joined()
			let base64Data = "\(ServiceName):\(ServicePassword)".data(using: String.Encoding.utf8)?.base64EncodedString(options: Data.Base64EncodingOptions.init(rawValue: 0))
			
			// prepare json data
			let json: [String:String] = ["rawtx": data.base64EncodedString()]
			
			let jsonData = try? JSONSerialization.data(withJSONObject: json)
			
			// create post request
			let url = URL(string: "https://api.sib.moe/wallet/sib.svc/broadcastTransaction")!
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
					self.delegate?.broadcastTransactionResult(false, nil, nil)
					return
				}
				let responseString = String(data: data, encoding: String.Encoding.utf8)
				print(responseString ?? "nil")
				let responseJSON = try? JSONSerialization.jsonObject(with: data, options: [])
				if let responseJSON = responseJSON as? [String: [String: Any]] {
					print(responseJSON)
					let txsResponse = responseJSON["BroadcastTransactionResult"]!
					let result: Bool = txsResponse["Success"] as? Bool ?? false
					var txid: String? = nil
					var msg: String? = nil
					if result {
						txid = txsResponse["TransactionId"] as? String
					} else {
						msg = txsResponse["Message"] as? String
					}
					self.delegate?.broadcastTransactionResult(result, txid, msg)
				} else {
					self.delegate?.broadcastTransactionResult(false, nil, nil)
				}
			}
			task.resume()
		}
	}

	private func _loadCurrentRatesData() -> Void {
		DispatchQueue.global().async {
			// prepare auth data
			let ServiceName = "SIB"
			let ServiceSecret = "E0FB115E-80D8-4F4E-9701-E655AF9E84EB"
			let md5src = "\(ServiceName)\(ServiceSecret)"
			let md5digest = Crypto.md5(md5src)
			let ServicePassword = md5digest.map { String(format: "%02hhx", $0) }.joined()
			let base64Data = "\(ServiceName):\(ServicePassword)".data(using: String.Encoding.utf8)?.base64EncodedString(options: Data.Base64EncodingOptions.init(rawValue: 0))
			
			// prepare json data
			var json: [String:Any] = ["addresses": self.Addresses.map { (_ a: Address) -> String in
				a.address
				}]
			json["last"] = 3
			
			let jsonData = try? JSONSerialization.data(withJSONObject: json)
			
			// create post request
			let url = URL(string: "https://api.sib.moe/wallet/sib.svc/currentRates")!
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
					let ratesResponse = responseJSON["CurrentRatesResult"]!
					let rates = ratesResponse["Items"] as? [Any]
					if (rates != nil) {
						self.CurrentRates.load(rates!)
					}
					//Инициализируем историю
					self.delegate?.stopCurrentRatesUpdate()
					self.isCurrentRatesRefresh = false
				}
			}
			
			if (!self.isCurrentRatesRefresh) {
				self.isCurrentRatesRefresh = true
				self.delegate?.startCurrentRatesUpdate()
			}
			
			task.resume()
		}
	}
	
	func storeWallet(_ wallet: Wallet, _ refresh: Bool = true, _ walletType: sibWalletType = .Incoming) -> Void {
		add(wallet.PrivateKey!, wallet.PublicKey!, wallet.Address!, wallet.WIF!, wallet.Compressed, refreshAfter: refresh, walletType: walletType)
	}
	
	func add(_ privateKey: Data, _ publicKey: Data, _ address: String, _ wif: String, _ compressed: Bool, refreshAfter: Bool = true, walletType: sibWalletType = .Incoming) -> Void {
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
		a.type = walletType.rawValue
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
}

protocol ModelRootDelegate {
	func startBalanceUpdate()
	func stopBalanceUpdate(error: String?)
	func startHistoryUpdate()
	func stopHistoryUpdate()
	func startCurrentRatesUpdate()
	func stopCurrentRatesUpdate()
	func unspetData(_ data: Unspent)
	func broadcastTransactionResult(_ result: Bool, _ txid: String?, _ message: String?)
	func sellStart()
	func sellComplete()
	func updateSellRate()
	func buyStart()
	func buyComplete()
	func updateBuyRate()
}

