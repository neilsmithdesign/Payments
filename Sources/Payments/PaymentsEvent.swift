//
//  PaymentsEvent.swift
//  
//
//  Created by Neil Smith on 27/08/2019.
//

import Foundation
import StoreKit

public enum PaymentsEvent {
    
    // MARK: - Load products
    enum LoadProducts {
        
        public struct Succeeded: PaymentsNotifying {
            
            public typealias Content = Set<Product>
            public var content: Set<Product>
            public static var kind: PaymentsEventKind { .loadProductsSucceeded }
            public init(_ content: Set<Product>) {
                self.content = content
            }
        }
        
        public struct Failed: PaymentsNotifying {
            
            public typealias Content = PaymentsError
            public var content: PaymentsError
            public static var kind: PaymentsEventKind { .loadProductsFailed }
            public init(_ content: PaymentsError) {
                self.content = content
            }
            
        }
        
    }
    
    
    // MARK: - Cannot make
    struct CannotMakePayments: PaymentsNotifying {
        
        public typealias Content = Any?
        public var content: Any?
        public static var kind: PaymentsEventKind { .cannotMakePayments }
        public init(_ content: Any?) {
            self.content = content
        }
        
    }
    
    enum Payment {
        
        // MARK: - Complete
        public struct Complete: PaymentsNotifying {
            
            public typealias Content = ProductIdentifier
            public var content: ProductIdentifier
            public static var kind: PaymentsEventKind { .paymentCompletedSuccessfully }
            public init(_ content: ProductIdentifier) {
                self.content = content
            }

        }
        
        
        // MARK: - Restored
        public struct Restored: PaymentsNotifying {
            
            public typealias Content = ProductIdentifier
            public var content: ProductIdentifier
            public static var kind: PaymentsEventKind { .paymentRestoredSuccessfully }
            public init(_ content: ProductIdentifier) {
                self.content = content
            }

        }
    
    
        // MARK: - Deferred
        public struct Deferred: PaymentsNotifying {
            
            public typealias Content = Payments.DeferredAlert
            public var content: Payments.DeferredAlert
            public static var kind: PaymentsEventKind { .paymentDeferred }
            public init(_ content: Payments.DeferredAlert) {
                self.content = content
            }
        }
        
        
        // MARK: - Failed
        public struct Failed: PaymentsNotifying {
            
            public typealias Content = PaymentsError
            public var content: PaymentsError
            public static var kind: PaymentsEventKind { .paymentFailed }
            public init(_ content: PaymentsError) {
                self.content = content
            }
   
        }
        
    }
    
}
