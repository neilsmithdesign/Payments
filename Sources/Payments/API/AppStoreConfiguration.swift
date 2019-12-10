//
//  AppStoreConfiguration.swift
//  
//
//  Created by Neil Smith on 29/11/2019.
//

import StoreKit

/// Use this type to configure an instance of AppStore.
public struct AppStoreConfiguration {
    
    /**
     Configuration for initializing an AppStore instance.
     - Parameters:
        - environment: Declare whether this is a production or development environment.
                    In development, this allows you to simulate ask to buy during testing.
        - receiptConfiguration: Determines how you intend to validate the App Store receipt.
                    Either locally on device, or remotely on your server.
        - productIdentifiers: Your product identifiers as configured in App Store Connect
        - transactionObserver: You can optionally set your own transaction observer to handle
                    call backs from StoreKit yourself. Alternatively, if you pass nil, your
                    instance of AppStore handle SKPaymentTransactionObserver methods.
    */
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
    init(environment: Environment,
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
    
    
    /// In a sandox/development environment, simulates the ask to buy purchase 
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
