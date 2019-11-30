//
//  PaymentQueue.swift
//  
//
//  Created by Neil Smith on 30/11/2019.
//

import StoreKit

protocol PaymentQueue: AnyObject {
    var canMakePayments: Bool { get }
    func add(_ observer: SKPaymentTransactionObserver)
    func remove(_ observer: SKPaymentTransactionObserver)
    func add(_ payment: SKPayment)
    func restoreCompletedTransactions()
}

extension PaymentQueue where Self: SKPaymentQueue {
    
    var canMakePayments: Bool {
        return Self.canMakePayments()
    }
    
}


extension SKPaymentQueue: PaymentQueue {}
