//
//  PaymentsError.swift
//  
//
//  Created by Neil Smith on 29/11/2019.
//

import StoreKit

public enum PaymentsError: Error {
    
    /// Errors provided during the receipt validation process
    case receiptError(ReceiptError)
    
    /// If request to load products failed. Typically this is due
    /// to a mismatch between supplied product identifiers and
    /// those which have been configured in App Store Connect.
    case productLoadRequestFailed(message: String)
    
    /// When an in-app purchase fails and the supplied SKError
    case paymentFailed(SKError)
    
    /// If an attempt connnect to the App Store was made but the
    /// user is not connected to the network
    case networkUnavailable
    
    /// An unknown error
    case unknownError(Error?)
    
    init(_ error: Error?) {
        if let err = error {
            switch (err as NSError).domain {
            case NSURLErrorDomain: self = .networkUnavailable
            case SKErrorDomain:
                guard let skError = err as? SKError else {
                    self = .unknownError(err)
                    return
                }
                self = .paymentFailed(skError)
            default: self = .unknownError(err)
            }
        } else {
            self = .unknownError(nil)
        }
    }
}

extension PaymentsError: Equatable {
    
    public static func == (lhs: PaymentsError, rhs: PaymentsError) -> Bool {
        switch (lhs, rhs) {
        case let (.productLoadRequestFailed(lm), .productLoadRequestFailed(rm)): return lm == rm
        case let (.paymentFailed(le), .paymentFailed(re)): return le == re
        case (.networkUnavailable, .networkUnavailable): return true
        case let (.unknownError(le), .unknownError(re)): return le?.localizedDescription == re?.localizedDescription
        default: return false
        }
    }
    
}

extension PaymentsError {
    
    static let noProductsMatchingIdentifiers: PaymentsError = .productLoadRequestFailed(message: "Unable to load products for requested Identifiers.")
    
}
