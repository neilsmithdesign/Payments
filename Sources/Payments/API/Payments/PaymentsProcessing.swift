//
//  PaymentsProcessing.swift
//  
//
//  Created by Neil Smith on 26/08/2019.
//

import Foundation

/// Interface to Payments.swift. Permits intergation testing with a fake object
public protocol PaymentsProcessing {
    
    /// Direct observer of payments class via a 'delegate-style' method
    var observer: PaymentsObserving? { get set }
    
    /// Add an observer for a specific payment event (sent via NotificationCenter)
    static func add(observer: Any, forPaymentEvent kind: PaymentEventKind, selector: Selector)
    
    /// Remove an observer for a specific payment event (sent via NotificationCenter)
    static func remove(observer: Any, forPaymentEvent kind: PaymentEventKind)
    
    /// Verify the user's existing purchases if they exist. When interacting with the App Store
    /// on iOS, this method retrieves the encrypted App Store receipt from the user's device
    /// and validates it using the supplied receipt validator
    func validateReceipt()
    
    func loadProducts()

    /// A list of the available products for purchase. This can include products a user has
    /// already purchased. Before making a call to loadProducts(), this Set is empty.
    var availableProducts: Set<Product> { get }
    
    /// Initiate the purchase flow for the passed in product. Progess is reported via
    /// both the observer and payment event notifications.
    func purchase(_ product: Product)
    
    /// Restores any previous purchases a user may have made. When interacting with the App Store
    /// this involves inspecting the App Store receipt. Progess is reported via
    /// both the observer and payment event notifications.
    func restorePreviousPurchases()
}
