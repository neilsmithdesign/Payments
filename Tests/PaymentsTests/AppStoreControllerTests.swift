//
//  AppStoreControllerTests.swift
//  
//
//  Created by Neil Smith on 30/11/2019.
//

import XCTest
import StoreKit
@testable import Payments

final class AppStoreControllerTests: XCTestCase {
    
    var controller: AppStoreController!
    let validIdentifiers: Set<ProductIdentifier> = ["com.NeilSmithDesignLTD.Payments.fake.product"]
    let validRequest = FakeProductsRequest(productIdentifiers: ["com.NeilSmithDesignLTD.Payments.fake.product"])
    let invalidIdentifiers: Set<ProductIdentifier> = ["com.NeilSmithDesignLTD.Payments.invalid.product"]
    let invalidRequest = FakeProductsRequest(productIdentifiers: ["com.NeilSmithDesignLTD.Payments.invalid.product"])
    let observer = TransactionObserverSpy()
    
    
    func testTransactionObserverExistsWhenNotSupplied() {
        
        // Given
        let queue = FakePaymentQueue()
        
        // When
        controller = AppStoreController(productIdentifiers: [], transactionObserver: nil, paymentQueue: queue)
        
        // Then
        XCTAssertNotNil(queue.observer)
        
    }
    
    
    func testTransactionObserverExistsWhenSupplied() {
        
        // Given
        let queue = FakePaymentQueue()
        
        // When
        controller = AppStoreController(productIdentifiers: [], transactionObserver: observer, paymentQueue: queue)
        
        // Then
        XCTAssertNotNil(queue.observer)
        
    }

    
    /// FakeProductsRequest ensures the completion handler of AppStoreController.loadProducts is called immediately
    func testSuccessCalledWhenLoadingFromValidProductIdentifiers() {
        
        // Given
        controller = AppStoreController(productIdentifiers: validIdentifiers, productsRequest: validRequest)
    
        // When
        controller.loadProducts { result in

            // Then
            switch result {
            case .failure:
                XCTFail()
            case .success(let products):
                XCTAssert(products.count == self.validIdentifiers.count)
            }
        }
        
    }
    
    
    /// FakeProductsRequest ensures the completion handler of AppStoreController.loadProducts is called immediately
    func testFailureCalledWhenLoadingFromInvalidProductIdentifiers() {
        
        // Given
        controller = AppStoreController(productIdentifiers: invalidIdentifiers, productsRequest: invalidRequest)
    
        // When
        controller.loadProducts { result in

            // Then
            let expectedError: PaymentsError = .noProductsMatchingIdentifiers
            
            switch result {
            case .failure(let error):
                XCTAssert(error == expectedError)
            case .success:
                XCTFail()
            }
        }
        
    }
    
    
    /// FakePaymentQueue ensures the completion handler of AppStoreController.purchase is called immediately
    func testPurchaseOfValidProductSucceeds() {
        
        // Given
        let product = AppStoreProduct(storeKit: FakeProduct())
        let queue = FakePaymentQueue(productIdentifiers: validIdentifiers)
        
        controller = AppStoreController(
            productIdentifiers: validIdentifiers,
            transactionObserver: observer,
            paymentQueue: queue
        )
        
        // When
        controller.purchase(product) { result in
            
            // Then
            switch result {
            case .success(let id):
                XCTAssert(self.observer.didPurchase)
                XCTAssert(id == self.validIdentifiers.first!)
            default: XCTFail()
            }
            
        }
        
    }
    
    
    /// FakePaymentQueue ensures the completion handler of AppStoreController.purchase is called immediately
    func testPurchaseOfInvalidProductFails() {
        
        // Given
        let product = AppStoreProduct(storeKit: FakeProduct())
        let queue = FakePaymentQueue(productIdentifiers: invalidIdentifiers)
        let controller = AppStoreController(
            productIdentifiers: invalidIdentifiers,
            transactionObserver: observer,
            paymentQueue: queue
        )
        
        // When
        controller.purchase(product) { result in
            
            // Then
            let expectedError: PaymentsError = .paymentFailed(SKError(.storeProductNotAvailable))
            
            switch result {
            case .failure(let error): XCTAssert(error == expectedError)
            default: XCTFail()
            }
            
        }
        
    }
    
    
    func testRestorationOfPreviousPurchaseWithValidIdentifiers() {
        
        // Given
        let queue = FakePaymentQueue(productIdentifiers: validIdentifiers)
        controller = AppStoreController(
            productIdentifiers: validIdentifiers,
            transactionObserver: observer,
            paymentQueue: queue
        )
        
        // When
        controller.restorePurchases { result in
            
            // Then
            switch result {
            case .restored(let id):
                XCTAssert(self.observer.didRestore)
                XCTAssert(id == self.validIdentifiers.first!)
            default: XCTFail()
            }
            
        }
        
    }
    
}
