//
//  FakeProductResponse.swift
//  
//
//  Created by Neil Smith on 03/12/2019.
//

import StoreKit
@testable import Payments

final class FakeProductResponse: SKProductsResponse {
    
    private let validIdentifiers: Set<ProductIdentifier>
    private let invalidIdentifiers: Set<ProductIdentifier>
    
    init(validIdentifiers: Set<ProductIdentifier>, invalidIdentifiers: Set<ProductIdentifier>) {
        self.validIdentifiers = validIdentifiers
        self.invalidIdentifiers = invalidIdentifiers
    }
    
    override var products: [SKProduct] {
        return validIdentifiers.map { _ in FakeProduct() }
    }
    
    override var invalidProductIdentifiers: [String] {
        return invalidIdentifiers.map { $0 }
    }
    
}
