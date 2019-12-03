//
//  AppStoreConfiguration.swift
//  
//
//  Created by Neil Smith on 29/11/2019.
//

import StoreKit

public struct AppStoreConfiguration {
    
    public init(environment: Environment,
                receiptConfiguration: ReceiptValidationConfiguration,
                fileInspector: FileInspector = FileManager.default,
                productIdentifiers: Set<ProductIdentifier>,
                transactionObserver: SKPaymentTransactionObserver? = nil) {
        self.init(
            environment: environment,
            receiptValidator: receiptConfiguration.validator,
            receiptLoader: receiptConfiguration.loader,
            fileInspector: fileInspector,
            productIdentifiers: productIdentifiers,
            transactionObserver: transactionObserver
        )
    }

    /// Private initializer utilized to provide mocking ability
    public init(environment: Environment,
                receiptValidator: ReceiptValidating? = nil,
                receiptLoader: ReceiptLoading? = nil,
                fileInspector: FileInspector = FileManager.default,
                productIdentifiers: Set<ProductIdentifier>,
                transactionObserver: SKPaymentTransactionObserver? = nil) {
        self.environment = environment
        self.productIdentifiers = productIdentifiers
        self.receiptValidator = receiptValidator
        self.receiptLoader = receiptLoader
        self.fileInspector = fileInspector
        self.transactionObserver = transactionObserver
    }
    
    
    /// Determines which App Store to request payments to and from
    public var environment: Environment

    
    /// The product identifiers for in-app purchases which your app offers
    public var productIdentifiers: Set<ProductIdentifier>
    
    
    public var simulateAskToBuy: Bool {
        switch environment {
        case .production: return false
        case .sandbox(simulateAskToBuy: let simulate): return simulate
        }
    }
    
    
    /// Performs validation of the App Store receipt.
    /// Assigning nil means the receipt won't be loaded or validated
    let receiptValidator: ReceiptValidating?
    
    
    /// Loads the App Store receipt from the appropriate location.
    /// Assigning nil means the receipt won't be loaded or validated
    let receiptLoader: ReceiptLoading?
    
    
    /// Performs a t check on the existence of a file for a given URL
    /// Primarily used to check if a file exists at the App Store receipt url
    /// Protocol interface provides an easy way to perform tests.
    let fileInspector: FileInspector
    
    
    /// An optional transaction observer. The user of this library has the option
    /// of assigning one of their own classes as the transaction observer.
    /// If this value is nil, the 'Payments' class sets itself as the observer.
    let transactionObserver: SKPaymentTransactionObserver?

    
}

public extension AppStoreConfiguration {
    
    enum Environment {
        case sandbox(simulateAskToBuy: Bool)
        case production
    }
    
}
