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
    
    func payments(_ payments: PaymentsProcessing, didValidate receipt: AppStoreReceipt) {
        isReceiptValidated = true
    }
    
    func payments(_ payments: PaymentsProcessing, didLoad products: Set<Product>) {
        DispatchQueue.main.async {
            self.didLoadProducts = true            
        }
    }
    
    func payments(_ payments: PaymentsProcessing, didFailWith error: PaymentsError) {}
    func payments(_ payments: PaymentsProcessing, paymentWasDeferred alert: PaymentDeferredAlert) {}
    func didRestorePurchases(_ payments: PaymentsProcessing) {}
    func didCompletePurchase(_ payments: PaymentsProcessing) {}
    func userCannotMake(payments: PaymentsProcessing) {}
    
}
