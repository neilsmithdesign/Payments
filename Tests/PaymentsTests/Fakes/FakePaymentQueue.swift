//
//  File.swift
//  
//
//  Created by Neil Smith on 30/11/2019.
//

import StoreKit
@testable import Payments

class FakePaymentQueue: SKPaymentQueue {
    
    weak var observer: SKPaymentTransactionObserver?
    
    init(productIdentifiers: Set<ProductIdentifier> = []) {
        self.productIdentifiers = productIdentifiers
    }
    
    private let productIdentifiers: Set<ProductIdentifier>
    
    override func add(_ observer: SKPaymentTransactionObserver) {
        super.add(observer)
        self.observer = observer
    }
    
    override func remove(_ observer: SKPaymentTransactionObserver) {
        super.remove(observer)
        self.observer = nil
    }
    
    override func add(_ payment: SKPayment) {
        assert(productIdentifiers.contains(payment.productIdentifier))
        observer?.paymentQueue(self, updatedTransactions: [FakePaymentTransaction(fakePayment: payment, fakeState: .purchased)])
    }
    
    override func restoreCompletedTransactions() {
        assert(!productIdentifiers.isEmpty)
        let id = productIdentifiers.first!
        let product = FakeProduct(fakeIdentifier: id)
        let payment = SKPayment(product: product)
        observer?.paymentQueue(self, updatedTransactions: [FakePaymentTransaction(fakePayment: payment, fakeState: .restored)])
    }
    
}

final class FakePaymentTransaction: SKPaymentTransaction {
    
    private let fakePayment: SKPayment
    private let fakeState: SKPaymentTransactionState
    
    init(fakePayment: SKPayment, fakeState: SKPaymentTransactionState) {
        self.fakePayment = fakePayment
        self.fakeState = fakeState
    }
    
    override var payment: SKPayment {
        return fakePayment
    }
    
    override var transactionState: SKPaymentTransactionState {
        return fakeState
    }
    
}

final class SKPaymentQueueCannotMakePaymentsMock: AppStorePaymentQueue {
    
    weak var observer: SKPaymentTransactionObserver?
    
    var canMakePayments: Bool {
        return false
    }

    func add(_ observer: SKPaymentTransactionObserver) {
        self.observer = observer
    }
    
    func remove(_ observer: SKPaymentTransactionObserver) {
        self.observer = nil
    }
    
    func add(_ payment: SKPayment) {
        
    }
    
    func restoreCompletedTransactions() {
        
    }
    
}
