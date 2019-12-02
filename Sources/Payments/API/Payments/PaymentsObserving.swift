//
//  PaymentsObserving.swift
//  
//
//  Created by Neil Smith on 26/08/2019.
//

import Foundation

public protocol PaymentsObserving: AnyObject {
    func payments(_ payments: Payments, didValidate receipt: AppStoreReceipt)
    func payments(_ payments: Payments, didLoad products: Set<Product>)
    func payments(_ payments: Payments, didFailWith error: PaymentsError)
    func payments(_ payments: Payments, paymentWasDeferred alert: Payments.DeferredAlert)
    func didRestorePurchases(_ payments: Payments)
    func didCompletePurchase(_ payments: Payments)
    func userCannotMake(payments: Payments)
}
