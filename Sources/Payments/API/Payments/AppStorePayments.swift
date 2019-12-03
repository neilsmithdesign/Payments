//
//  AppStorePayments.swift
//  
//
//  Created by Neil Smith on 30/11/2019.
//

import StoreKit

public final class AppStorePayments: Payments {
    
    
    // MARK: Interface
    public init(configuration: AppStoreConfiguration, transactionObserver: SKPaymentTransactionObserver? = nil) {
        self.configuration = configuration
        self.receiptValidator = configuration.receiptValidator
        self.receiptLoader = configuration.receiptLoader
        let storeController = AppStoreController(
            productIdentifiers: configuration.productIdentifiers,
            transactionObserver: transactionObserver,
            simulatesAskToBuy: configuration.simulateAskToBuy
        )
        super.init(storeController: storeController)
    }
    
    
    public override func verifyPurchases() {
        guard let loader = receiptLoader else {
            return
        }
        loader.load(using: configuration.fileInspector) { [weak self] result in
            self?.handle(receiptLoading: result)
        }
    }
    
    private func handle(receiptLoading result: ReceiptLoadingResult) {
        switch result {
        case .success(let data):
            self.receiptData = data
            guard let validator = receiptValidator else {
                return
            }
            validator.validate(receipt: data) { [weak self] validationResult in
                self?.handle(validation: validationResult)
            }
        case .failure(let error):
            observer?.payments(self, didFailWith: .receiptError(.loading(error)))
        }
    }

    private func handle(validation result: ReceiptValidationResult) {
        switch result {
        case .success(let receipt):
            observer?.payments(self, didValidate: receipt)
        case .failure(let error):
            observer?.payments(self, didFailWith: .receiptError(.validation(error)))
        }
    }
    
    // MARK: Private
    private let configuration: AppStoreConfiguration
    private let receiptValidator: ReceiptValidating?
    private let receiptLoader: ReceiptLoading?
    private var receiptData: Data?
    
}
