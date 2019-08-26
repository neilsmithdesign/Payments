//
//  Product.swift
//  
//
//  Created by Neil Smith on 26/08/2019.
//

import StoreKit

public struct Product {
    
    public let title: String
    public let description: String
    public let price: String
    public let identifier: String
    public let storeKitProduct: SKProduct
    
    var storeKitPayment: SKMutablePayment {
        return SKMutablePayment(product: storeKitProduct)
    }
    
    public init(storeKit product: SKProduct) {
        self.title = product.localizedTitle
        self.description = product.localizedDescription
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        if formatter.locale != product.priceLocale {
            formatter.locale = product.priceLocale
        }
        self.price = formatter.string(from: product.price) ?? "\(product.price)"
        self.identifier = product.productIdentifier
        self.storeKitProduct = product
    }
}

extension Product: Hashable {
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(identifier)
    }
    
}
