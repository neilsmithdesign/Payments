//
//  PaymentsNotification.swift
//  
//
//  Created by Neil Smith on 27/08/2019.
//

import Foundation
import StoreKit

public enum PaymentsNotification {
    
    case loadProductsSucceeded
    case loadProductsFailed
    case cannotMakePayments
    case paymentCompletedSuccessfully
    case paymentRestoredSuccessfully
    case paymentDeferred
    
    public var name: Notification.Name {
        return .init(root)
    }
    
    public var userInfoKey: String {
        return root + ".user.info.key"
    }
    
    private var root: String {
        var name = "com.NeilSmithDesignLTD.payments"
        switch self {
        case .loadProductsSucceeded: name += ".load.products.succeeded"
        case .loadProductsFailed: name += ".load.products.failed"
        case .cannotMakePayments: name += ".cannot.make.payments"
        case .paymentCompletedSuccessfully: name += ".payment.completed.successfully"
        case .paymentRestoredSuccessfully: name += ".payment.restored.successfully"
        case .paymentDeferred: name += "payment.deferred"
        }
        return name
    }
    
}



public protocol PaymentsNotifying {
    associatedtype Content
    var content: Content { get set }
    static var ntf: PaymentsNotification { get }
    init()
}

public extension PaymentsNotifying {
    
    init?(_ notification: Notification) {
        guard let content = notification.userInfo?[Self.key] as? Content else { return nil }
        self.init()
        self.content = content
    }
}

extension PaymentsNotifying {
    static var notification: Notification.Name { ntf.name }
    static var key: String { ntf.userInfoKey }
}
extension PaymentsNotifying {
    static func notify(with content: Content) {
        NotificationCenter.default.post(
            name: Self.notification,
            object: nil,
            userInfo: [Self.key : content]
        )
    }
}


public extension PaymentsNotification {
    
    
    // MARK: - Loaded
    enum LoadedProducts {
        
        public struct Succeeded: PaymentsNotifying {
            public typealias Content = Set<Product>
            public var content: Set<Product>
            public static var ntf: PaymentsNotification { .loadProductsSucceeded }
            public init() {
                self.content = []
            }
        }
        
        public struct Failed: PaymentsNotifying {
            public typealias Content = PaymentsError
            public var content: PaymentsError
            public static var ntf: PaymentsNotification { .loadProductsSucceeded }
            public init() {
                self.content = .productLoadRequestFailed(message: "")
            }
        }
        
    }
    
    
    // MARK: - Cannot make
    struct CannotMakePayments: PaymentsNotifying {
        public typealias Content = Any?
        public var content: Any?
        public static var ntf: PaymentsNotification { .loadProductsSucceeded }
        public init() {
            self.content = nil
        }
    }
    
    enum Payment {
        
        
        // MARK: - Complete
        public struct Complete: PaymentsNotifying {
            public typealias Content = ProductIdentifier
            public var content: ProductIdentifier
            public static var ntf: PaymentsNotification { .paymentCompletedSuccessfully }
            public init() {
                self.content = ""
            }
        }
        
        
        // MARK: - Restored
        public struct Restored: PaymentsNotifying {
            public typealias Content = ProductIdentifier
            public var content: ProductIdentifier
            public static var ntf: PaymentsNotification { .paymentRestoredSuccessfully }
            public init() {
                self.content = ""
            }
        }
    
    
        // MARK: - Deferred
        public struct Deferred: PaymentsNotifying {
            public typealias Content = Payments.DeferredAlert
            public var content: Payments.DeferredAlert
            public static var ntf: PaymentsNotification { .paymentDeferred }
            public init() {
                self.content = .standardMessage(for: "")
            }
        }
        
        
        // MARK: - Failed
        public struct Failed: PaymentsNotifying {
            public typealias Content = SKError
            public var content: SKError
            public static var ntf: PaymentsNotification { .paymentDeferred }
            public init() {
                self.content = .init(_nsError: NSError())
            }
            
            
        }
        
    }
    
}

