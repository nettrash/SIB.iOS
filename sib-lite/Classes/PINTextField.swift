//
//  PINTextField.swift
//  sib-lite
//
//  Created by Иван Алексеев on 23.12.2017.
//  Copyright © 2017 NETTRASH. All rights reserved.
//

import Foundation
import UIKit

class PINTextField: UITextField {
	
	override func deleteBackward() {
		let shouldDismiss = self.text!.count == 0
		
		super.deleteBackward()
		
		if (shouldDismiss) {
			self.delegate?.textField!(self, shouldChangeCharactersIn: NSRange.init(location: 0, length: 0), replacementString: "")
		}
	}
}
