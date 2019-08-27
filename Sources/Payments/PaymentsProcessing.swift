//
//  PaymentsProcessing.swift
//  
//
//  Created by Neil Smith on 26/08/2019.
//

import Foundation

/// Interface to Payments.swift. Permits testing with a fake object
public protocol PaymentsProcessing {
    func add(observer: PaymentsObserving)
    func remove(observer: PaymentsObserving)
    var availableProducts: Set<Product> { get }
    func loadProducts()
    func makeInAppPurchase(for product: Product)
    func restoreInAppPurchases()
}
