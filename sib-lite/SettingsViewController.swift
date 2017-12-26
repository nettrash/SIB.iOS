//
//  SettingsViewController.swift
//  sib-lite
//
//  Created by Иван Алексеев on 26.12.2017.
//  Copyright © 2017 NETTRASH. All rights reserved.
//

import Foundation
import UIKit

class SettingsViewController : BaseViewController {

	override func viewDidLoad() {
		super.viewDidLoad()
	}
	
	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
	}
	
	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}
	
	@IBAction func closeClick(_ sender: Any?) -> Void {
		performSegue(withIdentifier: unwindIdentifiers["settings-sib"]!, sender: self)
	}

}
