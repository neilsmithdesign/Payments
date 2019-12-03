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

    
    func testTransactionObserverExistsWhenNotSupplied() {
        
        // Given
        let paymentQueue = SKPaymentQueueMock()
        
        // When
        controller = AppStoreController(productIdentifiers: [], transactionObserver: nil, paymentQueue: paymentQueue)
        
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
        controller = AppStoreController(productIdentifiers: [], transactionObserver: observer, paymentQueue: paymentQueue)
        
        // Then
        XCTAssertNotNil(paymentQueue.observer)
        
    }
    
    func testObserverIsNilWhenUserCannotMakePayments() {
        
        // Given
        let paymentQueue = SKPaymentQueueCannotMakePaymentsMock()
        
        // When
        controller = AppStoreController(productIdentifiers: [], transactionObserver: nil, paymentQueue: paymentQueue)
        
        // Then
        XCTAssertNil(paymentQueue.observer)
        
    }
    
}


