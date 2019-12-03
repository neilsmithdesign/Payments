//
//  TransactionObserverSpy.swift
//  
//
//  Created by Neil Smith on 03/12/2019.
//

import StoreKit
@testable import Payments

final class TransactionObserverSpy: NSObject, SKPaymentTransactionObserver {
    
    var didPurchase: Bool = false
    var didRestore: Bool = false
    
    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        for t in transactions {
            switch t.transactionState {
            case .purchased: self.didPurchase = true
            case .restored: self.didRestore = true
            default: fatalError()
            }
        }
    }
    
    
}
