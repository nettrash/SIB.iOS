//
//  BaseViewController.swift
//  sib-lite
//
//  Created by Иван Алексеев on 17.10.2017.
//  Copyright © 2017 NETTRASH. All rights reserved.
//

import Foundation
import UIKit

class BaseViewController: UIViewController {
	
	public var unwindIdentifiers: [String:String] = [String:String]()
	
	override func viewDidLoad() {
		super.viewDidLoad()
		for v in view.subviews {
			if v is SIBLogoImageView {
				(v as! SIBLogoImageView).image = UIImage(named: NSLocalizedString("SIBLogoImageName", comment: "SIBLogoImageName"))
			}
		}
	}
	
	override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
		self.view.endEditing(true)
	}
	
	public func processUrlCommand() -> Void {
		dismiss(animated: false, completion: nil)
	}
	
	public func showError(error: String) -> Void {
		let alert = UIAlertController.init(title: NSLocalizedString("Error", comment: "Ошибка"), message: error, preferredStyle: UIAlertControllerStyle.alert)
		alert.addAction(UIAlertAction.init(title: NSLocalizedString("Cancel", comment: "Отмена"), style: UIAlertActionStyle.cancel, handler: { _ in alert.dismiss(animated: true, completion: nil) }))
		self.present(alert, animated: true, completion: nil)
	}
	
	public func shareText(_ text: String) -> Void {
		let activityViewController : UIActivityViewController = UIActivityViewController(
			activityItems: [text], applicationActivities: [])
		present(activityViewController, animated: true, completion: nil)
	}
}
