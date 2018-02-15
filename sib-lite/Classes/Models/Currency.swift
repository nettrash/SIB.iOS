//
//  Currency.swift
//  sib-lite
//
//  Created by Иван Алексеев on 30.12.2017.
//  Copyright © 2017 NETTRASH. All rights reserved.
//

import Foundation

public enum Currency: String {
	case RUB = "RUB"
	case USD = "USD"
	case EUR = "EUR"
	case SIB = "SIB"
	case BTC = "BTC"
	case BIO = "BIO"
	
	func symbol() -> String {
		switch self {
		case .RUB:
			return "₽"
		case .USD:
			return "$"
		case .EUR:
			return "€"
		case .SIB:
			return "SIB"
		case .BTC:
			return "BTC"
		case .BIO:
			return "BIO"
		}
	}
}
