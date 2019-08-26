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
    public weak var observer: PaymentsObserving?
    
    public init(configuration: Payments.Configuration, transactionObserver: SKPaymentTransactionObserver? = nil) {
        self.configuration = configuration
        super.init()
        if let observer = transactionObserver {
            SKPaymentQueue.default().add(observer)
        } else {
            SKPaymentQueue.default().add(self)
        }
    }
    
    public private (set) var availableProducts: Set<Product> = []

    
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
    
    static var canMakePayments: Bool {
        return SKPaymentQueue.canMakePayments()
    }
    
}


// MARK: - Product Request
extension Payments: SKProductsRequestDelegate {
    
    public func loadProducts() {
        productsRequest.start()
    }
    
    public func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        availableProducts = Set(response.products.map { Product(storeKit: $0) })
        DispatchQueue.main.async {
            self.observer?.payments(self, didLoad: self.availableProducts)
        }
    }
    
}


// MARK: - Purchases
extension Payments {

    
    public func makeInAppPurchase(for product: Product) {
        guard Payments.canMakePayments else {
            DispatchQueue.main.async { self.observer?.userCannotMake(payments: self) }
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
            case .purchasing: break
            case .deferred: handle(deferred: transaction)
            case .purchased: handle(purchased: transaction)
            case .failed: handle(failed: transaction)
            case .restored: handle(restored: transaction)
            @unknown default: fatalError()
            }
        }
    }
    
    public func paymentQueue(_ queue: SKPaymentQueue, restoreCompletedTransactionsFailedWithError error: Error) {
        handle(transaction: error)
    }

    
    // MARK: Helpers
    private func handle(purchased transaction: SKPaymentTransaction) {
        SKPaymentQueue.default().finishTransaction(transaction)
        DispatchQueue.main.async { self.observer?.didCompletePurchase(self) }
    }

    private func handle(restored transaction: SKPaymentTransaction) {
        SKPaymentQueue.default().finishTransaction(transaction)
        DispatchQueue.main.async { self.observer?.didRestorePurchases(self) }
    }
    
    private func handle(failed transaction: SKPaymentTransaction) {
        SKPaymentQueue.default().finishTransaction(transaction)
        handle(transaction: transaction.error)
    }
    
    private func handle(deferred transaction: SKPaymentTransaction) {
        DispatchQueue.main.async { self.observer?.payments(self, paymentWasDeferred: .deferredAlert) }
    }
    
    private func handle(transaction error: Error?) {
        if let err = error as? SKError, err.code != .paymentCancelled {
            DispatchQueue.main.async { self.observer?.payments(self, didFailWithError: err.localizedDescription) }
        }
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
