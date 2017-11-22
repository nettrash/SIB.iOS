//
//  Wallet.swift
//  sib-lite
//
//  Created by Иван Алексеев on 14.11.2017.
//  Copyright © 2017 NETTRASH. All rights reserved.
//

import Foundation
import CoreData
import CommonCrypto

public class Wallet : NSObject {
	
	private let KeyTypePublic: UInt8 = 0x3f
	private let KeyTypePrivate: UInt8 = 0x80
	private let KeyTypeMultisign: UInt8 = 0x28
	
	private let Ticker: String = "SIB"
	private let URIScheme: String = "sibcoin:"
	
	private let OperationReturnMax: Int8 = 40
	
	private let Compressed: Bool = true
	
	private var PrivateKey: Data?
	private var PublicKey: Data?
	private var Address: String?
	
	private let appDelegate: AppDelegate?
	
	init(_ app: AppDelegate) {
		appDelegate = app
		super.init()
	}
	
	private func sha256(_ data : Data) -> Data {
		var hash = [UInt8](repeating: 0,  count: Int(CC_SHA256_DIGEST_LENGTH))
		data.withUnsafeBytes {
			_ = CC_SHA256($0, CC_LONG(data.count), &hash)
		}
		return Data(bytes: hash)
	}
	
	private func generatePublicKey() -> Data {
		let privateKeyBigInteger: BigInteger = BigInteger(PrivateKey!)
		let curve: EllipticCurve = EllipticCurve()
		let curvePt: PointFP = curve.G!.multiply(privateKeyBigInteger)
		let x = curvePt.x!.toBigInteger()
		let y = curvePt.y!.toBigInteger()
		
		if Compressed {
			if y.isEven() {
				return Data(EllipticCurve.integerToBytes(x, 32).shifted(by: -0x02))
			} else {
				return Data(EllipticCurve.integerToBytes(x, 32).shifted(by: -0x03))
			}
		} else {
			return Data(EllipticCurve.integerToBytes(x, 32) + EllipticCurve.integerToBytes(y, 32))
		}
	}
	
	public func initialize(_ secret: String) -> Void {
		let sourceForPrivateKey: String = "SIBPrivateKey\(3571 * secret.lengthOfBytes(using: String.Encoding.ascii))\(secret)NETTRASHSIB"
		let sourceForPrivateKeyData: Data = sourceForPrivateKey.data(using: String.Encoding.utf8)!
		PrivateKey = sha256(sourceForPrivateKeyData)
		PublicKey = generatePublicKey()
		Address = sibAddress.forKey(PublicKey!)
	}
}
