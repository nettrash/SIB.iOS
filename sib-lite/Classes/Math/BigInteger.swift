//
//  BigInteger.swift
//  sib-lite
//
//  Created by Иван Алексеев on 15.11.2017.
//  Copyright © 2017 NETTRASH. All rights reserved.
//

import Foundation

public class BigInteger : NSObject {
	
	private var _numberData: [Int]
	private var t: Int = 0
	private var s: Int = 0
	
	public enum Exception : Error {
		case DivisionByZero
	}
	
	public var bitLength: Int {
		if t <= 0 { return 0 }
		return 26 * (t - 1) + ((_numberData[t - 1]) ^ (s & ((1 << 26) - 1))).nbits
	}
	
	override public init() {
		_numberData = [Int]()
		super.init()
	}
	
	init(_ data: Data) {
		_numberData = [Int]()

		var bytes: [UInt8] = [UInt8](data)
		
		if bytes[0] & 0x80 > 0 {
			bytes.insert(0, at: 0)
		}
		
		super.init()

		fromBytes(bytes)
	}
	
	private func fromBytes(_ bytes: [UInt8]) -> Void {
		_numberData = [Int]()
		
		var mi: Bool = false
		var sh: Int = 0
		
		for b in bytes.reversed() {
			let x: Int = Int(b & 0xff)
			if x < 0 {
				mi = true
				continue
			}
			mi = false
			if sh == 0 {
				_numberData.insert(x, at:t)
				t = t + 1
			} else {
				if sh + 8 > 26 {
					_numberData[t-1] |= (x & ((1 << (26 - sh)) - 1)) << sh
					_numberData.insert((x >> (26 - sh)), at:t)
					t = t + 1
				} else {
					_numberData[t - 1] |= x << sh
				}
			}
			sh = sh + 8
			if sh >= 26 {
				sh = sh - 26
			}
		}
		if bytes[0] & 0x80 != 0 {
			s = -1
			if sh >= 26 {
				_numberData[t - 1] |= ((1 << (26 - sh)) - 1) << sh
			}
		}
		clamp()
		if (mi) {
			let r = BigInteger(Data([0])).subtract(self)
			s = r.s
			t = r.t
			_numberData = r._numberData
		}
	}
	
	private func clamp() -> Void {
		let c: Int = s & ((1 << 26) - 1)
		while t > 0 && _numberData[t - 1] == c {
			t = t - 1
		}
	}
	
	public func add(_ a: BigInteger) -> BigInteger {
		let retVal = BigInteger()
		var i = 0
		var c = 0
		var m = a.t < t ? a.t : t
		while i < m {
			c += _numberData[i] + a._numberData[i]
			retVal._numberData.insert(c & ((1 << 26) - 1), at: i)
			i = i + 1
			c >>= 26
		}
		if a.t < t {
			c += a.s
			while i < t {
				c += _numberData[i]
				retVal._numberData.insert(c & ((1 << 26) - 1), at: i)
				i = i + 1
				c >>= 26
			}
			c += s
		} else {
			c += s
			while i < a.t {
				c += a._numberData[i]
				retVal._numberData.insert(c & ((1 << 26) - 1), at: i)
				i = i + 1
				c >>= 26
			}
			c += a.s
		}
		retVal.s = c < 0 ? -1 : 0
		if (c > 0) {
			retVal._numberData.insert(c, at: i)
			i = i + 1
		} else {
			if c < 0 {
				retVal._numberData.insert((1 << 26) + c, at: i)
				i = i + 1
			}
		}
		retVal.t = i
		retVal.clamp()
		return retVal
	}
	
	public func subtract(_ a: BigInteger) -> BigInteger {
		let retVal: BigInteger = BigInteger()
		retVal._numberData = [Int]()
		var i = 0
		var c = 0
		let m = a.t < self.t ? a.t : self.t
		while i < m {
			c = c + _numberData[i] - a._numberData[i]
			retVal._numberData.insert(c & ((1 << 26) - 1), at: i)
			i = i + 1
			c = c >> 26
		}
		if a.t < self.t {
			c = c - a.s
			while i < t {
				c = c + _numberData[i]
				retVal._numberData.insert(c & ((1 << 26) - 1), at: i)
				i = i + 1
				c = c >> 26
			}
			c = c + s
		} else {
			c = c + s
			while i < a.t {
				c = c - a._numberData[i]
				retVal._numberData.insert(c & ((1 << 26) - 1), at: i)
				i = i + 1
				c = c >> 26
			}
			c = c - a.s
		}
		retVal.s = c < 0 ? -1 : 0
		if c < -1 {
			retVal._numberData.insert((1 << 26) + c, at: i)
			i = i + 1
		} else {
			if c > 0 {
				retVal._numberData.insert(c, at: i)
				i = i + 1
			}
		}
		retVal.t = i
		retVal.clamp()
		return retVal
	}
	
