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
            id: InAppPurchaseReceipt.IDs(product: "fake.product.id",
                      transaction: "fake.transaction.id",
                      originalTransaction: "fake.original.transaction.id",
                      webOrderLineItem: nil,
                      appItem: nil,
                      externalVersion: nil
            ),
            purchaseDate: Date(),
            originalPurchaseDate: Date(),
            subscription: nil
        )
        return .init(
            bundleID: .init(name: "fake.bundle.id", data: nil),
            appVersion: .init(current: "2.3.5", original: "1.8.4"),
            hash: nil,
            date: nil,
            inAppPurchaseReceipts: [iap]
        )
        
    }
    
}
