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
	
	let app = UIApplication.shared.delegate as! AppDelegate
	
	private var _unspent: Unspent?
	private var _amount: Double?
	private var _commission: Double?
	private var _unspentAmount: Double?
	private var _address: String?
	
	private var _otherAddress: String?
	private var _otherAmount: Decimal?
	private var _otherCurrency: Currency?
	
	var components: URLComponents?
	
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
		app.model!.delegate = self
		parseComponents()
		if tfAddress.text?.count ?? 0 > 0 {
			tfAmount.becomeFirstResponder()
		} else {
			tfAddress.becomeFirstResponder()
		}
	}
	
	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}
	
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		if (segue.identifier == "scan-address") {
			let dst = segue.destination as! ScanViewController
			dst.unwindIdentifiers["scan-address"] = "unwindSegueToSend"
		}
	}
	
	func parseComponents() -> Void {
		if components != nil {
			tfAddress.text = components?.host
			if components?.queryItems != nil {
				for qi in components!.queryItems! {
					switch qi.name {
					case "amount":
						tfAmount.text = qi.value ?? ""
						break;
					case "message":
						//message = qi.value
						break;
					case "IS":
						//scInstantSend.isOn = qi.value ?? "" == "1"
						break;
					default:
						break;
					}
				}
			}
			components = nil
		}
	}
	
	@IBAction func unwindToSend(unwindSegue: UIStoryboardSegue) {
		if (unwindSegue.source is ScanViewController) {
			let dest = unwindSegue.destination as! SendViewController
			let src = unwindSegue.source as! ScanViewController
			switch src.currency {
			case .SIB:
				dest.tfAddress.text = src.address
				if src.amount ?? 0 > 0 {
					dest.tfAmount.text = "\(src.amount!)"
				}
				//dest.scInstantSend.isOn = src.instantSend
				break
			case .BTC,
				 .BIO:
				//send SIB to other crypto
				processOtherCrypto(src.currency, src.address, src.amount)
				break
			default:
				break
			}
		}
	}

	func processOtherCrypto(_ currency: Currency?, _ address: String?, _ amount: Decimal?) -> Void {
		//Считаем курс sellRate
		_otherCurrency = currency
		_otherAddress = address
		_otherAmount = amount
		
		if (currency == nil) { return }
		
		self.vWait.isHidden = false
		
		self.app.model!.sellRate = 0
		self.app.model!.getSellRate(currency!.rawValue)
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
		app.model!.delegate = self
		app.model!.getUnspentData()
	}
	
	@IBAction func scanClick(_ sender: Any?) -> Void {
		self.view.endEditing(true)
		performSegue(withIdentifier: "scan-address", sender: self)
	}

	func verifyData() -> Bool {
		DispatchQueue.main.sync {
			_amount = Double(tfAmount.text!.replacingOccurrences(of: ",", with: ".", options: .literal, range: nil))
			_commission = Double(tfCommission.text!.replacingOccurrences(of: ",", with: ".", options: .literal, range: nil))
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
				spent += u.amount.rounded(toPlaces: 8)
				tx.addInput(u)
			} else {
				break;
			}
		}
		tx.addChange(amount: spent - _amount! - _commission!)
		return tx
	}
	
	private func _sendTransaction(_ tx: sibTransaction) -> Void {
		let app = UIApplication.shared.delegate as! AppDelegate
		app.model!.storeWallet(tx.Change!, true, .Change) //В слычае неуспеха отправки надо удалять
		let sign = tx.sign(app.model!.Addresses)
		print(sign.hexEncodedString())
		//Отправляем sign как rawtx
		app.model!.delegate = self
		app.model!.broadcastTransaction(sign)
	}
	
	// UITextFieldDelegate
	public func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
		return textField != self.tfCommission
	}
	
	public func textFieldDidBeginEditing(_ textField: UITextField) {
		
	}
	
	public func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
		return true
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
		
		if textField == tfAmount {
			let amount = Double(txtAfterUpdate.replacingOccurrences(of: ",", with: ".", options: .literal, range: nil))
			let commission = Double(0.001 * (amount ?? 0))
			self.tfCommission.text = String(format: "%.4f", commission)
			if self.app.model!.Balance < (amount ?? 0) + commission {
				textField.backgroundColor = UIColor(displayP3Red: 1, green: 0.9, blue: 0.9, alpha: 0.8)
			} else {
				textField.backgroundColor = UIColor(displayP3Red: 0.9, green: 1, blue: 0.9, alpha: 0.8)
			}
		}
		
		return true;
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
	
	func stopBalanceUpdate(error: String?) -> Void {
		
	}
	
	func startHistoryUpdate() -> Void {
		
	}
	
	func stopHistoryUpdate() -> Void {
		
	}
	
	func unspetData(_ data: Unspent) -> Void {
		_unspent = data
		if verifyData() {
			DispatchQueue.main.sync {
				let tx: sibTransaction = self._prepareTransaction()
				self._sendTransaction(tx)
				self.vWait.isHidden = false;
			}
		} else {
			DispatchQueue.main.sync {
				self.vWait.isHidden = true
				let alert = UIAlertController.init(title: NSLocalizedString("Error", comment: "Ошибка"), message: NSLocalizedString("SendAmountError", comment: "Ошибка") + String(format: "%.2f", self._unspentAmount!), preferredStyle: UIAlertControllerStyle.alert)
				alert.addAction(UIAlertAction.init(title: NSLocalizedString("Cancel", comment: "Отмена"), style: UIAlertActionStyle.cancel, handler: { _ in alert.dismiss(animated: true, completion: nil) }))
				self.present(alert, animated: true, completion: nil)
			}
		}
	}
	
	func broadcastTransactionResult(_ result: Bool, _ txid: String?, _ message: String?) {
		DispatchQueue.main.sync { self.vWait.isHidden = true }
		if result {
				let alert = UIAlertController.init(title: NSLocalizedString("SuccessSend", comment: "Успех"), message: NSLocalizedString("SuccessSendMessage", comment: "Success") + txid!, preferredStyle: UIAlertControllerStyle.alert)
				alert.addAction(UIAlertAction.init(title: NSLocalizedString("OK", comment: "OK"), style: UIAlertActionStyle.cancel, handler: { _ in alert.dismiss(animated: true, completion: nil); self.closeClick(nil) }))
				alert.addAction(UIAlertAction.init(title: NSLocalizedString("Share", comment: "Поделться"), style: UIAlertActionStyle.default, handler: { _ in self.shareText(txid!); alert.dismiss(animated: true, completion: nil) }))
				self.present(alert, animated: true, completion: nil)
			
		} else {
				//Добавить удаление последнего адреса Change
				let alert = UIAlertController.init(title: NSLocalizedString("ErrorSend", comment: "Ошибка"), message: NSLocalizedString("ErrorSendMessage", comment: "Ошибка") + (message ?? ""), preferredStyle: UIAlertControllerStyle.alert)
				alert.addAction(UIAlertAction.init(title: NSLocalizedString("OK", comment: "OK"), style: UIAlertActionStyle.cancel, handler: { _ in alert.dismiss(animated: true, completion: nil) }))
				self.present(alert, animated: true, completion: nil)
		}
	}
	
	func startCurrentRatesUpdate() {
	}
	
	func stopCurrentRatesUpdate() {
	}
	
	func sellStart() {
	}
	
	func sellComplete() {
		DispatchQueue.main.async {
			self.vWait.isHidden = true
			self.closeClick(nil)
		}
	}
	
	func updateSellRate() {
		DispatchQueue.main.async {
			self._amount = (self._otherAmount! as NSDecimalNumber).doubleValue / self.app.model!.sellRate
			let commission = Double(0.001 * (self._amount ?? 0))
			if self.app.model!.Balance < (self._amount ?? 0) + commission {
				self.vWait.isHidden = true
				
				let alert = UIAlertController.init(title: NSLocalizedString("Error", comment: "Ошибка"), message: NSLocalizedString("SendAmountError", comment: "Ошибка") + String(format: "%.2f", self.app.model!.Balance), preferredStyle: UIAlertControllerStyle.alert)
				alert.addAction(UIAlertAction.init(title: NSLocalizedString("Cancel", comment: "Отмена"), style: UIAlertActionStyle.cancel, handler: { _ in alert.dismiss(animated: true, completion: nil) }))
				self.present(alert, animated: true, completion: nil)
				
				return
			}

			let title: String = NSLocalizedString("OtherCryptoTransferTitle", comment: "OtherCryptoTransferTitle") + self._otherCurrency!.rawValue
			
			var msg: String = NSLocalizedString("OtherCryptoTransferMessageAddress", comment: "OtherCryptoTransferMessageAddress") + self._otherAddress! + "\n"
			msg += NSLocalizedString("OtherCryptoTransferMessageAmount", comment: "OtherCryptoTransferMessageAmount") + String(format: "%.8f", (self._otherAmount! as NSDecimalNumber).doubleValue) + " " + self._otherCurrency!.rawValue + "\n"
			msg += NSLocalizedString("OtherCryptoTransferMessageAmountSIB", comment: "OtherCryptoTransferMessageAmountSIB") + String(format: "%.8f", self._amount!) + " SIB\n"
			msg += NSLocalizedString("OtherCryptoTransferMessageCommission", comment: "OtherCryptoTransferMessageCommission") + String(format: "%.8f", commission) + " SIB"
			
			let alert = UIAlertController.init(title: title, message: msg, preferredStyle: UIAlertControllerStyle.alert)
			alert.addAction(UIAlertAction.init(title: NSLocalizedString("OtherCryptoTransferDo", comment: "Исполнить"), style: UIAlertActionStyle.default, handler: { _ in
				//Регистрируем выплату
				//Выплачиваем
				self.app.model!.sell(self._otherCurrency!.rawValue, self._amount!, (self._otherAmount! as NSDecimalNumber).doubleValue, self._otherAddress!)
				alert.dismiss(animated: true, completion: nil) }))
			alert.addAction(UIAlertAction.init(title: NSLocalizedString("Cancel", comment: "Отмена"), style: UIAlertActionStyle.cancel, handler: { _ in
				self.vWait.isHidden = true
				alert.dismiss(animated: true, completion: nil) }))
			self.present(alert, animated: true, completion: nil)
		}
	}
	
	func buyStart() {
		
	}
	
	func buyComplete() {
		
	}
	
	func updateBuyRate() {
		
	}
	
	func checkOpComplete(_ process: String) {
		
	}
	
	override func processUrlCommand() {
		let app = UIApplication.shared.delegate as! AppDelegate
		if app.needToProcessURL {
			if (app.openUrl != nil) {
				components = URLComponents(url: app.openUrl!, resolvingAgainstBaseURL: true)
				if components?.scheme?.lowercased() == "sibcoin" {
					app.needToProcessURL = false
					parseComponents()
				} else {
					super.processUrlCommand()
				}
			}
		}
	}
}

