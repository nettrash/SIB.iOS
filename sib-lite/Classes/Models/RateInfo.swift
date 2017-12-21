//
//  RateInfo.swift
//  sib-lite
//
//  Created by Иван Алексеев on 18.12.2017.
//  Copyright © 2017 NETTRASH. All rights reserved.
//

import Foundation

public class RateInfo : NSObject {
	
	var Currency: String?
	var Rate: Double?
	
	public init(currency: String, rate: Double) {
		Currency = currency
		Rate = rate
	}
}
