//
//  File.swift
//  
//
//  Created by Neil Smith on 30/11/2019.
//

import StoreKit

public final class StoreKitPayments: Payments {
    
    
    // MARK: Interface
    public init(configuration: StoreKitConfiguration, transactionObserver: SKPaymentTransactionObserver? = nil) {
        self.configuration = configuration
        let storeController = StoreKitController(
            productIdentifiers: configuration.productIdentifiers,
            transactionObserver: transactionObserver
        )
        super.init(
            configuration: configuration,
            storeController: storeController
        )
    }
    
    
    public override func verifyPurchases() {
        receiptLoader.load { [weak self] result in
            self?.handle(receiptLoading: result)
        }
    }
    
    private func handle(receiptLoading result: ReceiptLoadingResult) {
        switch result {
        case .success(let data):
            self.receiptData = data
            #warning("TO DO: Parse and inspect receipt data")
        case .failure(let error):
            print(error.localizedDescription)
            fatalError()
            #warning("TO DO: Handle receipt loading errors")
        }
    }


    // MARK: Private
    private let configuration: StoreKitConfiguration
    
    private lazy var receiptLoader: AppStoreReceiptLoader = .init(location: configuration.bundle)
    private var receiptData: Data?
    
}
