//
//  PaymentsProcessing.swift
//  
//
//  Created by Neil Smith on 26/08/2019.
//

import Foundation

/// Interface to Payments.swift. Permits intergation testing with a fake object
public protocol PaymentsProcessing {
    var observer: PaymentsObserving? { get set }
    func verifyPurchases()
    var availableProducts: Set<Product> { get }
    func loadProducts()
    func purchase(_ product: Product)
    func restorePreviousPurchases()
}
