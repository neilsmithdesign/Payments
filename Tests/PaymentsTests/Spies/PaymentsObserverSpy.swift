//
//  PaymentsObserverSpy.swift
//  
//
//  Created by Neil Smith on 03/12/2019.
//

import Foundation
@testable import Payments

final class PaymentsObserverSpy: PaymentsObserving {
    
    init() {}
    
    var isReceiptValidated: Bool = false
    var didLoadProducts: Bool = false
    
    func payments(_ payments: Payments, didValidate receipt: AppStoreReceipt) {
        isReceiptValidated = true
    }
    
    func payments(_ payments: Payments, didLoad products: Set<Product>) {
        DispatchQueue.main.async {
            self.didLoadProducts = true            
        }
    }
    
    func payments(_ payments: Payments, didFailWith error: PaymentsError) {}
    func payments(_ payments: Payments, paymentWasDeferred alert: Payments.DeferredAlert) {}
    func didRestorePurchases(_ payments: Payments) {}
    func didCompletePurchase(_ payments: Payments) {}
    func userCannotMake(payments: Payments) {}
    
}
