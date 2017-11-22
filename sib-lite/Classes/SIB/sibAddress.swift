//
//  sibAddress.swift
//  sib-lite
//
//  Created by Иван Алексеев on 12.10.2017.
//  Copyright © 2017 NETTRASH. All rights reserved.
//

import Foundation
import CommonCrypto

class sibAddress: NSObject {
	
	enum sibAddressError : Error {
		case InvalidCharacter
		case AddressTooLong
	}
	
	static let Alphabet = "123456789ABCDEFGHJKLMNPQRSTUVWXYZabcdefghijkmnopqrstuvwxyz"
	static let Size = 25

	private static func decodeBase58(_ input: String) throws -> Data {
		var output = [UInt8](repeating: 0, count: Size)
		
		for t in input {
			let range: Range<String.Index> = Alphabet.range(of: String(t))!
			var p = range.upperBound.encodedOffset - 1
			
			if (p < 0) {
				throw sibAddressError.InvalidCharacter
			}
			
			var j = Size
			
			while (j > 0) {
				j = j - 1
				p = p + 58 * Int(output[j])
				
				output[j] = UInt8(p % 256)
				
				p = p / 256
			}
			
			if (p != 0) {
				throw sibAddressError.AddressTooLong
			}
		}
		
		return Data(output)
	}
	
	private static func sha256(_ data : Data) -> Data {
		var hash = [UInt8](repeating: 0,  count: Int(CC_SHA256_DIGEST_LENGTH))
		data.withUnsafeBytes {
			_ = CC_SHA256($0, CC_LONG(data.count), &hash)
		}
		return Data(bytes: hash)
	}
	
	private static func subArray(_ data: Data, index: Int, length: Int) -> Data {
		return data.subdata(in: index..<index+length)
	}
	
	static func verify(_ address: String?) -> Bool {
		do
		{
			if (address == nil) {
				return false
			}
			if (address?.count ?? 0 < 26 || address?.count ?? 0 > 35) {
				return false
			}
			if (!address!.starts(with: "S")) {
				return false
			}
			let decoded = try decodeBase58(address!)
			let d1 = sha256(subArray(decoded, index: 0, length: 21))
			let d2 = sha256(d1)
			if (decoded[21] != d2[0] ||
				decoded[22] != d2[1] ||
				decoded[23] != d2[2] ||
				decoded[24] != d2[3]) {
				return false
			}
		
			return true
		}
		catch
		{
			return false
		}
	}
	
	static func forKey(_ key: Data) -> String {
		return ""
	}
}
