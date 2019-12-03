//
//  LocalReceiptValidatorMock.swift
//  
//
//  Created by Neil Smith on 02/12/2019.
//

import Foundation
@testable import Payments

struct LocalReceiptValidatorMock: ReceiptValidatingLocally {
    
    init(_ input: LocalReceiptValidationInput = .mock) {}
    
    func validate(receipt data: Data) -> ReceiptValidationResult {
        return .success(.mockReceipt)
    }
    
}

private extension LocalReceiptValidationInput {
    
    static var mock: LocalReceiptValidationInput {
        return .init(rootCertificateName: "", bundle: .main)
    }
    
}

private extension AppStoreReceipt {
    
    static var mockReceipt: AppStoreReceipt {
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
