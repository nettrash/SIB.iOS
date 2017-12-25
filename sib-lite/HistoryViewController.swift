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
	var selectedIndex: IndexPath? = nil
	
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
		if selectedIndex != nil && selectedIndex == indexPath {
			let cell = tableView.dequeueReusableCell(withIdentifier: "HistoryCellSelected", for: indexPath) as! HistoryCellSelected
			cell.loadData(item, self)
			return cell
		} else {
			let cell = tableView.dequeueReusableCell(withIdentifier: "HistoryCell", for: indexPath) as! HistoryCell
			cell.loadData(item)
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
	func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
		if selectedIndex != nil && selectedIndex == indexPath { return 96 }
		return 48
	}
	
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		if selectedIndex != indexPath {
			selectedIndex = indexPath
		} else {
			selectedIndex = nil
		}
		tableView.deselectRow(at: indexPath, animated: true)
		tableView.reloadRows(at: [indexPath], with: UITableViewRowAnimation.automatic)
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
	
	func sellStart() {
	}
	
	func sellComplete() {
	}

	func updateSellRate() {
	}
	
	func buyStart() {
		
	}
	
	func buyComplete() {
		
	}
	
	func updateBuyRate() {
		
	}
	
	func checkOpComplete(_ process: String) {
		
	}
	
}
