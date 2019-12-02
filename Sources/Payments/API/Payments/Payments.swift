//
//  Payments.swift
//  
//
//  Created by Neil Smith on 26/08/2019.
//

import Foundation

public class Payments: NSObject, PaymentsProcessing {
    
    
    // MARK: Interface
    public init(configuration: PaymentsConfiguring, storeController: StoreControlling) {
        self.simulateAskToBuy = configuration.simulateAskToBuy
        self.storeController = storeController
        super.init()
    }
    
    public weak var observer: PaymentsObserving?

    
    // MARK: Read only
    public private (set) var availableProducts: Set<Product> = []

    public var canMakePayments: Bool {
        return storeController.canMakePayments
    }

    
    // MARK: Private
    private let storeController: StoreControlling

    private var productIdentifiers: Set<String> {
        return storeController.productIdentifiers
    }

    private let simulateAskToBuy: Bool
    
    
    // MARK: Overrides
    
    /// Subclasses of 'Payments' must override this method to verify purchases
    /// You do not need to call super.
    public func verifyPurchases() {}
    
}


// MARK: - Notifications
extension Payments {
    
    public func add(observer: Any, forPaymentEvent kind: PaymentEventKind, selector: Selector) {
        NotificationCenter.default.addObserver(
            observer,
            selector: selector,
            name: kind.notification,
            object: nil
        )
    }
    
    public func remove(observer: Any, forPaymentEvent kind: PaymentEventKind) {
        NotificationCenter.default.removeObserver(observer, name: kind.notification, object: nil)
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

    public func purchase(_ product: Product) {
        storeController.purchase(product: product, simulateAskToBuy: simulateAskToBuy) { [weak self] result in
            self?.handle(payment: result)
        }
    }
    
    public func restorePreviousPurchases() {
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
