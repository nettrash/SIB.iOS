//
//  bitpayInvoice.swift
//  sib-lite
//
//  Created by Иван Алексеев on 17.02.2018.
//  Copyright © 2018 NETTRASH. All rights reserved.
//

import Foundation

/*
bitcoin:?r=https://bitpay.com/i/ShvPHvxLuwARmnLisSmnBg

https://bitpay.com/invoices/ShvPHvxLuwARmnLisSmnBg

{
	"facade":"public/invoice",
	"data":
	{
		"url":"https://bitpay.com/invoice?id=ShvPHvxLuwARmnLisSmnBg",
		"posData":"{\"D\":\"975447ff-7437-4c23-9e50-a80d2f4dbbf9|afedron|1539727934\"}",
		"status":"expired",
		"btcPrice":"0.001003",
		"btcDue":"0.001027",
		"price":10,
		"currency":"USD",
		"itemDesc":"Add funds to your Namecheap.com account",
		"orderId":"975447ff-7437-4c23-9e50-a80d2f4dbbf9",
		"invoiceTime":1518774292767,
		"expirationTime":1518775192767,
		"currentTime":1518782260380,
		"id":"ShvPHvxLuwARmnLisSmnBg",
		"lowFeeDetected":false,
		"amountPaid":0,
		"btcPaid":"0.000000",
		"rate":9969,
		"exceptionStatus":false,
		"redirectURL":"https://ap.www.namecheap.com/Profile/Billing/TopupComplete/BitCoin",
		"refundAddressRequestPending":false,
		"buyerProvidedEmail":"nettrash@yandex.ru",
		"buyerProvidedInfo":
		{
			"emailAddress":"nettrash@yandex.ru",
			"selectedTransactionCurrency":"BTC"
		},
		"addresses":
		{
			"BTC":"16Wb8rBHyyGfGwEGaHnaigpkt5anCphSxB"
		},
		"paymentSubtotals":
		{
			"BTC":100300
		},
		"paymentTotals":
		{
			"BTC":102700
		},
		"bitcoinAddress":"16Wb8rBHyyGfGwEGaHnaigpkt5anCphSxB",
		"exchangeRates":
		{
			"BTC":
			{
				"USD":9968.997119163414
			}
		},
		"minerFees":
		{
			"BTC":
			{
				"totalFee":2400,
				"satoshisPerByte":16
			}
		},
		"buyerPaidBtcMinerFee":"0.000024",
		"supportedTransactionCurrencies":
		{
			"BTC":
			{
				"enabled":true
			}
		},
		"exRates":
		{
			"BTC":1,
			"USD":9968.997119163414
		},
		"paymentUrls":
		{
			"BIP21":"bitcoin:16Wb8rBHyyGfGwEGaHnaigpkt5anCphSxB?amount=0.001027",
			"BIP72":"bitcoin:16Wb8rBHyyGfGwEGaHnaigpkt5anCphSxB?amount=0.001027&r=https://bitpay.com/i/ShvPHvxLuwARmnLisSmnBg",
			"BIP72b":"bitcoin:?r=https://bitpay.com/i/ShvPHvxLuwARmnLisSmnBg",
			"BIP73":"https://bitpay.com/i/ShvPHvxLuwARmnLisSmnBg"
		},
		"paymentCodes":
		{
			"BTC":
			{
				"BIP21":"bitcoin:16Wb8rBHyyGfGwEGaHnaigpkt5anCphSxB?amount=0.001027",
				"BIP72":"bitcoin:16Wb8rBHyyGfGwEGaHnaigpkt5anCphSxB?amount=0.001027&r=https://bitpay.com/i/ShvPHvxLuwARmnLisSmnBg",
				"BIP72b":"bitcoin:?r=https://bitpay.com/i/ShvPHvxLuwARmnLisSmnBg",
				"BIP73":"https://bitpay.com/i/ShvPHvxLuwARmnLisSmnBg"
			}
		},
		"token":"5uqeA84nXkFyYDAk2yW3RJre9AQnfQSCAhkCqZtqG5D4X1djRnUgWS5xXyktxvA6L"
	}
}

*/

class bitpayInvoice {
	
	var valid: Bool
	
	public var url: URL?
	public var posData: String?
	public var status: String?
	public var btcPrice: Double?
	public var btcDue: Double?
	public var price: Double?
	public var currency: String?
	public var itemDesc: String?
	public var orderId: String?
	public var invoiceTime: Date?
	public var expirationTime: Date?
	public var currentTime: Date?
	public var id: String?
	public var lowFeeDetected: Bool?
	public var amountPaid: Double?
	public var btcPaid: Double?
	public var rate: Double?
	public var exceptionStatus: Bool?
	public var redirectURL: URL?
	public var refundAddressRequestPending: Bool?
	public var buyerProvidedEmail: String?
	public var buyerProvidedInfo: bitpayBuyerProvidedInfo?
	public var addresses: [String:String]?
	public var paymentSubtotals: [String:Double]?
	public var paymentTotals: [String:Double]?
	public var bitcoinAddress: String?
	public var exchangeRates: bitpayExchangeRates?
	public var minerFees: bitpayMinerFees?
	public var buyerPaidBtcMinerFee: Double?
	public var supportedTransactionCurrencies: bitpaySupportedTransactionCurrencies?
	public var exRates: [String:Double]?
	public var paymentUrls: [String:String]?
	public var paymentCodes: bitpayPaymentCodes?
	public var token: String?
	
