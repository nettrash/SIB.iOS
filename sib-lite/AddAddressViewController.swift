//
//  AddAddressViewController.swift
//  sib-lite
//
//  Created by Иван Алексеев on 12.10.2017.
//  Copyright © 2017 NETTRASH. All rights reserved.
//

import UIKit

class AddAddressViewController: BaseViewController, UITextFieldDelegate {
	
	@IBOutlet var textFieldAddress: UITextField!
	
	@IBOutlet var btnCancel: UIButton!
	
	public var availibleCancel: Bool = true
	
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
		btnCancel.isHidden = !availibleCancel
		textFieldAddress.becomeFirstResponder()
	}
	
	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
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
		
		if (sibAddress.verify(txtAfterUpdate)) {
			textField.backgroundColor = UIColor(displayP3Red: 0.9, green: 1, blue: 0.9, alpha: 0.8)
		} else {
			textField.backgroundColor = UIColor(displayP3Red: 1, green: 0.9, blue: 0.9, alpha: 0.8)
		}
		
		return true;
	}
	
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		if (segue.identifier == "Scan") {
			let dst = segue.destination as! ScanViewController
			dst.unwindIdentifiers = self.unwindIdentifiers
		}
	}

	public func textFieldShouldClear(_ textField: UITextField) -> Bool {
		return true;
	}
	
	public func textFieldShouldReturn(_ textField: UITextField) -> Bool {
		if (sibAddress.verify(textField.text)) {
			performSegue(withIdentifier: unwindIdentifiers["add-address"]!, sender: self)
		}
		return false
	}

	@IBAction func unwindToAddAddress(unwindSegue: UIStoryboardSegue) {
		if (unwindSegue.source is BaseViewController && unwindSegue.destination is BaseViewController) {
			let src = unwindSegue.source as! BaseViewController
			let dst = unwindSegue.destination as! BaseViewController
			
			dst.unwindIdentifiers = src.unwindIdentifiers
		}
		if (unwindSegue.source is ScanViewController) {
			let dest = unwindSegue.destination as! AddAddressViewController
			let src = unwindSegue.source as! ScanViewController
			dest.textFieldAddress.text = src.address
		
			if (src.address ?? "" != "") {
				performSegue(withIdentifier: unwindIdentifiers["add-address"]!, sender: self)
			}
		}
	}
	
	@IBAction func btnCancelClick(_ sender: Any?) {
		dismiss(animated: true)
	}

}

