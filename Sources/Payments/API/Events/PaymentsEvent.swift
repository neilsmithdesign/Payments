//
//  PaymentsEvent.swift
//  
//
//  Created by Neil Smith on 27/08/2019.
//

import Foundation
import StoreKit

/// Container type for various payment events. Nested types use
/// NotificationCenter to broadcast to their observers.
public enum PaymentEvent {
    
    static func notify(for transaction: SKPaymentTransaction) {
        let id = transaction.payment.productIdentifier
        switch transaction.transactionState {
        case .failed: Payment.Failed.notify(with: PaymentsError(transaction.error))
        case .deferred: Payment.Deferred.notify(with: .standardMessage(productIdentifier: id))
        case .purchased: Payment.Complete.notify(with: id)
        case .restored: Payment.Restored.notify(with: id)
        case .purchasing: break
        @unknown default: fatalError()
        }
    }
    
}

public extension PaymentEvent {
        
    // MARK: - Load products
    enum LoadProducts {
        
        public struct Succeeded: PaymentsNotifying {
            
            public typealias Content = Set<Product>
            public var content: Set<Product>
            public static var kind: PaymentEventKind { .loadProductsSucceeded }
            public init(_ content: Set<Product>) {
                self.content = content
            }
        }
        
        public struct Failed: PaymentsNotifying {
            
            public typealias Content = PaymentsError
            public var content: PaymentsError
            public static var kind: PaymentEventKind { .loadProductsFailed }
            public init(_ content: PaymentsError) {
                self.content = content
            }
            
        }
        
    }
    
    
    // MARK: - Cannot make
    struct CannotMakePayments: PaymentsNotifying {
        
        public typealias Content = Any?
        public var content: Any?
        public static var kind: PaymentEventKind { .cannotMakePayments }
        public init(_ content: Any?) {
            self.content = content
        }
        
    }
    
    enum Payment {
        
        // MARK: - Complete
        public struct Complete: PaymentsNotifying {
            
            public typealias Content = ProductIdentifier
            public var content: ProductIdentifier
            public static var kind: PaymentEventKind { .paymentCompletedSuccessfully }
            public init(_ content: ProductIdentifier) {
                self.content = content
            }
            
        }
        
        
        // MARK: - Restored
        public struct Restored: PaymentsNotifying {
            
            public typealias Content = ProductIdentifier
            public var content: ProductIdentifier
            public static var kind: PaymentEventKind { .paymentRestoredSuccessfully }
            public init(_ content: ProductIdentifier) {
                self.content = content
            }
            
        }
        
        
        // MARK: - Deferred
        public struct Deferred: PaymentsNotifying {
            
            public typealias Content = PaymentDeferredAlert
            public var content: PaymentDeferredAlert
            public static var kind: PaymentEventKind { .paymentDeferred }
            public init(_ content: PaymentDeferredAlert) {
                self.content = content
            }
        }
        
        
        // MARK: - Failed
        public struct Failed: PaymentsNotifying {
            
            public typealias Content = PaymentsError
            public var content: PaymentsError
            public static var kind: PaymentEventKind { .paymentFailed }
            public init(_ content: PaymentsError) {
                self.content = content
            }
            
        }
        
    }
    
}
