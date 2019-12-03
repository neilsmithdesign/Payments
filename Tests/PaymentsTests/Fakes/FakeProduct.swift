//
//  FakeProduct.swift
//  
//
//  Created by Neil Smith on 03/12/2019.
//

import StoreKit
@testable import Payments

final class FakeProduct: SKProduct {
    
    private let fakeIdentifier: String
    
    init(fakeIdentifier: String = "com.NeilSmithDesignLTD.Payments.fake.product") {
        self.fakeIdentifier = fakeIdentifier
    }
    
    override var priceLocale: Locale {
        return Locale(identifier: "en_GB")
    }
    
    override var localizedTitle: String {
        return "Fake Product"
    }
    
    override var localizedDescription: String {
        return "Very fake"
    }
    
    override var price: NSDecimalNumber {
        return NSDecimalNumber(floatLiteral: 4.99)
    }
    
    override var productIdentifier: String {
        return fakeIdentifier
    }
    
}