	init(_ jsonData: String) {
		valid = false
		let json = try? JSONSerialization.jsonObject(with: jsonData.data(using: String.Encoding.utf8)!, options: [])
		if let json = json as? [String:Any] {
			valid = true

			url = URL(string: json["url"] as? String ?? "")
			posData = json["posData"] as? String
			status = json["status"] as? String
			btcPrice = (Decimal(string: json["btcPrice"] as? String ?? "") as NSDecimalNumber?)?.doubleValue
			btcDue = (Decimal(string: json["btcDue"] as? String ?? "") as NSDecimalNumber?)?.doubleValue
			price = json["price"] as? Double
			currency = json["currency"] as? String
			itemDesc = json["itemDesc"] as? String
			orderId = json["orderId"] as? String
			if let invoiceTimeInterval = json["invoiceTime"] as? Double {
				invoiceTime = Date(timeIntervalSince1970: invoiceTimeInterval)
			}
			if let exoirationTimeInterval = json["expirationTime"] as? Double {
				expirationTime = Date(timeIntervalSince1970: exoirationTimeInterval)
			}
			if let currentTimeInterval = json["currentTime"] as? Double {
				currentTime = Date(timeIntervalSince1970: currentTimeInterval)
			}
			id = json["id"] as? String
			lowFeeDetected = json["lowFeeDetected"] as? Bool
			amountPaid = json["amountPaid"] as? Double
			btcPaid = (Decimal(string: json["btcPaid"] as? String ?? "") as NSDecimalNumber?)?.doubleValue
			rate = json["rate"] as? Double
			exceptionStatus = json["exceptionStatus"] as? Bool
			redirectURL = URL(string: json["redirectURL"] as? String ?? "")
			refundAddressRequestPending = json["refundAddressRequestPending"] as? Bool
			buyerProvidedEmail = json["buyerProvidedEmail"] as? String
			if let buyerProvidedInfoSource = json["buyerProvidedInfo"] as? [String:String] {
				buyerProvidedInfo = bitpayBuyerProvidedInfo()
				buyerProvidedInfo?.emailAddress = buyerProvidedInfoSource["emailAddress"]
				buyerProvidedInfo?.selectedTransactionCurrency = buyerProvidedInfoSource["selectedTransactionCurrency"]
			}
			addresses = json["addresses"] as? [String:String]
			paymentSubtotals = json["paymentSubtotals"] as? [String:Double]
			paymentTotals = json["paymentTotals"] as? [String:Double]
			bitcoinAddress = json["bitcoinAddress"] as? String
			if let exchangeRatesSource = json["exchangeRates"] as? [String:[String:Double]] {
				exchangeRates = bitpayExchangeRates()
				exchangeRates?.BTC = exchangeRatesSource["BTC"]
			}
			if let minerFeesSource = json["minerFees"] as? [String:[String:UInt64]] {
				minerFees = bitpayMinerFees()
				minerFees?.BTC = bitpayMinerFee()
				let btcFee = minerFeesSource["BTC"]
				minerFees?.BTC?.totalFee = btcFee?["totalFee"]
				minerFees?.BTC?.satoshisPerByte = btcFee?["satoshisPerByte"]
			}
			buyerPaidBtcMinerFee = (Decimal(string: json["buyerPaidBtcMinerFee"] as? String ?? "") as NSDecimalNumber?)?.doubleValue
			if let supportedTransactionCurrenciesSource = json["supportedTransactionCurrencies"] as? [String:[String:Any]] {
				supportedTransactionCurrencies = bitpaySupportedTransactionCurrencies()
				if let btcSource = supportedTransactionCurrenciesSource["BTC"] {
					supportedTransactionCurrencies?.BTC = bitpaySupportedTransactionCurrencyInfo()
					supportedTransactionCurrencies?.BTC?.enabled = btcSource["enabled"] as? Bool
				}
			}
			exRates = json["exRates"] as? [String:Double]
			paymentUrls = json["paymentUrls"] as? [String:String]
			if let paymentCodesSource = json["paymentCodes"] as? [String:[String:String]] {
				paymentCodes = bitpayPaymentCodes()
				paymentCodes?.BTC = paymentCodesSource["BTC"]
			}
			token = json["token"] as? String
			
			valid = posData != nil && status != nil && id != nil
		}
	}
	
}
