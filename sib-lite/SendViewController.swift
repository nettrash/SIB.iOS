//
//  SendViewController.swift
//  sib-lite
//
//  Created by Иван Алексеев on 02.12.2017.
//  Copyright © 2017 NETTRASH. All rights reserved.
//

import Foundation
import UIKit

class SendViewController : BaseViewController, UITextFieldDelegate {
	
	@IBOutlet var tfAddress: UITextField!
	@IBOutlet var tfAmount: UITextField!
	@IBOutlet var tfCommission: UITextField!
	@IBOutlet var lblBalance: UILabel!
	
	override func viewDidLoad() {
		super.viewDidLoad()
		let app = UIApplication.shared.delegate as! AppDelegate
		lblBalance.text = String(format: "%.2f", app.model!.Balance)
	}
	
	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
	}
	
	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}
	
	@IBAction func closeClick(_ sender: Any?) -> Void {
		performSegue(withIdentifier: unwindIdentifiers["send-sib"]!, sender: self)
	}
	
	// UITextFieldDelegate
	public func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
		return false;
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
		return false
	}
	
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
	}
	
	public func textFieldShouldClear(_ textField: UITextField) -> Bool {
		return false;
	}
	
	public func textFieldShouldReturn(_ textField: UITextField) -> Bool {
		return false
	}
	
}

