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
}
