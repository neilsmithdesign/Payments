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
    public let numericalPrice: NSDecimalNumber
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
        self.numericalPrice = product.price
        self.price = formatter.string(from: product.price) ?? "\(product.price)"
        self.identifier = product.productIdentifier
        self.storeKitProduct = product
    }
}

public extension Product {
    
    static func createMock(title: String, description: String, price: Decimal, identifier: String) -> Product {
        return .init(title: title, description: description, price: price, identifier: identifier)
    }
    
    private init(title: String, description: String, price: Decimal, identifier: String) {
        self.title = title
        self.description = description
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        let numericalPrice = NSDecimalNumber(decimal: price)
        self.numericalPrice = numericalPrice
        self.price = formatter.string(from: numericalPrice) ?? ""
        self.identifier = identifier
        self.storeKitProduct = SKProduct()
    }
    
}

extension Product: Hashable {
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(identifier)
    }
    
}