	public func isEven() -> Bool {
		return (t > 0 ? _numberData[0] & 1 : s) == 0
	}
	
	public func abs() -> BigInteger {
		if s < 0 {
			return negate()
		} else {
			return self
		}
	}
	
	public func negate() -> BigInteger {
		return BigInteger(Data([0])).subtract(self)
	}
	
	public func toByteArray() -> [UInt8] {
		var retVal: [UInt8] = [UInt8]()
		var i = t
		retVal.insert(UInt8(s < 0 ? s + 256 : s), at: 0)
		var p = 26 - (i * 26) % 8
		var k = 0
		if i > 0 {
			i = i - 1
			var d = _numberData[i]
			if (p < 26) && ( ( d >> p ) !=  ((s & ((1 << 26) - 1)) >> p ) ) {
				retVal.insert(UInt8(d | s << (26 - p)), at: k)
				k = k + 1
			}
			while i >= 0 {
				if p < 8 {
					d = _numberData[i] & (( 1 << p) - 1) << (8 - p)
					p = p + 26 - 8
					i = i - 1
					d |= _numberData[i] >> p
				} else {
					d = (_numberData[i] >> (p - 8)) & 0xff
					if (p <= 0) {
						p = p + 26
						i = i - 1
					}
				}
				if d & 0x80 != 0 {
					d |= -256
					if k == 0 && s & 0x80 != d & 0x80 {
						k = k + 1
					}
					if k > 0 || d != s {
						retVal.insert(UInt8(d), at: k)
						k = k + 1
					}
				}
			}
		}
		return retVal
	}
	
	public func toByteArrayUnsigned() -> [UInt8] {
		var ba = abs().toByteArray()

		if ba.count < 1 {
			return ba
		}
		if (ba[0] == 0) {
			ba = [UInt8](ba[1...])
		}
		return ba
	}
	
	public func signum() -> Int {
		if s < 0 { return -1 }
		if t <= 0 || (t == 1 && _numberData[0] <= 0) { return 0 }
		return 1
	}
	
	public func compareTo(_ a: BigInteger) -> Int {
		var r = s - a.s
		if r != 0 { return r }
		var i = t
		r = i - a.t
		if r != 0 { return s < 0 ? -r : r }
		while i >= 0 {
			i = i - 1
			r = _numberData[i] - a._numberData[i]
			if r != 0 { return r }
		}
		return 0
	}
	
	public func equals(_ b: BigInteger) -> Bool {
		return compareTo(b) == 0
	}
	
	public func mod(_ a: BigInteger) -> BigInteger {
		var retVal: BigInteger = try! abs().div(a)
		if s < 0 && retVal.compareTo(BigInteger(Data([0]))) > 0 { retVal = a.subtract(retVal)}
		return retVal
	}
	
	public func lShift(_ n: Int) -> BigInteger {
		let bs = n % 26
		let cbs = 26 - bs
		let bm = (1 << cbs) - 1
		let ds = floor(Double(n) / 26)
		var c = (s << bs) & ((1 << 26) - 1)
		let r: BigInteger = BigInteger()
		for i in t-1...0 {
			r._numberData.insert((_numberData[i] >> cbs) | c, at: i+Int(ds)+1)
			c = (_numberData[i] & bm) << bs
		}
		for i in (Int)(ds)-1...0 {
			r._numberData.insert(0, at: i)
		}
		r._numberData.insert(c, at: Int(ds))
		r.t = t + Int(ds) + 1
		r.s = s
		r.clamp()
		return r
	}
	
	public func dlShift(_ n: Int) -> BigInteger {
		let retVal: BigInteger = BigInteger()
		for i in (t - 1)...0 {
			retVal._numberData.insert(_numberData[i], at: i+n)
		}
		for i in (n-1)...0 {
			retVal._numberData.insert(0, at: i)
		}
		retVal.t = t + n
		retVal.s = s
		return retVal
	}
	
	public func rShift(_ n: Int) -> BigInteger {
		let retVal : BigInteger = BigInteger()
		retVal.s = s
		let ds = Int(floor(Double(n) / Double(26)))
		if ds > t {
			retVal.t = 0
			return retVal
		}
		let bs = n % 26
		let cbs = 26 - bs
		let bm = (1 << bs) - 1
		retVal._numberData.insert(_numberData[ds] >> bs, at: 0)
		for i in (ds+1)...t {
			retVal._numberData.insert((s & bm) << cbs, at: i - ds - 1)
			retVal._numberData.insert(_numberData[i] >> bs, at: i - ds)
		}
		if bs > 0 {
			retVal._numberData[t - ds - 1] |= (s & bm) << cbs
		}
		retVal.t = t - ds
		retVal.clamp()
		return retVal
	}
	
	public func shiftLeft(_ n: Int) -> BigInteger {
		if n < 0 {
			return rShift(-n)
		} else {
			return lShift(n)
		}
	}
	
