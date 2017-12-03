//
//  ReceiveViewController.swift
//  sib-lite
//
//  Created by Иван Алексеев on 29.11.2017.
//  Copyright © 2017 NETTRASH. All rights reserved.
//

import Foundation
import UIKit

class ReceiveViewController : BaseViewController, UITextFieldDelegate {
	
	@IBOutlet var tfAddress: UITextField!
	@IBOutlet var imgQR: UIImageView!
	@IBOutlet var aiWait: UIActivityIndicatorView!
	
	var address: String = ""
	var addressUrl: String = ""
	
	override func viewDidLoad() {
		super.viewDidLoad()
	}
	
	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
		
		let app = UIApplication.shared.delegate as! AppDelegate
		address = app.model!.Addresses[app.model!.Addresses.count-1].address
		addressUrl = app.model!.SIB!.URIScheme + address
		tfAddress.text = address
		DispatchQueue.main.async {
			self.refreshQR()
		}
	}
	
	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}
	
	@IBAction func shareAddress(_ sender: Any?) -> Void {
		let activityViewController : UIActivityViewController = UIActivityViewController(
			activityItems: [address, imgQR.image!], applicationActivities: nil)
	
		activityViewController.popoverPresentationController?.sourceView = (sender as! UIButton)
	
		activityViewController.popoverPresentationController?.permittedArrowDirections = UIPopoverArrowDirection.any
		activityViewController.popoverPresentationController?.sourceRect = CGRect(x: 150, y: 150, width: 0, height: 0)
	
		activityViewController.excludedActivityTypes = [
			UIActivityType.postToWeibo,
			UIActivityType.assignToContact,
			UIActivityType.addToReadingList,
			UIActivityType.postToFlickr,
			UIActivityType.postToVimeo,
			UIActivityType.postToTencentWeibo
		]
	
		self.present(activityViewController, animated: true, completion: nil)
	}
	
	func refreshQR() -> Void {
		let data = addressUrl.data(using: String.Encoding.ascii)
		let filter = CIFilter(name: "CIQRCodeGenerator")
	
		filter!.setValue(data, forKey: "inputMessage")
		filter!.setValue("Q", forKey: "inputCorrectionLevel")
		
		let qrcodeImage = filter!.outputImage
		
		let scaleX = imgQR.frame.size.width / qrcodeImage!.extent.size.width
		let scaleY = imgQR.frame.size.height / qrcodeImage!.extent.size.height
		
		let transformedImage = qrcodeImage!.transformed(by: CGAffineTransform(scaleX: scaleX, y: scaleY))
		
		imgQR.image = UIImage(ciImage: transformedImage)
		
		aiWait.stopAnimating()
	}
		
	@IBAction func closeClick(_ sender: Any?) -> Void {
		performSegue(withIdentifier: unwindIdentifiers["receive-sib"]!, sender: self)
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
