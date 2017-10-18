//
//  ViewController.swift
//  sib-lite
//
//  Created by Иван Алексеев on 23.09.17.
//  Copyright © 2017 NETTRASH. All rights reserved.
//

import UIKit

class RootViewController: BaseViewController {

	override func viewDidLoad() {
		super.viewDidLoad()
		// Do any additional setup after loading the view, typically from a nib.
	}

	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
		let app = UIApplication.shared.delegate as! AppDelegate
		if (app.model!.Addresses.count < 1) {
			performSegue(withIdentifier: "root-address-add", sender: self)
		} else {
			performSegue(withIdentifier: "balance", sender: self)
		}
	}
	
	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}
	
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		if (segue.identifier == "root-address-add") {
			let dst = segue.destination as! AddAddressViewController
			dst.availibleCancel = false
			dst.unwindIdentifiers["address-add"] = "unwindSegueToRoot"
		}
	}
	
	@IBAction func unwindToRoot(unwindSegue: UIStoryboardSegue) {
		if (unwindSegue.source is AddAddressViewController) {
			let app = UIApplication.shared.delegate as! AppDelegate
			let src = unwindSegue.source as! AddAddressViewController
			app.model!.add(src.textFieldAddress.text!)
			performSegue(withIdentifier: "balance", sender: self)
		}
	}

}

