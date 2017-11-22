//
//  FieldElementFP.swift
//  sib-lite
//
//  Created by Иван Алексеев on 17.11.2017.
//  Copyright © 2017 NETTRASH. All rights reserved.
//

import Foundation

public class FieldElementFP : NSObject {
	
	public enum Exception : Error {
		case EvenValueOfQ
	}
	
	private var Q: BigInteger?
	private var X: BigInteger?
	
	init(_ q: BigInteger, _ x: BigInteger) {
		Q = q
		X = x
		super.init()
	}
	
	public func toBigInteger() -> BigInteger {
		return X!
	}
	
	public func negate() -> FieldElementFP {
		return FieldElementFP(Q!, X!.negate().mod(Q!))
	}
}
