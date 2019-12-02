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
            receiptValidator.validate(receipt: data) { [weak self] validationResult in
                self?.handle(validation: validationResult)
            }
        case .failure(let error):
            print(error.localizedDescription)
            fatalError()
            #warning("TO DO: Handle receipt loading errors")
        }
    }

    private func handle(validation result: ReceiptValidationResult) {
        switch result {
        case .success(let receipt):
            observer?.payments(self, didValidate: receipt)
        case .failure(let error):
            print(error.localizedDescription)
            fatalError()
        }
    }
    
    // MARK: Private
    private let configuration: StoreKitConfiguration
    
    private lazy var receiptLoader: AppStoreReceiptLoader = .init(location: configuration.bundle)
    private lazy var receiptValidator: ReceiptValidating = TestReceiptValidator(.local)
    private var receiptData: Data?
    
}

private struct TestReceiptValidator: ReceiptValidating {
    
    init(_ strategy: ReceiptValidationStrategy, localValidator: ReceiptValidatingLocally? = nil, remoteValidator: ReceiptValidatingRemotely? = nil) {}
    
    func validate(receipt data: Data, completion: @escaping (ReceiptValidationResult) -> Void) {
        completion(.success(.testReceipt))
    }
    
}

private extension AppStoreReceipt {
    
    static var testReceipt: AppStoreReceipt {
        let iap = InAppPurchaseReceipt(
            quantity: 1,
            id: .init(product: "fake.product.id",
                      transaction: "fake.transaction.id",
                      originalTransaction: "fake.original.transaction.id",
                      webOrderLineItem: nil
            ),
            date: .init(
                purchase: Date(),
                originalPurchase: Date(),
                subscriptionExpiration: nil,
                cancellation: nil
            )
        )
        return .init(bundleID: .init(name: "fake.bundle.id", data: Data()),
                     appVersion: .init(current: "2.0.0", original: "1.0.0"),
                     hash: .init(sha1: Data(), opaqueValue: Data()),
                     date: .init(receiptCreation: Date(), expiration: nil),
                     inAppPurchaseReceipts: [iap]
        )
        
    }
    
}
