//
//  DataExtensions.swift
//  sib-lite
//
//  Created by Иван Алексеев on 12.12.2017.
//  Copyright © 2017 NETTRASH. All rights reserved.
//

import Foundation

extension Data {
	
	func hexEncodedString() -> String {
		return map { String(format: "%02hhx", $0) }.joined()
	}
	
	func fileUrl(withName name: String) -> URL {
		
		let url = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent(name)
		
		try! write(to: url, options: .atomicWrite)
		
		return url
	}
}
