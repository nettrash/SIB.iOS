//
//  DateExtensions.swift
//  sib-lite
//
//  Created by Иван Алексеев on 27.12.2017.
//  Copyright © 2017 NETTRASH. All rights reserved.
//

import Foundation

extension Date {
	
	func year() -> Int {
		return NSCalendar.current.component(Calendar.Component.year, from: self)
	}
	
	func month() -> Int {
		return NSCalendar.current.component(Calendar.Component.month, from: self)
	}
	
	func day() -> Int {
		return NSCalendar.current.component(Calendar.Component.day, from: self)
	}
	
	func isToday() -> Bool {
		let now = Date()
		return now.year() == self.year() && now.month() == self.month() && now.day() == self.day()
	}
	
	func isYesterday() -> Bool {
		let now = Date()
		return now.year() == self.year() && now.month() == self.month() && now.day() - 1 == self.day()
	}
	
	func isCurrentMonth() -> Bool {
		let now = Date()
		return now.year() == self.year() && now.month() == self.month()
	}
}
