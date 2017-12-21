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
	
	func luhnCheck() -> Bool {
		var sum = 0
		let reversedCharacters = self.reversed().map { String($0) }
		for (idx, element) in reversedCharacters.enumerated() {
			guard let digit = Int(element) else { return false }
			switch ((idx % 2 == 1), digit) {
			case (true, 9): sum += 9
			case (true, 0...8): sum += (digit * 2) % 9
			default: sum += digit
			}
		}
		return sum % 10 == 0
	}
}