	public func div(_ m: BigInteger) throws -> BigInteger {
		let pm = m.abs()
		if pm.t <= 0 { throw Exception.DivisionByZero }
		let pt = self.abs()
		if pt.t < pm.t {
			return self
		}
		var y: BigInteger
		let ts = self.s
		let ms = m.s
		
		let nsh = 26 - pm._numberData[pm.t - 1].nbits
		var r: BigInteger
		if nsh > 0 {
			y = pm.lShift(nsh)
			r = pt.lShift(nsh)
		} else {
			y = pm
			r = pt
		}
		
		let ys = y.t
		let y0 = y._numberData[ys - 1]
		if y0 == 0 { return r}
		let yt = (y0 * (1 << (52 - 26))) + Int((ys > 1 ? y._numberData[ys - 2] >> (2 * 26 - 52) : 0))
		let d1 = pow(2, 52) / Double(yt)
		let d2 = Double(1 << (52 - 26)) / Double(yt)
		let e = 1 << (2 * 26 - 52)
		
		var i = r.t
		var j = i - ys
		var tt = y.dlShift(j)
		if r.compareTo(tt) >= 0 {
			r._numberData.insert(1, at: r.t)
			r.t = r.t + 1
			r = r.subtract(tt)
		}
		tt = BigInteger(Data([1])).dlShift(ys)
		y = tt.subtract(y)
		while y.t < ys {
			y._numberData.insert(0, at: y.t)
			y.t = y.t + 1
		}
		j = j - 1
		while j >= 0 {
			i = i - 1
			var qd: Int = 0
			if r._numberData[i] == y0 {
				qd = (1 << 26) - 1
			} else {
				let k1: Double = Double(r._numberData[i]) * d1
				let k2: Double = Double(Double(r._numberData[i-1]) + Double(e)) * d2
				qd = Int(floor(k1 + k2))
			}
			r._numberData[i] = r._numberData[i] + y.am(0, qd, r, j, 0, ys)
			if r._numberData[i] < qd {
				tt = y.dlShift(j)
				r = r.subtract(tt)
			}
			qd = qd - 1
			while r._numberData[i] < qd {
				r = r.subtract(tt)
				qd = qd - 1
			}
			j = j - 1
		}
		r.t = ys
		r.clamp()
		if nsh > 0 {
			r = r.rShift(nsh)
		}
		if ts < 0 {
			r = BigInteger(Data([0])).subtract(r)
		}
		return r
	}
	
	public func am(_ i: Int, _ x: Int, _ w: BigInteger, _ j: Int, _ c: Int, _ n: Int) -> Int {
		var nn = n - 1
		var ii = i
		var cc = c
		var jj = j
		while nn >= 0 {
			let v = x * _numberData[ii] + w._numberData[jj] + cc
			ii = ii + 1
			cc = Int(floor(Double(v) / Double(0x4000000)))
			w._numberData[jj] = Int(cc & 0x3ffffff)
			jj = jj + 1
			nn = nn - 1
		}
		return cc
	}
	
	public func multiply(_ a: BigInteger) -> BigInteger {
		var retVal: BigInteger = BigInteger()
		let x = abs()
		let y = a.abs()
		var i = x.t
		retVal.t = i + y.t
		i = i - 1
		while i >= 0 {
			retVal._numberData.insert(0, at: i)
			i = i - 1
		}
		for i in 0...y.t {
			retVal._numberData.insert(x.am(0, y._numberData[i], retVal, i, 0, x.t), at: i + x.t)
		}
		retVal.s = 0
		retVal.clamp()
		if s != a.s {
			retVal = BigInteger(Data([0])).subtract(retVal)
		}
		return retVal
	}
	
	public func testBit(_ n: Int) -> Bool {
		let j = Int(floor(Double(n) / Double(26)))
		if j >= t { return s != 0 }
		return _numberData[j] & (1 << (n % 26)) != 0
	}
	
	public func square() -> BigInteger {
		let retVal = BigInteger()
		let x = abs()
		retVal.t = 2 * x.t
		for i in retVal.t-1...0 {
			retVal._numberData.insert(0, at: i)
		}
		for i in 0...x.t-1 {
			let c = x.am(i, x._numberData[i], retVal, 2*i, 0, 1)
			retVal._numberData[i+x.t] += x.am(i+1, 2*x._numberData[i], retVal, 2*i+1, c, x.t-i-1)
			if retVal._numberData[i+x.t] >= 1 << 26 {
				retVal._numberData[i + x.t] -= 1 << 26
				retVal._numberData[i + x.t + 1] = 1
			}
		}
		if retVal.t > 0 {
			retVal._numberData[retVal.t-1] += x.am(x.t, x._numberData[retVal.t], retVal, 2*x.t, 0, 1)
		}
		retVal.s = 0
		retVal.clamp()
		return retVal
	}
}
