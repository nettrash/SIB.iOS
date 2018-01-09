//
//  SettingsViewController.swift
//  sib-lite
//
//  Created by Иван Алексеев on 26.12.2017.
//  Copyright © 2017 NETTRASH. All rights reserved.
//

import Foundation
import UIKit
import MobileCoreServices

class SettingsViewController : BaseViewController, UIDocumentPickerDelegate {

	var app = UIApplication.shared.delegate as! AppDelegate
	
	@IBOutlet var vWait: UIView!
	@IBOutlet var scCurrency: UISegmentedControl!
	
	override func viewDidLoad() {
		super.viewDidLoad()
	}
	
	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
		vWait.isHidden = true
		
		switch app.model!.currency {
		case .RUB:
			scCurrency.selectedSegmentIndex = 0
			break
		case .USD:
			scCurrency.selectedSegmentIndex = 1
			break
		case .EUR:
			scCurrency.selectedSegmentIndex = 2
			break
		}
	}
	
	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}
	
	@IBAction func scCurrencyValueChanged(_ sender: Any?) {
		switch scCurrency.selectedSegmentIndex {
		case 0:
			app.model!.setCurrency(.RUB)
			break
		case 1:
			app.model!.setCurrency(.USD)
			break
		case 2:
			app.model!.setCurrency(.EUR)
			break
		default:
			app.model!.setCurrency(.RUB)
			break
		}
	}
	
	@IBAction func closeClick(_ sender: Any?) -> Void {
		performSegue(withIdentifier: unwindIdentifiers["settings-sib"]!, sender: self)
	}

	@IBAction func shareKeys(_ sender: Any?) -> Void {
	
		self.vWait.isHidden = false
		
		let alert = UIAlertController.init(title: NSLocalizedString("EncryptTitle", comment: "Шифрование"), message: NSLocalizedString("EncryptMessage", comment: "Шифрование"), preferredStyle: UIAlertControllerStyle.alert)
		alert.addTextField(configurationHandler: configurationTextField)
		alert.addAction(UIAlertAction.init(title: NSLocalizedString("OK", comment: "OK"), style: UIAlertActionStyle.cancel, handler: { _ in
			
			let psw = alert.textFields![0].text ?? ""
			
			if psw != "" {
				let app = UIApplication.shared.delegate as! AppDelegate
				var json: [String: Any] = [:]
				let v = app.model!.Addresses.map { "\($0.type)" + ($0.privateKey as Data).base64EncodedString().aesEncrypt(key: psw, iv: "20219510518024419136177230")! }
				var hs = ""
				for s in v { hs = hs + s }
				hs = hs + psw
				let hash = Crypto.sha256(hs.data(using: String.Encoding.utf8)!).base64EncodedString()
				json["version"] = "1.0"
				json["hash"] = hash
				json["keys"] = v
				let jsonData = try? JSONSerialization.data(withJSONObject: json)
				let urlToShare = jsonData?.fileUrl(withName: "keys.sib")

				self.vWait.isHidden = true

				DispatchQueue.main.asyncAfter(deadline: .now(), execute: {
					if urlToShare != nil {
						self.shareUrl(urlToShare!)
					}
				})
				
			} else {
				self.vWait.isHidden = true
				alert.dismiss(animated: true, completion: nil)
			}
		}))
		self.present(alert, animated: true, completion: nil)

	}

	func configurationTextField(textField: UITextField!) {
		textField.placeholder = NSLocalizedString("Key", comment: "Key")
		textField.isSecureTextEntry = true
	}

	@IBAction func loadKeys(_ sender: Any?) -> Void {
		self.vWait.isHidden = false
		
		let dpvc = UIDocumentPickerViewController(documentTypes: [String(kUTTypeData)], in: .import)
		dpvc.allowsMultipleSelection = false
		dpvc.delegate = self
		present(dpvc, animated: true, completion: nil)
	}
	
	//UIDocumentPickerDelegateb
	
	public func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
		let file: Data? = try? Data.init(contentsOf: urls[0], options: .uncachedRead)
		if file != nil {
			let jsonData = try? JSONSerialization.jsonObject(with: file!, options: JSONSerialization.ReadingOptions.mutableContainers)
			
			if jsonData != nil {
				let alert = UIAlertController.init(title: NSLocalizedString("EncryptTitle", comment: "Шифрование"), message: NSLocalizedString("EncryptMessage", comment: "Шифрование"), preferredStyle: UIAlertControllerStyle.alert)
				alert.addTextField(configurationHandler: configurationTextField)
				alert.addAction(UIAlertAction.init(title: NSLocalizedString("OK", comment: "OK"), style: UIAlertActionStyle.cancel, handler: { _ in
					
					let psw = alert.textFields![0].text ?? ""
					
					if psw != "" {
						let json = jsonData as? [String:Any]
						if json!["version"] as? String ?? "" == "1.0" {
							let hash = json!["hash"] as! String
							let v = json!["keys"] as! [String]
							
							var hs = ""
							for s in v { hs = hs + s }
							hs = hs + psw
							let hashFile = Crypto.sha256(hs.data(using: String.Encoding.utf8)!).base64EncodedString()
							
							if hashFile == hash {
								let app = UIApplication.shared.delegate as! AppDelegate
								for sKey in v {
									let keyType = Int16(String(sKey[String.Index(encodedOffset: 0)]))
									let keyData = String(sKey[String.Index(encodedOffset: 1)..<String.Index(encodedOffset: sKey.count)])
									let privKey = Data(base64Encoded: keyData.aesDecrypt(key: psw, iv: "20219510518024419136177230")!)!
									let w: Wallet = Wallet.init(privateKey: privKey)
									app.model!.storeWallet(w, false, keyType! == 0 ? .Incoming : .Change)
								}
								app.model!.save(app)
								app.model!.reload(app)

								let alert = UIAlertController.init(title: NSLocalizedString("KeyStoreImportTitle", comment: "Ключи"), message: NSLocalizedString("KeyStoreImportMessage", comment: "Ключи"), preferredStyle: UIAlertControllerStyle.alert)
								alert.addAction(UIAlertAction.init(title: NSLocalizedString("OK", comment: "OK"), style: UIAlertActionStyle.cancel, handler: nil))
								self.present(alert, animated: true, completion: nil)

							} else {
								let alert = UIAlertController.init(title: NSLocalizedString("EncryptTitle", comment: "Шифрование"), message: NSLocalizedString("EncryptPasswordErrorMessage", comment: "Шифрование"), preferredStyle: UIAlertControllerStyle.alert)
								alert.addAction(UIAlertAction.init(title: NSLocalizedString("OK", comment: "OK"), style: UIAlertActionStyle.cancel, handler: nil))
								self.present(alert, animated: true, completion: nil)
							}
							DispatchQueue.main.sync {
								self.vWait.isHidden = true
							}
						}
					}
				}))
				present(alert, animated: true, completion: nil)
			}
		}
	}

}
