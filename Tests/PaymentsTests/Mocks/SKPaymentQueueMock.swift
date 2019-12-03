//
//  File.swift
//  
//
//  Created by Neil Smith on 30/11/2019.
//

import StoreKit
@testable import Payments

class SKPaymentQueueMock: SKPaymentQueue {
    
    weak var observer: SKPaymentTransactionObserver?
    
    override func add(_ observer: SKPaymentTransactionObserver) {
        super.add(observer)
        self.observer = observer
    }
    
    override func remove(_ observer: SKPaymentTransactionObserver) {
        super.remove(observer)
        self.observer = nil
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
