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
	
	private static func encodeBase58(_ data: Data) -> String {
		let base = BigInteger(58)
		var bi = BigInteger(data)
		var chars: String = ""
		
		while bi.compareTo(base) >= 0 {
			let mod = bi.mod(base)
			chars = String(Alphabet[String.Index(encodedOffset: mod.intValue())]) + chars
			bi = try! bi.subtract(mod).divide(base)
		}
		chars = String(Alphabet[String.Index(encodedOffset: bi.intValue())]) + chars
		for i in 0..<data.count {
			if data[i] == 0x00 {
				chars = String(Alphabet[String.Index(encodedOffset: 0)]) + chars
			} else {
				break
			}
		}
		return chars
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
		let keyHash = sha256(key)
		var md = RIPEMD160()
		md.update(data: keyHash)
		var hashData = md.finalize()
		hashData.insert(0x3f, at: 0)
		let hash = sha256(sha256(hashData))
		hashData.append(contentsOf: hash.subdata(in: 0..<4))
		return encodeBase58(hashData)
	}
	
	static func wifFromPrivateKey(_ key: Data, _ compressed: Bool = true) -> String {
		var d: Data = key
		if compressed {
			d.append(0x01)
		}
		d.insert(0x80, at: 0)
		let hash = sha256(sha256(d))
		d.append(contentsOf: hash.subdata(in: 0..<4))
		return encodeBase58(d)
	}
}
