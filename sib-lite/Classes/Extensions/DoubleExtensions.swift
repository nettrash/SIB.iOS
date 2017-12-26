//
//  DoubleExtensions.swift
//  sib-lite
//
//  Created by Иван Алексеев on 26.12.2017.
//  Copyright © 2017 NETTRASH. All rights reserved.
//

import Foundation

extension Double {

	func rounded(toPlaces places:Int) -> Double {
		let divisor = pow(10.0, Double(places))
		return (self * divisor).rounded() / divisor
	}
}
