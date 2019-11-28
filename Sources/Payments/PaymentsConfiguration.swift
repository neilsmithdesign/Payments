//
//  PaymentsConfiguration.swift
//  
//
//  Created by Neil Smith on 26/08/2019.
//

import StoreKit

public extension Payments {
    
    struct Configuration {
        
        /// Determines which App Store to request payments to and from
        let mode: Mode
        
        /// The product identifiers for in-app purchases which your app offers
        let productIdentifiers: Set<String>
        
        /// An optional transaction observer. The user of this library has the option
        /// of assigning one of their own classes as the transaction observer.
        /// If this value is nil, the 'Payments' class sets itself as the observer.
        let transactionObserver: SKPaymentTransactionObserver?
        
        var simulateAskToBuy: Bool {
            switch mode {
            case .production: return false
            case .sandbox(simulateAskToBuy: let simulate): return simulate
            }
        }
        
        public init(mode: Mode, productIdentifiers: Set<String>, transactionObserver: SKPaymentTransactionObserver? = nil) {
            self.mode = mode
            self.productIdentifiers = productIdentifiers
            self.transactionObserver = transactionObserver
        }
        
        public enum Mode {
            case sandbox(simulateAskToBuy: Bool)
            case production
        }
    }
    
}

