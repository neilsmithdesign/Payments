//
//  PaymentsObserving.swift
//  
//
//  Created by Neil Smith on 26/08/2019.
//

import Foundation

public protocol PaymentsObserving: AnyObject {
    func payments(_ payments: PaymentsProcessing, didValidate receipt: AppStoreReceipt)
    func payments(_ payments: PaymentsProcessing, didLoad products: Set<Product>)
    func payments(_ payments: PaymentsProcessing, didFailWith error: PaymentsError)
    func payments(_ payments: PaymentsProcessing, paymentWasDeferred alert: PaymentDeferredAlert)
    func payments(_ payments: PaymentsProcessing, didRestorePurchaseForProductWith identifier: ProductIdentifier)
    func payments(_ payments: PaymentsProcessing, didCompletePurchaseForProductWith identifier: ProductIdentifier)
    func userCannotMake(payments: PaymentsProcessing)
}
