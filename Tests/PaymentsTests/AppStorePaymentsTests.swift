//
//  AppStorePaymentsTests.swift
//  
//
//  Created by Neil Smith on 03/12/2019.
//

import XCTest
@testable import Payments

final class AppStorePaymentsTests: XCTestCase {
    
    let observer = PaymentsObserverSpy()
    
    func testReceiptIsValidated() {
        
        // Given
        let observer = PaymentsObserverSpy()
        let config = AppStoreConfiguration(
            environment: .sandbox(simulateAskToBuy: false),
            receiptValidator: ReceiptValidatorMock(),
            receiptLoader: ReceiptLoaderMock(),
            productIdentifiers: []
        )
        let payments = AppStore(configuration: config)
        payments.observer = observer

        XCTAssertFalse(observer.isReceiptValidated)
        
        // When
        payments.validateReceipt()
        
        // Then
        XCTAssertTrue(observer.isReceiptValidated)
        
    }
    
    func testDoesntLoadProductsFromInvalidIdentifiers() {
        
        // Given
        let identifiers: Set<ProductIdentifier> = ["com.NeilSmithDesignLTD.Payments.invalid.product"]
        let config = AppStoreConfiguration(
            environment: .sandbox(simulateAskToBuy: false),
            productIdentifiers: identifiers
        )
        let request = FakeProductsRequest(productIdentifiers: identifiers)
        let payments = AppStore(
            configuration: config,
            productsRequest: request
        )
        
        // When
        payments.loadProducts()
        
        // Then
        XCTAssert(payments.availableProducts.count == 0)
        
    }
    
}


private extension AppStore {
    
    convenience init(configuration: AppStoreConfiguration, productsRequest: ProductsRequest) {
        let controller = AppStoreController(
            productIdentifiers: configuration.productIdentifiers,
            transactionObserver: configuration.transactionObserver,
            productsRequest: productsRequest,
            simulatesAskToBuy: configuration.simulateAskToBuy
        )
        self.init(controller: controller, configuration: configuration)
    }
    
}
