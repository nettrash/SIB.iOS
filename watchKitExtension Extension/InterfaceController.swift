//
//  InterfaceController.swift
//  watchKitExtension Extension
//
//  Created by Иван Алексеев on 13.01.2018.
//  Copyright © 2018 NETTRASH. All rights reserved.
//

import WatchKit
import Foundation
import CoreData

class InterfaceController: WKInterfaceController {

	static var persistentContainer: PersistentContainer = {
		let container = PersistentContainer(name: "sib_lite")
		container.loadPersistentStores(completionHandler: { (storeDescription:NSPersistentStoreDescription, error:Error?) in
			if let error = error as NSError?{
				fatalError("UnResolved error \(error), \(error.userInfo)")
			}
		})
		
		return container
	}()
	
	var balance: BalanceResponse?
	@IBOutlet var lblBalance: WKInterfaceLabel!
	@IBOutlet var imgLogo: WKInterfaceImage!
	@IBOutlet var imgBack: WKInterfaceImage!
	
	static func md5(_ string: String) -> Data {
		let messageData = string.data(using:.utf8)!
		var digestData = Data(count: Int(CC_MD5_DIGEST_LENGTH))
		
		_ = digestData.withUnsafeMutableBytes {digestBytes in
			messageData.withUnsafeBytes {messageBytes in
				CC_MD5(messageBytes, CC_LONG(messageData.count), digestBytes)
			}
		}
		
		return digestData
	}
	
	override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        
        // Configure interface objects here.
		self.imgBack.setImage(UIImage(named: "WKBackground"))
		self.imgLogo.setImage(UIImage(named: NSLocalizedString("SIBLogoImageName", comment: "SIBLogoImageName")))
		self.lblBalance.setText("...")
    }
    
    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
		self.imgBack.setImage(UIImage(named: "WKBackground"))
		self.imgLogo.setImage(UIImage(named: NSLocalizedString("SIBLogoImageName", comment: "SIBLogoImageName")))
		self._loadBalanceData()
    }
    
    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }

	func _loadBalanceData() -> Void {
		// prepare auth data
		let ServiceName = "SIB"
		let ServiceSecret = "E0FB115E-80D8-4F4E-9701-E655AF9E84EB"
		let md5src = "\(ServiceName)\(ServiceSecret)"
		let md5digest = InterfaceController.md5(md5src)
		let ServicePassword = md5digest.map { String(format: "%02hhx", $0) }.joined()
		let base64Data = "\(ServiceName):\(ServicePassword)".data(using: String.Encoding.utf8)?.base64EncodedString(options: Data.Base64EncodingOptions.init(rawValue: 0))
		
		let moc = InterfaceController.persistentContainer.viewContext
		moc.refreshAllObjects()
		let Addresses = try! moc.fetch(Address.fetchRequest()) as! [Address]
		
		// prepare json data
		let json: [String:Any] = ["addresses": Addresses.map { (_ a: Address) -> String in
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
				self.lblBalance.setText("-")
				return
			}
			let responseString = String(data: data, encoding: String.Encoding.utf8)
			print(responseString ?? "nil")
			let responseJSON = try? JSONSerialization.jsonObject(with: data, options: [])
			if let responseJSON = responseJSON as? [String: [String: Any]] {
				print(responseJSON)
				self.balance = BalanceResponse.init(json: responseJSON["BalanceResult"]!)
				self.lblBalance.setText(String(format: "%.2f", Double(self.balance?.Value ?? 0) / Double(100000000.00)))
			}
		}
		
		task.resume()
	}
	
	/*func qrIncoming() {
		let moc = InterfaceController.persistentContainer.viewContext
		let Addresses = try! moc.fetch(Address.fetchRequest()) as! [Address]
		let AddressesForIncoming = Addresses.filter { $0.type == sibWalletType.Incoming.rawValue }
		let address = AddressesForIncoming[AddressesForIncoming.count-1].address
		
		let data = "sibcoin://\(address)".data(using: String.Encoding.ascii)
		let filter = CIFilter(name: "CIQRCodeGenerator")
		
		filter!.setValue(data, forKey: "inputMessage")
		filter!.setValue("Q", forKey: "inputCorrectionLevel")
		
		let qrcodeImage = filter!.outputImage
		
		let scaleX = imgQR.frame.size.width / qrcodeImage!.extent.size.width
		let scaleY = imgQR.frame.size.height / qrcodeImage!.extent.size.height
		
		let transformedImage = qrcodeImage!.transformed(by: CGAffineTransform(scaleX: scaleX, y: scaleY))
		
		imgQR.setImage(UIImage(ciImage: transformedImage))
	}*/

}
