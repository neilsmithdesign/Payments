//
//  PaymentsConfiguration.swift
//  
//
//  Created by Neil Smith on 26/08/2019.
//

import StoreKit

public protocol PaymentsConfiguring {
    var environment: Payments.Environment { get }
    var productIdentifiers: Set<ProductIdentifier> { get }
    var simulateAskToBuy: Bool { get }
}


public extension Payments {
    
    struct StoreKitConfiguration: PaymentsConfiguring {
        
        public init(environment: Payments.Environment, productIdentifiers: Set<ProductIdentifier>, transactionObserver: SKPaymentTransactionObserver? = nil) {
            self.environment = environment
            self.productIdentifiers = productIdentifiers
            self.transactionObserver = transactionObserver
        }
        
        
        /// Determines which App Store to request payments to and from
        public var environment: Payments.Environment
        
        
        /// The product identifiers for in-app purchases which your app offers
        public var productIdentifiers: Set<ProductIdentifier>
        
        
        /// An optional transaction observer. The user of this library has the option
        /// of assigning one of their own classes as the transaction observer.
        /// If this value is nil, the 'Payments' class sets itself as the observer.
        let transactionObserver: SKPaymentTransactionObserver?

        
        public var simulateAskToBuy: Bool {
            switch environment {
            case .production: return false
            case .sandbox(simulateAskToBuy: let simulate): return simulate
            }
        }
    }
    
}

public extension Payments {
        
    enum Environment {
        case sandbox(simulateAskToBuy: Bool)
        case production
    }
    
}
