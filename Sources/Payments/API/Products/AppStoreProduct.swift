//
//  AppStoreProduct.swift
//  
//
//  Created by Neil Smith on 03/12/2019.
//

import StoreKit

/**
 A representation of an in-app purchase.
 Contains the underlying StoreKit product.
 */
public final class AppStoreProduct: Product {
    
    /// The associated SKProduct
    public private (set) var storeKitProduct: SKProduct
    
    /// Convenience method for initiating a payment for this product
    func preparedStoreKitPayment() -> SKMutablePayment {
        return SKMutablePayment(product: storeKitProduct)
    }
    
    public convenience init(storeKit product: SKProduct) {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        if formatter.locale != product.priceLocale {
            formatter.locale = product.priceLocale
        }
        self.init(
            title: product.localizedTitle,
            description: product.localizedDescription,
            price: product.price,
            formatter: formatter,
            identifier: product.productIdentifier,
            storeKitProduct: product
        )
    }
    
    private init(title: String, description: String, price: NSDecimalNumber, formatter: NumberFormatter? = nil, identifier: String, storeKitProduct: SKProduct? = nil) {
        let nf: NumberFormatter
        if let f = formatter {
            nf = f
        } else {
            nf = NumberFormatter()
            nf.numberStyle = .currency
        }
        let priceString = nf.string(from: price) ?? "\(price.decimalValue)"
        self.storeKitProduct = storeKitProduct ?? SKProduct()
        super.init(
            title: title,
            description: description,
            price: priceString,
            numericalPrice: price,
            identifier: identifier
        )
    }
    
}
