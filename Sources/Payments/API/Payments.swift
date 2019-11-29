//
//  Payments.swift
//  
//
//  Created by Neil Smith on 26/08/2019.
//

import Foundation
import StoreKit


/// Handles all Store Kit related transactions. If not using a separate SKPaymentTransactionObserver,
/// this class must be initiliazed at app launch and held in memory for the duration of the app life cycle.
public final class Payments: NSObject, PaymentsProcessing {
    
    
    // MARK: Interface
    public init(configuration: PaymentsConfiguring, storeController: StoreControlling? = nil, transactionObserver: SKPaymentTransactionObserver? = nil) {
        self.configuration = configuration
        self.storeController = storeController ?? StoreKitController(productIdentifiers: configuration.productIdentifiers, transactionObserver: transactionObserver)
        super.init()
    }
    
    public weak var observer: PaymentsObserving?

    
    // MARK: Read only
    public private (set) var availableProducts: Set<Product> = []

    public var canMakePayments: Bool {
        return storeController.canMakePayments
    }

    
    // MARK: Private
    private let configuration: PaymentsConfiguring
    
    private let storeController: StoreControlling
    
    private var productIdentifiers: Set<String> {
        return configuration.productIdentifiers
    }
    
}


// MARK: - Load products
extension Payments {
    
    public func loadProducts() {
        storeController.loadProducts { [weak self] result in
            switch result {
            case .success(let products):
                self?.availableProducts = products
                self?.didLoad(products)
            case .failure(let error):
                self?.failedToLoadProducts(with: error)
            }
        }
    }
    
}


// MARK: - Purchases
extension Payments {

    public func makeInAppPurchase(for product: Product) {
        storeController.purchase(product: product, simulateAskToBuy: configuration.simulateAskToBuy) { [weak self] result in
            self?.handle(payment: result)
        }
    }
    
    public func restoreInAppPurchases() {
        storeController.restorePurchases { [weak self] result in
            self?.handle(payment: result)
        }
    }
    
    private func handle(payment result: PaymentResult) {
        switch result {
        case .success(let identifier):
            self.didCompletePurchase(for: identifier)
        case .restored(let identifier):
            self.didRestorePurchases(for: identifier)
        case .deferred(let identifier):
            self.paymentWasDeferred(for: identifier)
        case .failure(let error):
            self.paymentFailed(with: PaymentsError(error))
        }
    }
    
}


// MARK: - Observer calls
extension Payments {
    
    private func didLoad(_ products: Set<Product>) {
        onMainThread {
            self.observer?.payments(self, didLoad: products)
            PaymentEvent.LoadProducts.Succeeded.notify(with: products)
        }
    }
    
    private func failedToLoadProducts(with error: Error) {
        let productLoadError = PaymentsError.productLoadRequestFailed(message: error.localizedDescription)
        onMainThread {
            self.observer?.payments(self, didFailWith: productLoadError)
            PaymentEvent.LoadProducts.Failed.notify(with: productLoadError)
        }
    }
    
    private func cannotMakePayments() {
        onMainThread {
            self.observer?.userCannotMake(payments: self)
            PaymentEvent.CannotMakePayments.notify(with: nil)
        }
    }
    
    private func didCompletePurchase(for productIdentifier: ProductIdentifier) {
        onMainThread {
            self.observer?.didCompletePurchase(self)
            PaymentEvent.Payment.Complete.notify(with: productIdentifier)
        }
    }
    
    private func didRestorePurchases(for productIdentifier: ProductIdentifier) {
        onMainThread {
            self.observer?.didRestorePurchases(self)
            PaymentEvent.Payment.Restored.notify(with: productIdentifier)
        }
    }
    
    private func paymentWasDeferred(for productIdentifier: ProductIdentifier) {
        let alert = DeferredAlert.standardMessage(for: productIdentifier)
        onMainThread {
            self.observer?.payments(self, paymentWasDeferred: alert)
            PaymentEvent.Payment.Deferred.notify(with: alert)
        }
    }
    
    private func paymentFailed(with error: PaymentsError) {
        onMainThread {
            self.observer?.payments(self, didFailWith: error)
            PaymentEvent.Payment.Failed.notify(with: error)
        }
    }
    
    private func onMainThread(_ closure: @escaping () -> Void) {
        DispatchQueue.main.async { closure() }
    }
    
}



public extension Payments {
    
    struct DeferredAlert {
        
        public let title: String
        public let message: String
        public let productIdentifier: String
        
        static func standardMessage(for productIdentifier: String) -> DeferredAlert {
            return .init(
                title: "Waiting For Approval",
                message: "Thank you! You can continue to use the app whilst your purchase is pending approval from your family organizer.",
                productIdentifier: productIdentifier
            )
        }
        
    }
    
}
