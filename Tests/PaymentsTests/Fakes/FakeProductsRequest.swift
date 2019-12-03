//
//  FakeProductsRequest.swift
//  
//
//  Created by Neil Smith on 03/12/2019.
//

import StoreKit
@testable import Payments

final class FakeProductsRequest: SKProductsRequest {
    
    private let productIdentifiersInAppStoreConnect: Set<ProductIdentifier> = [
        "com.NeilSmithDesignLTD.Payments.fake.product"
    ]
    
    private let suppliedProductIdentifiers: Set<ProductIdentifier>
    
    override init(productIdentifiers: Set<ProductIdentifier>) {
        self.suppliedProductIdentifiers = productIdentifiers
        super.init()
    }
    
    override func start() {
        let valid = suppliedProductIdentifiers.intersection(productIdentifiersInAppStoreConnect)
        let invalid = suppliedProductIdentifiers.subtracting(productIdentifiersInAppStoreConnect)
        let response = FakeProductResponse(validIdentifiers: valid, invalidIdentifiers: invalid)
        delegate?.productsRequest(self, didReceive: response)
    }
    
}
