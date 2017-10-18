//
//  TransactionHistory.swift
//  sib-lite
//
//  Created by Иван Алексеев on 18.10.2017.
//  Copyright © 2017 NETTRASH. All rights reserved.
//

import Foundation

public class History: NSObject {
	
	var Items: [HistoryItem] = []
	
	override init() {
		super.init()
		Items.append(HistoryItem(type: .Incoming, date: Date.init(timeIntervalSinceNow: -1000), amount: 100))
		Items.append(HistoryItem(type: .Outgoing, date: Date.init(timeIntervalSinceNow: -500), amount: 25))
		Items.append(HistoryItem(type: .Outgoing, date: Date.init(timeIntervalSinceNow: -100), amount: 75))
	}
}
