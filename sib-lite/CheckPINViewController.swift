//
//  CheckPINViewController.swift
//  sib-lite
//
//  Created by Иван Алексеев on 29.11.2017.
//  Copyright © 2017 NETTRASH. All rights reserved.
//

import Foundation
import UIKit
import LocalAuthentication

class CheckPINViewController : BaseViewController, UITextFieldDelegate {
	
	var PIN0: String = ""
	var Checked: Bool = false
	var Count: Int = 0
	
	@IBOutlet var tfPIN0: UITextField!
	@IBOutlet var tfPIN1: UITextField!
	@IBOutlet var tfPIN2: UITextField!
	@IBOutlet var tfPIN3: UITextField!
	@IBOutlet var lblMode: UILabel!
	var authenticationContext: LAContext!
	
	override func viewDidLoad() {
		super.viewDidLoad()
		authenticationContext = LAContext()
	}
	
	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
		DispatchQueue.main.async {
			self.tryBiometric()
		}
	}
	
	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}
	
	func tryBiometric() -> Void {
		let err: NSErrorPointer = nil
		if authenticationContext.canEvaluatePolicy(LAPolicy.deviceOwnerAuthenticationWithBiometrics, error: err) {
			authenticationContext.evaluatePolicy(LAPolicy.deviceOwnerAuthenticationWithBiometrics, localizedReason: NSLocalizedString("BiometricPIN", comment: "BiometricInfo"), reply: { (_ result: Bool, _ err: Error?) in
					if result {
						self.checkPassed()
					} else {
						self.setupEnterPIN()
					}
			})
		} else {
			setupEnterPIN()
		}
	}
	
	func setupEnterPIN() -> Void {
		DispatchQueue.main.async {
			self.Count += 1
			self.Checked = false
			self.PIN0 = ""
			self.lblMode.text = NSLocalizedString("enterPIN", comment: "enterPIN")
			self.tfPIN0.text = ""
			self.tfPIN1.text = ""
			self.tfPIN2.text = ""
			self.tfPIN3.text = ""
			self.tfPIN0.becomeFirstResponder()
		}
	}
	
	func checkPassed() -> Void {
		Checked = true
		performSegue(withIdentifier: unwindIdentifiers["check-pin"]!, sender: self)
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
		if txtAfterUpdate.count != 1 { return false }
		if textField == tfPIN0 {
			tfPIN0.text = "0"
			PIN0 = PIN0 + txtAfterUpdate
			tfPIN1.becomeFirstResponder()
			return false
		}
		if textField == tfPIN1 {
			tfPIN1.text = "0"
			PIN0 = PIN0 + txtAfterUpdate
			tfPIN2.becomeFirstResponder()
			return false
		}
		if textField == tfPIN2 {
			tfPIN2.text = "0"
			PIN0 = PIN0 + txtAfterUpdate
			tfPIN3.becomeFirstResponder()
			return false
		}
		if textField == tfPIN3 {
			tfPIN3.text = "1"
			PIN0 = PIN0 + txtAfterUpdate
			let app = UIApplication.shared.delegate as! AppDelegate
			if app.model!.checkPIN(PIN0) {
				checkPassed()
			} else {
				setupEnterPIN()
			}
			return false
		}
		return false
	}
	
	override public func processUrlCommand() -> Void {
	}

	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
	}
	
	public func textFieldShouldClear(_ textField: UITextField) -> Bool {
		return true;
	}
	
	public func textFieldShouldReturn(_ textField: UITextField) -> Bool {
		return false
	}
	
}

