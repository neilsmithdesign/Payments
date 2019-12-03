//
//  PaymentsEventKind.swift
//  
//
//  Created by Neil Smith on 29/11/2019.
//

import Foundation

public extension Payments {
    
    enum EventKind {
        case loadProductsSucceeded
        case loadProductsFailed
        case cannotMakePayments
        case paymentCompletedSuccessfully
        case paymentRestoredSuccessfully
        case paymentDeferred
        case paymentFailed
        
        var notification: Notification.Name {
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
            case .paymentFailed: name += "payment.failed"
            }
            return name
        }        
    }
    
    
}
