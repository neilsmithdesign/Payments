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
    public init(configuration: Payments.Configuration) {
        self.configuration = configuration
        super.init()
        if let observer = configuration.transactionObserver {
            SKPaymentQueue.default().add(observer)
        } else {
            SKPaymentQueue.default().add(self)
        }
    }
    
    public weak var observer: PaymentsObserving?

    
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
    
    public func request(_ request: SKRequest, didFailWithError error: Error) {
        
        print("SKRequest failed with error: \(error.localizedDescription)")
    }
    
}


public enum PaymentsError: Error {
    case productLoadRequestFailed(message: String)
}


// MARK: - Purchases
extension Payments {

    
    public func makeInAppPurchase(for product: Product) {
        guard Payments.canMakePayments else {
            cannotMakePayments()
            return
        }
        let payment = product.storeKitPayment
        payment.simulatesAskToBuyInSandbox = configuration.simulateAskToBuy
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


// MARK: - Observer calls
extension Payments {
    
    private func didLoad(_ products: Set<Product>) {
        observer?.payments(self, didLoad: products)
        PaymentsNotification.LoadedProducts.Succeeded.notify(with: products)
    }
    
    private func failedToLoadProducts(with error: Error) {
        let productLoadError = PaymentsError.productLoadRequestFailed(message: error.localizedDescription)
        observer?.payments(self, didFailToLoadProductsWith: productLoadError)
        PaymentsNotification.LoadedProducts.Failed.notify(with: productLoadError)
    }
    
    private func cannotMakePayments() {
        observer?.userCannotMake(payments: self)
        PaymentsNotification.CannotMakePayments.notify(with: nil)
    }
    
    private func didCompletePurchase(for transaction: SKPaymentTransaction) {
        observer?.didCompletePurchase(self)
        PaymentsNotification.Payment.Complete.notify(with: transaction.payment.productIdentifier)
    }
    
    private func didRestorePurchases(for transaction: SKPaymentTransaction) {
        observer?.didRestorePurchases(self)
        PaymentsNotification.Payment.Restored.notify(with: transaction.payment.productIdentifier)
    }
    
    private func paymentWasDeferred(for transaction: SKPaymentTransaction) {
        observer?.payments(self, paymentWasDeferred: .deferredAlert)
        let alert = DeferredAlert.standardMessage(for: transaction.payment.productIdentifier)
        PaymentsNotification.Payment.Deferred.notify(with: alert)
    }
    
    private func paymentFailed(with error: SKError) {
        observer?.payments(self, didFailWithError: error.localizedDescription)
        PaymentsNotification.Payment.Failed.notify(with: error)
    }
    
}


// MARK: - Alerts
public extension Payments {
    
    struct Alert {
        public let title: String?
        public let message: String?
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
