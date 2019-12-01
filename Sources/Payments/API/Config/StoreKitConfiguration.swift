//
//  StoreKitConfiguration.swift
//  
//
//  Created by Neil Smith on 29/11/2019.
//

import StoreKit

public struct StoreKitConfiguration: PaymentsConfiguring {
        
    public init(environment: Payments.Environment,
                bundle: Bundle,
                receiptValidation: ReceiptValidationStrategy,
                productIdentifiers: Set<ProductIdentifier>,
                transactionObserver: SKPaymentTransactionObserver? = nil) {
        self.environment = environment
        self.bundle = bundle
        self.receiptValidation = receiptValidation
        self.productIdentifiers = productIdentifiers
        self.transactionObserver = transactionObserver
    }
    
    
    /// Determines which App Store to request payments to and from
    public var environment: Payments.Environment
    
    
    /// The bundle used to access relevant files such as the app store receipt
    /// and Apple root certificate if using local receipt validation
    public var bundle: Bundle
    
    
    /// The product identifiers for in-app purchases which your app offers
    public var productIdentifiers: Set<ProductIdentifier>
    
    
    public var simulateAskToBuy: Bool {
        switch environment {
        case .production: return false
        case .sandbox(simulateAskToBuy: let simulate): return simulate
        }
    }
    
    
    let receiptValidation: ReceiptValidationStrategy
    
    
    /// An optional transaction observer. The user of this library has the option
    /// of assigning one of their own classes as the transaction observer.
    /// If this value is nil, the 'Payments' class sets itself as the observer.
    let transactionObserver: SKPaymentTransactionObserver?

    
}

