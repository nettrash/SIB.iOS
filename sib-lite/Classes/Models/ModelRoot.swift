//
//  ModelRoot.swift
//  sib-lite
//
//  Created by Иван Алексеев on 23.09.17.
//  Copyright © 2017 NETTRASH. All rights reserved.
//

import UIKit
import CoreData;

public class ModelRoot: NSObject {

	public var Addresses: [Address] = [Address]()
	
	public var Balance: Double = 0
	
	public var Dimension: BalanceDimension = .SIB
	
	public var HistoryItems: History = History()
	
	init(_ app: AppDelegate) {
		super.init()
		reload(app)
	}
	
	func reload(_ app: AppDelegate) {
		do {
			let moc = app.persistentContainer.viewContext
			Addresses = try moc.fetch(Address.fetchRequest()) as! [Address]
		} catch {
			Addresses = [Address]()
		}
	}
	
	func refresh() {
		//Обновляем
		NSLog("%i", Addresses.count)
	}
	
	func add(_ address: String) {
		for  a in Addresses {
			if (a.address == address) { return }
		}
		let app = (UIApplication.shared.delegate as! AppDelegate)
		let moc = app.persistentContainer.viewContext
		let a = NSEntityDescription.insertNewObject(forEntityName: "Address", into: moc) as! Address
		a.address = address
		a.ballance = nil
		a.update_date = nil
		try! moc.save()
		reload(app)
		refresh()
	}
}
