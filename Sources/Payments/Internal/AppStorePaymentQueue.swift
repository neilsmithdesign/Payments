//
//  AppStorePaymentQueue.swift
//  
//
//  Created by Neil Smith on 30/11/2019.
//

import StoreKit

protocol AppStorePaymentQueue: AnyObject {
    var canMakePayments: Bool { get }
    func add(_ observer: SKPaymentTransactionObserver)
    func remove(_ observer: SKPaymentTransactionObserver)
    func add(_ payment: SKPayment)
    func restoreCompletedTransactions()
}

extension AppStorePaymentQueue where Self: SKPaymentQueue {
    var canMakePayments: Bool {
        return Self.canMakePayments()
    }
}

extension SKPaymentQueue: AppStorePaymentQueue {}
