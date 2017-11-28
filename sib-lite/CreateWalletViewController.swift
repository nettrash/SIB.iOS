//
//  CreateWalletViewController.swift
//  sib-lite
//
//  Created by Иван Алексеев on 12.11.2017.
//  Copyright © 2017 NETTRASH. All rights reserved.
//

import UIKit

class CreateWalletViewController: BaseViewController, UITextFieldDelegate {
	
	@IBOutlet var textFieldSecret: UITextField!

	override func viewDidLoad() {
		super.viewDidLoad()
		
		for v in self.view.subviews {
			if (v is UIButton) {
				v.layer.cornerRadius = 4
			}
		}
	}
	
	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
		textFieldSecret.becomeFirstResponder()
	}
	
	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}
	
	@IBAction func createClick(_ sender: Any?) -> Void {
		registerWallet()
	}
	
	func registerWallet() -> Void {
		let app: AppDelegate = UIApplication.shared.delegate as! AppDelegate
		app.model!.SIB?.initialize(textFieldSecret.text!)
	}
	
	// UITextFieldDelegate
	public func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
		return true;
	}
	
	public func textFieldDidBeginEditing(_ textField: UITextField) {
		
	}
	
	public func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
		return true;
	}
	
	public func textFieldDidEndEditing(_ textField: UITextField) {
		
	}
	
	public func textFieldDidEndEditing(_ textField: UITextField, reason: UITextFieldDidEndEditingReason) {
		
	}
	
	public func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
		let textFieldText: NSString = (textField.text ?? "") as NSString
		let txtAfterUpdate = textFieldText.replacingCharacters(in: range, with: string)
		
		return true;
	}
	
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
	}
	
	public func textFieldShouldClear(_ textField: UITextField) -> Bool {
		return true;
	}
	
	public func textFieldShouldReturn(_ textField: UITextField) -> Bool {
		
		if (sibAddress.verify(textField.text)) {
			performSegue(withIdentifier: unwindIdentifiers["create-wallet"]!, sender: self)
		}
		return false
	}
	
}
