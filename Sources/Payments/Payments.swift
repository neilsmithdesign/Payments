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
    public init(configuration: Payments.Configuration, transactionObserver: SKPaymentTransactionObserver? = nil) {
        self.configuration = configuration
        super.init()
        if let observer = transactionObserver {
            SKPaymentQueue.default().add(observer)
        } else {
            SKPaymentQueue.default().add(self)
        }
    }
    
    public func add(observer: PaymentsObserving) {
        let observation = Observation(observer: observer)
        self.observations[ObjectIdentifier(observer)] = observation
    }
    
    public func remove(observer: PaymentsObserving) {
        self.observations.removeValue(forKey: ObjectIdentifier(observer))
    }
    
    
    // MARK: Read only
    public private (set) var availableProducts: Set<Product> = []

    public static var canMakePayments: Bool {
        return SKPaymentQueue.canMakePayments()
    }

    
    // MARK: Private
    private let configuration: Payments.Configuration
    
    private var productIdentifiers: Set<String> {
        return configuration.productIdentifiers
    }
    
    private lazy var productsRequest: SKProductsRequest = {
        let pr = SKProductsRequest(productIdentifiers: self.productIdentifiers)
        pr.delegate = self
        return pr
    }()
    
    
    // MARK: Observations
    private var observations: [ObjectIdentifier : Observation] = [:]
    
}


// MARK: - Product Request
extension Payments: SKProductsRequestDelegate {
    
    public func loadProducts() {
        productsRequest.start()
    }
    
    public func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        availableProducts = Set(response.products.map { Product(storeKit: $0) })
        didLoad(availableProducts)
    }
    
}


// MARK: - Purchases
extension Payments {

    
    public func makeInAppPurchase(for product: Product) {
        guard Payments.canMakePayments else {
            cannotMakePayments()
            return
        }
        let payment = product.storeKitPayment
        payment.simulatesAskToBuyInSandbox = configuration.simulatesAskToBuyInSandbox
        SKPaymentQueue.default().add(payment)
    }
    
    public func restoreInAppPurchases() {
        SKPaymentQueue.default().restoreCompletedTransactions()
    }
    
}


// MARK: - Transaction Observer
extension Payments: SKPaymentTransactionObserver {
    
    public func remove(_ transactionObserver: SKPaymentTransactionObserver) {
        SKPaymentQueue.default().remove(transactionObserver)
    }

    public func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        for transaction in transactions {
            switch transaction.transactionState {
            case .purchasing:
                break
                
            case .deferred:
                paymentWasDeferred(for: transaction)
                
            case .purchased:
                SKPaymentQueue.default().finishTransaction(transaction)
                didCompletePurchase(for: transaction)
                
            case .failed:
                SKPaymentQueue.default().finishTransaction(transaction)
                handle(transaction: transaction.error)
                
            case .restored:
                SKPaymentQueue.default().finishTransaction(transaction)
                didRestorePurchases(for: transaction)
                
            @unknown default: fatalError()
            }
        }
    }
    
    public func paymentQueue(_ queue: SKPaymentQueue, restoreCompletedTransactionsFailedWithError error: Error) {
        handle(transaction: error)
    }
    
    private func handle(transaction error: Error?) {
        guard let error = error as? SKError, error.code != .paymentCancelled else { return }
        paymentFailed(with: error)
    }
    
}


// MARK: - Observers
extension Payments {
    
    struct Observation {
        weak var observer: PaymentsObserving?
    }
    
    private var observers: [PaymentsObserving] {
        var observers: [PaymentsObserving] = []
        for (id, observation) in observations {
            guard let observer = observation.observer else {
                observations.removeValue(forKey: id)
                continue
            }
            observers.append(observer)
        }
        return observers
    }
    
    private func notifyObservers(_ event: @escaping (PaymentsObserving) -> Void) {
        DispatchQueue.main.async {
            self.observers.forEach { event($0) }
        }
    }
    
    private func didLoad(_ products: Set<Product>) {
        notifyObservers { $0.payments(self, didLoad: products) }
        Notification.LoadedProducts.notify(with: products)
    }
    
    private func cannotMakePayments() {
        notifyObservers { $0.userCannotMake(payments: self) }
        Notification.CannotMakePayments.notify()
    }
    
    private func didCompletePurchase(for transaction: SKPaymentTransaction) {
        notifyObservers { $0.didCompletePurchase(self) }
        Notification.Payment.Complete.notify(for: transaction.payment.productIdentifier)
    }
    
    private func didRestorePurchases(for transaction: SKPaymentTransaction) {
        notifyObservers { $0.didRestorePurchases(self) }
        Notification.Payment.Restored.notify(for: transaction.payment.productIdentifier)
    }
    
    private func paymentWasDeferred(for transaction: SKPaymentTransaction) {
        notifyObservers { $0.payments(self, paymentWasDeferred: .deferredAlert) }
        Notification.Payment.Deferred.notify()
    }
    
    private func paymentFailed(with error: SKError) {
        notifyObservers { $0.payments(self, didFailWithError: error.localizedDescription) }
        Notification.Payment.Failed.notify(for: error)
    }
    
}


// MARK: - Alerts
public extension Payments {
    
    struct Alert {
        let title: String?
        let message: String?
    }
    
}

extension Payments.Alert {
    
    static var deferredAlert: Payments.Alert {
        return .init(
            title: "Waiting For Approval",
            message: "Thank you! You can continue to use the app whilst your purchase is pending approval from your family organizer."
        )
    }
    
}
