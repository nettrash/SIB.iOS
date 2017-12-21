//
//  HistoryViewController.swift
//  sib-lite
//
//  Created by Иван Алексеев on 20.12.2017.
//  Copyright © 2017 NETTRASH. All rights reserved.
//

import Foundation
import UIKit

class HistoryViewController : BaseViewController, ModelRootDelegate, UITableViewDelegate, UITableViewDataSource {
	
	let app = UIApplication.shared.delegate as! AppDelegate
	
	@IBOutlet var tblHistory: UITableView!
	@IBOutlet var lblNoOps: UILabel!
	var refreshControl: UIRefreshControl!
	
	override func viewDidLoad() {
		super.viewDidLoad()
		self.app.model!.HistoryItems.Items = []
		refreshControl = UIRefreshControl()
		refreshControl.addTarget(self, action: #selector(refresh), for: .valueChanged)
		refreshControl.tintColor = UIColor.white
		tblHistory.addSubview(refreshControl)
	}
	
	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
		self.tblHistory.setContentOffset(CGPoint(x: 0, y: -self.refreshControl!.frame.size.height - self.view.safeAreaInsets.bottom), animated: true)
		refreshHistory()
	}
	
	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}
	
	@IBAction func closeClick(_ sender: Any?) -> Void {
		performSegue(withIdentifier: unwindIdentifiers["history-sib"]!, sender: self)
	}
	
	@objc func refresh(sender:AnyObject) {
		refreshHistory()
	}
	
	func refreshHistory() -> Void {
		self.app.model!.delegate = self
		self.app.model!.refreshHistory()
	}
	
	//UITaleViewDataSourceDelegate
	func numberOfSections(in tableView: UITableView) -> Int {
		return 1;
	}
	
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return self.app.model!.HistoryItems.Items.count
	}
	
	private func _historyCell(_ tableView: UITableView, _ indexPath: IndexPath) -> UITableViewCell {
		let item = app.model!.HistoryItems.Items.sorted(by: { (_ a: HistoryItem, _ b: HistoryItem) -> Bool in
			a.date > b.date
		})[indexPath.row]
		switch item.type {
		case .Incoming:
			let cell = tableView.dequeueReusableCell(withIdentifier: "HistoryCellIncoming", for: indexPath)
			
			cell.detailTextLabel?.text = "+ " + item.getAmount(app.model!.Dimension)
			cell.textLabel?.text = item.getDate()
			
			return cell
		case .Outgoing:
			let cell = tableView.dequeueReusableCell(withIdentifier: "HistoryCellOutgoing", for: indexPath)
			
			cell.detailTextLabel?.text = "- " + item.getAmount(app.model!.Dimension)
			cell.textLabel?.text = item.getDate()
			
			return cell
		case .Unknown:
			let cell = tableView.dequeueReusableCell(withIdentifier: "UnknownCell", for: indexPath)
			
			cell.detailTextLabel?.text = "? " + item.getAmount(app.model!.Dimension)
			cell.textLabel?.text = item.getDate()
			
			return cell
		}
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		if tableView == tblHistory {
			return _historyCell(tableView, indexPath)
		}
		return UITableViewCell()
	}
	
	//UITableViewDelegate
	func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
	{
		return 48
	}
	
	//ModelRootDelegate
	func startBalanceUpdate() {
		
	}
	
	func stopBalanceUpdate(error: String?) {
		
	}
	
	func startHistoryUpdate() {
		DispatchQueue.main.async {
			self.app.model!.HistoryItems.Items = []
			self.tblHistory.reloadData()
			self.refreshControl.beginRefreshing()
		}
	}
	
	func stopHistoryUpdate() {
		DispatchQueue.main.async {
			self.refreshControl.endRefreshing()
			self.tblHistory.reloadData()
			self.lblNoOps.isHidden = self.app.model!.HistoryItems.Items.count > 0
		}
	}
	
	func startCurrentRatesUpdate() {
		
	}
	
	func stopCurrentRatesUpdate() {
		
	}
	
	func unspetData(_ data: Unspent) {
		
	}
	
	func broadcastTransactionResult(_ result: Bool, _ txid: String?, _ message: String?) {
		
	}

}
