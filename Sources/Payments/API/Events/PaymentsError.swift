//
//  PaymentsError.swift
//  
//
//  Created by Neil Smith on 29/11/2019.
//

import StoreKit

public enum PaymentsError: Error {
    
    case receiptError(ReceiptError)
    case productLoadRequestFailed(message: String)
    case paymentFailed(SKError)
    case networkUnavailable
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
