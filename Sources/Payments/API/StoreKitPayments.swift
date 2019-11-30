//
//  File.swift
//  
//
//  Created by Neil Smith on 30/11/2019.
//

import StoreKit

public final class StoreKitPayments: Payments {
    
    public init(configuration: StoreKitConfiguration, transactionObserver: SKPaymentTransactionObserver? = nil) {
        let storeController = StoreKitController(
            productIdentifiers: configuration.productIdentifiers,
            transactionObserver: transactionObserver
        )
        super.init(
            configuration: configuration,
            storeController: storeController
        )
    }
    
}
