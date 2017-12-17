//
//  BalanceViewController.swift
//  sib-lite
//
//  Created by Иван Алексеев on 12.10.2017.
//  Copyright © 2017 NETTRASH. All rights reserved.
//

import UIKit

class BalanceViewController: BaseViewController, UITableViewDelegate, UITableViewDataSource, ModelRootDelegate {
	
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
	@IBOutlet var aiRefresh: UIActivityIndicatorView!
	@IBOutlet var lblNoOps: UILabel!
	
	override func viewDidLoad() {
		super.viewDidLoad()

		self.lblNoOps.isHidden = true
	}

	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		DispatchQueue.main.async {
			self.app.model!.delegate = self
			self.prepareActionMenu()
			self.refreshBalanceView()
			self.app.model!.refresh()
		}
	}
	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}
	
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		imgActionInfo.alpha = 1.0
		if (segue.identifier == "add-address") {
			let dst = segue.destination as! AddAddressViewController
			dst.availibleCancel = true;
			dst.unwindIdentifiers["add-address"] = "unwindSegueToBalance"
		}
		if (segue.identifier == "receive-sib") {
			let dst = segue.destination as! ReceiveViewController
			dst.unwindIdentifiers["receive-sib"] = "unwindSegueToBalance"
		}
		if (segue.identifier == "send-sib") {
			let dst = segue.destination as! SendViewController
			dst.unwindIdentifiers["send-sib"] = "unwindSegueToBalance"
			if sender is URLComponents {
				let components = sender as! URLComponents
				dst.components = components
			}
		}
	}

	@IBAction func unwindToBalance(unwindSegue: UIStoryboardSegue) {
		if (unwindSegue.source is AddAddressViewController) {
			let src = unwindSegue.source as! AddAddressViewController
			//app.model!.add(src.textFieldAddress.text!)
		}
		if (unwindSegue.source is ReceiveViewController) {
			let src = unwindSegue.source as! ReceiveViewController
			//app.model!.add(src.textFieldAddress.text!)
		}
		if (unwindSegue.source is SendViewController) {
			let src = unwindSegue.source as! SendViewController
			//app.model!.add(src.textFieldAddress.text!)
		}
	}
	
	@IBAction func addAddress(_ sender: Any?) {
		performSegue(withIdentifier: "add-address", sender: self)
	}
	
	@IBAction func receiveSIB(_ sender: Any?) {
		performSegue(withIdentifier: "receive-sib", sender: self)
	}
	
	@IBAction func sendSIB(_ sender: Any?) {
		performSegue(withIdentifier: "send-sib", sender: self)
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
			lblBalance.text = String(format: "%.0f", app.model!.Balance * 1000 * 1000 * 100)
			scDimension.selectedSegmentIndex = 3
		}
	}
	
	@IBAction func refreshBalanceClick(_ sender: Any?) {
		DispatchQueue.main.async {
			self.app.model!.refresh()
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
		return app.model!.HistoryItems.Items.count
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
		case .Unknown:
			let cell = tableView.dequeueReusableCell(withIdentifier: "UnknownTransaction", for: indexPath)
			
			cell.detailTextLabel?.text = "? " + item.getAmount(app.model!.Dimension)
			cell.textLabel?.text = item.getDate()
			
			return cell
		}
	}

	//UITableViewDelegate
	
	//ModelRootDelegate
	func startBalanceUpdate() {
		DispatchQueue.main.async {
			self.lblNoOps.isHidden = true
		}
		DispatchQueue.main.async {
			UIView.animate(withDuration: 0.35, animations: { () -> Void in
				self.lblBalance.alpha = 0.4
				self.lblBalance.font = self.lblBalance.font.withSize(18)
				UIView.transition(with: self.lblBalance,
				                  duration: 0.35,
				                  options: UIViewAnimationOptions.transitionFlipFromTop,
				                  animations: { [weak self] in
									self?.lblBalance.text = NSLocalizedString("reloadBalance", comment: "")
					}, completion: nil)
			}, completion: { (_ success: Bool) -> Void in })
		}
	}
	
	func stopBalanceUpdate(error: String?) {
		if error != nil { showError(error: error!) }
		DispatchQueue.main.async {
			UIView.animate(withDuration: 0.35, animations: { () -> Void in
				self.lblBalance.alpha = 1
				self.lblBalance.font = self.lblBalance.font.withSize(56)
				UIView.transition(with: self.lblBalance,
				                  duration: 0.35,
				                  options: UIViewAnimationOptions.transitionFlipFromBottom,
				                  animations: { [weak self] in
									self?.refreshBalanceView()
									self?.processUrlCommand()
					}, completion: nil)
			}, completion: { (_ success: Bool) -> Void in })
		}
	}
	
	func startHistoryUpdate() {
		DispatchQueue.main.async {
			self.app.model!.HistoryItems.Items = [];
			self.tblHistory.reloadData()
			self.aiRefresh.startAnimating()
		}
	}
	
	func stopHistoryUpdate() {
		DispatchQueue.main.async {
			self.aiRefresh.stopAnimating()
			self.tblHistory.reloadData()
			self.lblNoOps.isHidden = self.app.model!.HistoryItems.Items.count > 0
		}
	}
	
	func unspetData(_ unspent: Unspent) {
	}
	
	func broadcastTransactionResult(_ result: Bool, _ txid: String?, _ message: String?) {
	}
	
	override func processUrlCommand() {
		if app.needToProcessURL {
			app.needToProcessURL = false
			if (app.openUrl != nil) {
				let components = URLComponents(url: app.openUrl!, resolvingAgainstBaseURL: true)
				performSegue(withIdentifier: "send-sib", sender: components)
			}
		}
	}
}

