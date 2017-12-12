//
//  SendViewController.swift
//  sib-lite
//
//  Created by Иван Алексеев on 02.12.2017.
//  Copyright © 2017 NETTRASH. All rights reserved.
//

import Foundation
import UIKit

class SendViewController : BaseViewController, ModelRootDelegate, UITextFieldDelegate {
	
	private var _unspent: Unspent?
	private var _amount: Double?
	private var _commission: Double?
	private var _unspentAmount: Double?
	private var _address: String?
	
	@IBOutlet var tfAddress: UITextField!
	@IBOutlet var tfAmount: UITextField!
	@IBOutlet var tfCommission: UITextField!
	@IBOutlet var lblBalance: UILabel!
	@IBOutlet var vWait: UIView!
	
	override func viewDidLoad() {
		super.viewDidLoad()
		let app = UIApplication.shared.delegate as! AppDelegate
		lblBalance.text = String(format: "%.2f", app.model!.Balance) + " SIB"
		vWait.isHidden = true
	}
	
	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
		let app = UIApplication.shared.delegate as! AppDelegate
		app.model?.delegate = self
		vWait.isHidden = true
		tfAddress.becomeFirstResponder()
	}
	
	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}
	
	@IBAction func closeClick(_ sender: Any?) -> Void {
		performSegue(withIdentifier: unwindIdentifiers["send-sib"]!, sender: self)
	}
	
	func checkValid() -> Bool {
		return sibAddress.verify(tfAddress.text)
	}
	
	@IBAction func sendClick(_ sender: Any?) -> Void {
		self.view.endEditing(true)
		vWait.isHidden = false
		let app = UIApplication.shared.delegate as! AppDelegate
		app.model!.getUnspentData()
	}
	
	func verifyData() -> Bool {
		DispatchQueue.main.sync {
			_amount = Double(tfAmount.text!)
			_commission = Double(tfCommission.text!)
			_unspentAmount = 0
			if _unspent?.Items.count ?? 0 > 0 {
				for u in _unspent!.Items {
					_unspentAmount = (_unspentAmount ?? 0) + u.amount
				}
			}
			_address = tfAddress.text
		}
		return (_amount ?? 0) > 0 && ((_amount ?? 0) + (_commission ?? 0) <= (_unspentAmount ?? 0))
	}
	
	private func _prepareTransaction() -> sibTransaction {
		let tx: sibTransaction = sibTransaction()
		//Добавляем требуемый вывод
		tx.addOutput(address: _address!, amount: _amount!)
		var spent: Double = 0
		//Добавляем непотраченные входы
		for u in _unspent!.Items {
			if spent < _amount! + _commission! {
				spent += u.amount
				tx.addInput(u)
			} else {
				break;
			}
		}
		tx.addChange(amount: spent - _amount! - _commission!)
		let app = UIApplication.shared.delegate as! AppDelegate
		//Вот тут конечно надо брать те закрытые ключи что были для адресов на вход
		tx.sign(app.model!.AddressesForIncoming[app.model!.AddressesForIncoming.count-1].privateKey as Data)
		return tx
	}
	
	private func _sendTransaction(_ tx: sibTransaction) -> Void {
		
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
		
		if textField == tfAddress {
			if (sibAddress.verify(txtAfterUpdate)) {
				textField.backgroundColor = UIColor(displayP3Red: 0.9, green: 1, blue: 0.9, alpha: 0.8)
				textField.text = txtAfterUpdate
				tfAmount.becomeFirstResponder()
				return false
			} else {
				textField.backgroundColor = UIColor(displayP3Red: 1, green: 0.9, blue: 0.9, alpha: 0.8)
			}
		}
		
		if textField == tfAmount || textField == tfCommission {
			let app = UIApplication.shared.delegate as! AppDelegate
			let amount = Double(textField == tfAmount ? txtAfterUpdate : tfAmount.text!)
			let commission = Double(textField == tfCommission ? txtAfterUpdate : tfCommission.text!)
			if app.model!.Balance < (amount ?? 0) + (commission ?? 0) {
				textField.backgroundColor = UIColor(displayP3Red: 1, green: 0.9, blue: 0.9, alpha: 0.8)
			} else {
				textField.backgroundColor = UIColor(displayP3Red: 0.9, green: 1, blue: 0.9, alpha: 0.8)
			}
		}
		
		return true;
	}
	
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
	}
	
	public func textFieldShouldClear(_ textField: UITextField) -> Bool {
		return true;
	}
	
	public func textFieldShouldReturn(_ textField: UITextField) -> Bool {
		return checkValid()
	}
	
	//ModelRootDelegate
	
	func startBalanceUpdate() -> Void {
		
	}
	
	func stopBalanceUpdate() -> Void {
		
	}
	
	func startHistoryUpdate() -> Void {
		
	}
	
	func stopHistoryUpdate() -> Void {
		
	}
	
	func unspetData(_ data: Unspent) -> Void {
		_unspent = data
		if verifyData() {
			let tx: sibTransaction = _prepareTransaction()
			_sendTransaction(tx)
			vWait.isHidden = false;
			closeClick(nil)
		} else {
			DispatchQueue.main.async {
				self.vWait.isHidden = true
				let alert = UIAlertController.init(title: NSLocalizedString("Error", comment: "Ошибка"), message: NSLocalizedString("SendAmountError", comment: "Ошибка") + String(format: "%.2f", self._unspentAmount!), preferredStyle: UIAlertControllerStyle.alert)
				alert.addAction(UIAlertAction.init(title: NSLocalizedString("Cancel", comment: "Отмена"), style: UIAlertActionStyle.cancel, handler: { _ in alert.dismiss(animated: true, completion: nil) }))
				self.present(alert, animated: true, completion: nil)
			}
		}
	}
	
}

