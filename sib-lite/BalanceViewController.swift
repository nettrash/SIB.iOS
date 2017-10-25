//
//  BalanceViewController.swift
//  sib-lite
//
//  Created by Иван Алексеев on 12.10.2017.
//  Copyright © 2017 NETTRASH. All rights reserved.
//

import UIKit

class BalanceViewController: BaseViewController, UITableViewDelegate, UITableViewDataSource {
	
	let app = UIApplication.shared.delegate as! AppDelegate
	
	@IBOutlet var lblBalance: UILabel!
	@IBOutlet var scDimension: UISegmentedControl!
	@IBOutlet var btnAction: UIButton!
	@IBOutlet var imgActionInfo: UIImageView!
	@IBOutlet var imgVertical: UIImageView!
	@IBOutlet var btnAddAddress: UIButton!
	@IBOutlet var btnRequisites: UIButton!
	@IBOutlet var btnBuy: UIButton!
	@IBOutlet var tblHistory: UITableView!
	
	override func viewDidLoad() {
		super.viewDidLoad()
		refreshBalanceView()
	}

	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		prepareActionMenu()
	}
	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}
	
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		if (segue.identifier == "add-address") {
			let dst = segue.destination as! AddAddressViewController
			dst.availibleCancel = true;
			dst.unwindIdentifiers["address-add"] = "unwindSegueToBalance"
		}
	}

	@IBAction func unwindToBalance(unwindSegue: UIStoryboardSegue) {
		if (unwindSegue.source is AddAddressViewController) {
			let src = unwindSegue.source as! AddAddressViewController
			app.model!.add(src.textFieldAddress.text!)
		}
	}
	
	@IBAction func addAddress(_ sender: Any?) {
		performSegue(withIdentifier: "add-address", sender: self)
	}

	@IBAction func segmentControlValueChanged(_ sender: Any?) {
		switch scDimension.selectedSegmentIndex {
		case 0:
			app.model!.Dimension = .SIB
		case 1:
			app.model!.Dimension = .mSIB
		case 2:
			app.model!.Dimension = .µSIB
		case 3:
			app.model!.Dimension = .ivans
		default:
			app.model!.Dimension = .SIB
		}
		refreshBalanceView()
		tblHistory.reloadData()
	}
	
	func refreshBalanceView() {
		switch app.model!.Dimension {
		case .SIB:
			lblBalance.text = String(format: "%.2f", app.model!.Balance)
			scDimension.selectedSegmentIndex = 0
		case .mSIB:
			lblBalance.text = String(format: "%.2f", app.model!.Balance * 1000)
			scDimension.selectedSegmentIndex = 1
		case .µSIB:
			lblBalance.text = String(format: "%.2f", app.model!.Balance * 1000 * 1000)
			scDimension.selectedSegmentIndex = 2
		case .ivans:
			lblBalance.text = String(format: "%.2f", app.model!.Balance * 1000 * 1000 * 100)
			scDimension.selectedSegmentIndex = 3
		}
	}
	
	@IBAction func toggleMenu(_ sender: Any?) {
		UIView.animate(withDuration: 0.25, animations: { () -> Void in
			self.btnAction.transform = CGAffineTransform(rotationAngle: CGFloat.pi * 0.25)
		}, completion: { (_ success: Bool) -> Void in
			UIView.animate(withDuration: 0.20, animations: { () -> Void in
				self.btnAction.transform = CGAffineTransform(rotationAngle: CGFloat.pi * 0.50)
			}, completion: { (_ success: Bool) -> Void in
				UIView.animate(withDuration: 0.15, animations: { () -> Void in
					self.btnAction.transform = CGAffineTransform(rotationAngle: CGFloat.pi * 1)
					self.btnAddAddress.alpha = self.btnAddAddress.alpha == 0 ? 1 : 0
					self.imgVertical.alpha = self.imgVertical.alpha == 0 ? self.btnAddAddress.alpha : 0
				}, completion: { (_ success: Bool) -> Void in
					UIView.animate(withDuration: 0.10, animations: { () -> Void in
						self.btnAction.transform = CGAffineTransform(rotationAngle: CGFloat.pi * 1.50)
						self.btnRequisites.alpha = self.btnRequisites.alpha == 0 ? 1 : 0
					}, completion: { (_ success: Bool) -> Void in
						UIView.animate(withDuration: 0.05, animations: { () -> Void in
							self.btnAction.transform = CGAffineTransform(rotationAngle: CGFloat.pi * 2)
							self.imgActionInfo.alpha = self.imgActionInfo.alpha == 0 ? 1 : 0
							self.btnBuy.alpha = self.btnBuy.alpha == 0 ? 1 : 0
							self.imgVertical.alpha = self.imgVertical.alpha == 0 ? self.btnAddAddress.alpha : self.imgVertical.alpha
						}, completion: { (_ success: Bool) -> Void in
							
						})
					})
				})
			})
		})
	}
	
	private func prepareActionMenu() {
		btnAddAddress.alpha = 0;
		btnRequisites.alpha = 0;
		btnBuy.alpha = 0;
		imgVertical.alpha = 0;
		/*
		self.btnAddAddress.transform = CGAffineTransform(rotationAngle: CGFloat.pi * -0.5)
		self.btnRequisites.transform = CGAffineTransform(rotationAngle: CGFloat.pi * -0.25)
		
		let actionFrame = self.btnAction.frame
		
		var frameAdd = self.btnAddAddress.frame
		frameAdd.origin = CGPoint(x: actionFrame.origin.x, y: actionFrame.origin.y - 48)
		self.btnAddAddress.frame = frameAdd
			
		var frameReq = self.btnRequisites.frame
		frameReq.origin = CGPoint(x: 100, y: 100)//(x: actionFrame.origin.x + 48, y: actionFrame.origin.y - 48)
		self.btnRequisites.frame = frameReq
			
		var frameBuy = self.btnBuy.frame
		frameBuy.origin = CGPoint(x: actionFrame.origin.x + 48, y: actionFrame.origin.y)
		self.btnBuy.frame = frameBuy*/
	}
	
	//UITaleViewDataSourceDelegate
	func numberOfSections(in tableView: UITableView) -> Int {
		return 1;
	}
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return app.model!.HistoryItems.Items.count > 3 ? 3 : app.model!.HistoryItems.Items.count
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let item = app.model!.HistoryItems.Items.sorted(by: { (_ a: HistoryItem, _ b: HistoryItem) -> Bool in
			a.date > b.date
		})[indexPath.row]
		switch item.type {
		case .Incoming:
			let cell = tableView.dequeueReusableCell(withIdentifier: "IncomingTransaction", for: indexPath)
			
			cell.detailTextLabel?.text = "+ " + item.getAmount(app.model!.Dimension)
			cell.textLabel?.text = item.getDate()

			return cell
		case .Outgoing:
			let cell = tableView.dequeueReusableCell(withIdentifier: "OutgoingTransaction", for: indexPath)
			
			cell.detailTextLabel?.text = "- " + item.getAmount(app.model!.Dimension)
			cell.textLabel?.text = item.getDate()
			
			return cell
		}
	}

	//UITableViewDelegate
}

