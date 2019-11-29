//
//  PaymentsErrorTests.swift
//  
//
//  Created by Neil Smith on 29/11/2019.
//

import XCTest
@testable import Payments
import StoreKit


final class PaymentsErrorTests: XCTestCase {
    
    func testNetworkConnectionLostErrorIsProduced() {
        
        // Given
        let systemError = NSError(domain: NSURLErrorDomain, code: -1005, userInfo: nil)
        
        // When
        let error = PaymentsError(systemError)
        
        // Then
        XCTAssert(error == PaymentsError.networkUnavailable)
        
    }
    
    func testSKErrorIsProducedIfPaymentotAllowed() {
        
        // Given
        let storeKitError = SKError(.paymentNotAllowed)
        
        // When
        let error = PaymentsError(storeKitError)
        
        // Then
        XCTAssert(error == PaymentsError.paymentFailed(storeKitError))
        
    }
    
}

