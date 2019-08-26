//
//  Product.swift
//  
//
//  Created by Neil Smith on 26/08/2019.
//

import StoreKit

struct Product {
    
    let title: String
    let description: String
    let price: String
    let identifier: String
    let storeKitProduct: SKProduct
    
    var storeKitPayment: SKMutablePayment {
        return SKMutablePayment(product: storeKitProduct)
    }
    
    init(storeKit product: SKProduct) {
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
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(identifier)
    }
    
}
