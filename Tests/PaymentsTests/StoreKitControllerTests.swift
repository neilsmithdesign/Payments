//
//  StoreKitControllerTests.swift
//  
//
//  Created by Neil Smith on 30/11/2019.
//

import XCTest
import StoreKit
@testable import Payments

final class StoreKitControllerTests: XCTestCase {
    
    var controller: StoreKitController!

    
    func testTransactionObserverExistsWhenNotSupplied() {
        
        // Given
        let paymentQueue = SKPaymentQueueMock()
        
        // When
        controller = StoreKitController(productIdentifiers: [], transactionObserver: nil, paymentQueue: paymentQueue)
        
        // Then
        XCTAssertNotNil(paymentQueue.observer)
        
    }
    
    func testTransactionObserverExistsWhenSupplied() {
        
        // Given
        class TransactionObserver: NSObject, SKPaymentTransactionObserver {
            func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {}
        }
        let observer = TransactionObserver()
        let paymentQueue = SKPaymentQueueMock()
        
        // When
        controller = StoreKitController(productIdentifiers: [], transactionObserver: observer, paymentQueue: paymentQueue)
        
        // Then
        XCTAssertNotNil(paymentQueue.observer)
        
    }
    
    func testObserverIsNilWhenUserCannotMakePayments() {
        
        // Given
        let paymentQueue = SKPaymentQueueCannotMakePaymentsMock()
        
        // When
        controller = StoreKitController(productIdentifiers: [], transactionObserver: nil, paymentQueue: paymentQueue)
        
        // Then
        XCTAssertNil(paymentQueue.observer)
        
    }
    
}


