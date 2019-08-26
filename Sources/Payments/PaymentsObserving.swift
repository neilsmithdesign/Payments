//
//  PaymentsObserving.swift
//  
//
//  Created by Neil Smith on 26/08/2019.
//

import Foundation

protocol PaymentsObserving: AnyObject {
    func payments(_ payments: Payments, didLoad products: Set<Product>)
    func payments(_ payments: Payments, didFailWithError message: String?)
    func payments(_ payments: Payments, paymentWasDeferred alert: Payments.Alert)
    func didRestorePurchases(_ payments: Payments)
    func didCompletePurchase(_ payments: Payments)
    func userCannotMake(payments: Payments)
}
