//
//  AppStoreController.swift
//  
//
//  Created by Neil Smith on 29/11/2019.
//

import StoreKit

final class AppStoreController: NSObject, StoreControlling, SKProductsRequestDelegate {
    
    
    // MARK: Init
    init(productIdentifiers: Set<ProductIdentifier>,
        transactionObserver: SKPaymentTransactionObserver? = nil,
        paymentQueue: AppStorePaymentQueue = SKPaymentQueue.default(),
        productsRequest: ProductsRequest? = nil,
        simulatesAskToBuy: Bool = false
    ) {
        self.productIdentifiers = productIdentifiers
        self.paymentQueue = paymentQueue
        self.simulatesAskToBuy = simulatesAskToBuy
        self.productsRequest = productsRequest ?? SKProductsRequest(productIdentifiers: productIdentifiers)
        super.init()
        self.productsRequest.delegate = self
        if let observer = transactionObserver {
            paymentQueue.add(observer)
        } else {
            paymentQueue.add(self)
        }
    }
    
    var productIdentifiers: Set<ProductIdentifier>
    
    
    // MARK: Private
    private let paymentQueue: AppStorePaymentQueue
    private let simulatesAskToBuy: Bool
    private var productsRequest: ProductsRequest
    
    private var loadProductRequests: ((LoadedProductsResult) -> Void)?
    private var paymentRequest: ((PaymentResult) -> Void)?
    
}


// MARK: - Observations
extension AppStoreController {
    
    func add(transactionObserver: SKPaymentTransactionObserver) {
        paymentQueue.add(transactionObserver)
    }
    
    func remove(transactionObserver: SKPaymentTransactionObserver) {
        paymentQueue.remove(transactionObserver)
    }
    
    var canMakePayments: Bool {
        return paymentQueue.canMakePayments
    }
    
}


// MARK: - Load products
extension AppStoreController {
    
    func loadProducts(_ completion: @escaping (LoadedProductsResult) -> Void) {
        self.loadProductRequests = completion
        productsRequest.start()
    }
    
    func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        let products = Set(response.products.map { AppStoreProduct(storeKit: $0) })
        let result: LoadedProductsResult
        if products.count == 0 {
            result = .failure(PaymentsError.noProductsMatchingIdentifiers)
        } else {
            result = .success(products)
        }
        self.loadProductRequests?(result)
        self.loadProductRequests = nil
    }
    
    func request(_ request: SKRequest, didFailWithError error: Error) {
        guard request is SKProductsRequest else { return }
        self.loadProductRequests?(.failure(.productLoadRequestFailed(message: error.localizedDescription)))
        self.loadProductRequests = nil
    }
    
}


// MARK: - Purchases
extension AppStoreController: SKPaymentTransactionObserver {
   
    
    // Make purchase
    func purchase(_ product: Product, completion: @escaping (PaymentResult) -> Void) {
        guard let appStoreProduct = product as? AppStoreProduct else {
            preconditionFailure("Non-App Store product requested for purcahse. Programmer error.")
        }
        guard self.productIdentifiers.contains(appStoreProduct.identifier) else {
            completion(.failure(PaymentsError.paymentFailed(SKError(.storeProductNotAvailable))))
            return
        }
        if canMakePayments {
            let payment = appStoreProduct.storeKitPayment
            payment.simulatesAskToBuyInSandbox = simulatesAskToBuy
            self.paymentRequest = completion
            paymentQueue.add(payment)
        } else {
            completion(.failure(PaymentsError.paymentFailed(SKError(.paymentNotAllowed))))
        }
    }
    
    
    // Restores any existing purchases
    func restorePurchases(_ completion: @escaping (PaymentResult) -> Void) {
        self.paymentRequest = completion
        paymentQueue.restoreCompletedTransactions()
    }
    
    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        for transaction in transactions {
            notify(for: transaction)
            switch transaction.transactionState {
            case .purchased, .failed, .restored: SKPaymentQueue.default().finishTransaction(transaction)
            default: break
            }
        }
    }
    
    private func notify(for transaction: SKPaymentTransaction) {
        PaymentEvent.notify(for: transaction)
        let id = transaction.payment.productIdentifier
        switch transaction.transactionState {
        case .failed: handle(paymentRequest: transaction.error)
        case .deferred: paymentRequest?(.deferred(id))
        case .purchased: paymentRequest?(.success(id))
        case .restored: paymentRequest?(.restored(id))
        case .purchasing: break
        @unknown default: fatalError()
        }
    }
    
    func paymentQueue(_ queue: SKPaymentQueue, restoreCompletedTransactionsFailedWithError error: Error) {
        handle(paymentRequest: error)
    }    

    private func handle(paymentRequest error: Error?) {
        guard let error = error as? SKError, error.code != .paymentCancelled else { return }
        paymentRequest?(.failure(.paymentFailed(error)))
    }
    
}


