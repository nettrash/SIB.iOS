//
//  StringExtensions.swift
//  sib-lite
//
//  Created by Иван Алексеев on 16.11.2017.
//  Copyright © 2017 NETTRASH. All rights reserved.
//

import Foundation

extension String {
	var hexa2Bytes: [UInt8] {
		let hexa = Array(self)
		return stride(from: 0, to: count, by: 2).flatMap { UInt8(String(hexa[$0..<$0.advanced(by: 2)]), radix: 16) }
	}
}
