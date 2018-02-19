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
	var price: Double?
	var currency: String?
	var status: String?
	var itemDesc: String?
	var orderId: String?
	var url: String?
	var posData: String?
	var id: String?
	var buyerProvidedEmail: String?
	var redirectUrl: String?
	var bitcoinAddress: String?
	var btcDue: Double?
	
	init(_ jsonData: String) {
		valid = false
		let json = try? JSONSerialization.jsonObject(with: jsonData.data(using: String.Encoding.utf8)!, options: [])
		if let json = json as? [String:Any] {
			valid = true
			price = json["price"] as? Double
			currency = json["currency"] as? String
			status = json["status"] as? String
			itemDesc = json["itemDesc"] as? String
			orderId = json["orderId"] as? String
			url = json["url"] as? String
			posData = json["posData"] as? String
			id = json["id"] as? String
			buyerProvidedEmail = json["buyerProvidedEmail"] as? String
			redirectUrl = json["redirectUrl"] as? String
			bitcoinAddress = json["bitcoinAddress"] as? String
			btcDue = json["btcDue"] as? Double
		}
	}
	
}
