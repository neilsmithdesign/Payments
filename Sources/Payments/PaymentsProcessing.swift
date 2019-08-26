//
//  PaymentsProcessing.swift
//  
//
//  Created by Neil Smith on 26/08/2019.
//

import Foundation

public protocol PaymentsProcessing {
    var observer: PaymentsObserving? { get }
    var availableProducts: Set<Product> { get }
    func loadProducts()
    func makeInAppPurchase(for product: Product)
    func restoreInAppPurchases()
}
