//
//  StoreKitController.swift
//  
//
//  Created by Neil Smith on 29/11/2019.
//

import StoreKit

final class StoreKitController: NSObject, StoreControlling, SKProductsRequestDelegate {
    
    
    // MARK: Init
    init(productIdentifiers: Set<ProductIdentifier>, transactionObserver: SKPaymentTransactionObserver? = nil, paymentQueue: PaymentQueue = SKPaymentQueue.default()) {
        self.productIdentifiers = productIdentifiers
        self.paymentQueue = paymentQueue
        super.init()
        guard paymentQueue.canMakePayments else { return }
        if let observer = transactionObserver {
            paymentQueue.add(observer)
        } else {
            paymentQueue.add(self)
        }
    }
    
    var productIdentifiers: Set<ProductIdentifier>
    
    
    // MARK: Private
    private let paymentQueue: PaymentQueue
    
    private lazy var productsRequest: SKProductsRequest = {
        let req = SKProductsRequest(productIdentifiers: productIdentifiers)
        req.delegate = self
        return req
    }()
    
    private var loadProductRequests: ((LoadedProductsResult) -> Void)?
    private var paymentRequest: ((PaymentResult) -> Void)?
    
}


// MARK: - Observations
extension StoreKitController {
    
    func add(transactionObserver: SKPaymentTransactionObserver) {
        paymentQueue.add(transactionObserver)
    }
    
    func remove(transactionObserver: SKPaymentTransactionObserver) {
        paymentQueue.remove(transactionObserver)
    }
    
    var canMakePayments: Bool {
        return SKPaymentQueue.canMakePayments()
    }
    
}


// MARK: - Load products
extension StoreKitController {

    
    func loadProducts(_ completion: @escaping (LoadedProductsResult) -> Void) {
        self.loadProductRequests = completion
        productsRequest.start()
    }
    
    func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        let products = Set(response.products.map { Product(storeKit: $0) })
        self.loadProductRequests?(.success(products))
        self.loadProductRequests = nil
    }
    
    func request(_ request: SKRequest, didFailWithError error: Error) {
        self.loadProductRequests?(.failure(error))
        self.loadProductRequests = nil
    }
    
}


// MARK: - Purchases
extension StoreKitController: SKPaymentTransactionObserver {
    
    func purchase(product: Product, simulateAskToBuy: Bool, completion: @escaping (PaymentResult) -> Void) {
        if canMakePayments {
            let payment = product.storeKitPayment
            payment.simulatesAskToBuyInSandbox = simulateAskToBuy
            paymentQueue.add(payment)
            self.paymentRequest = completion
        } else {
            completion(.failure(PaymentsError.paymentFailed(SKError(.paymentNotAllowed))))
        }
    }
    
    func restorePurchases(_ completion: @escaping (PaymentResult) -> Void) {
        self.paymentRequest = completion
        paymentQueue.restoreCompletedTransactions()
    }
    
    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        for transaction in transactions {
            let id = transaction.payment.productIdentifier
            switch transaction.transactionState {
            
            case .purchasing:
                break
            
            case .deferred:
                paymentRequest?(.deferred(id))
            
            case .purchased:
                SKPaymentQueue.default().finishTransaction(transaction)
                paymentRequest?(.success(id))
                
            case .failed:
                SKPaymentQueue.default().finishTransaction(transaction)
                handle(paymentRequest: transaction.error)
                
            case .restored:
                SKPaymentQueue.default().finishTransaction(transaction)
                paymentRequest?(.restored(id))
                
            @unknown default: fatalError()
            }
        }
        paymentRequest = nil
    }
    
    public func paymentQueue(_ queue: SKPaymentQueue, restoreCompletedTransactionsFailedWithError error: Error) {
        handle(paymentRequest: error)
        paymentRequest = nil
    }
    

    private func handle(paymentRequest error: Error?) {
        guard let error = error as? SKError, error.code != .paymentCancelled else { return }
        paymentRequest?(.failure(error))
    }
    
}


