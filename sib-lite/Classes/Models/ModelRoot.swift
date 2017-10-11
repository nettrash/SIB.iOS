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

	public var Addresses: [Address]
	
	init(_ app: AppDelegate) {
		Addresses = [Address]()
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
		//Обновляе
		NSLog("%i", Addresses.count)
	}
	
	func add(_ address: String) {
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
