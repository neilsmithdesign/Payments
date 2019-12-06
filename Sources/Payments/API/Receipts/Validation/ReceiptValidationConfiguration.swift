//
//  ReceiptValidationConfiguration.swift
//  
//
//  Created by Neil Smith on 03/12/2019.
//

import Foundation

public struct ReceiptValidationConfiguration {
    
    let loader: ReceiptLoading?
    let validationKind: ValidationKind
    
    public init(loader: ReceiptLoading? = nil, validationKind: ValidationKind) {
        self.loader = loader
        self.validationKind = validationKind
    }
    
    var validator: ReceiptValidating {
        switch validationKind {
        case .local(let localValidator): return ReceiptValidator(.local(localValidator))
        case .remote(let url): return ReceiptValidator(.remote(RemoteReceiptValidator(url: url)))
        }
    }
    
    public enum ValidationKind {
        case local(ReceiptValidatingLocally)
        case remote(URL)
    }
}

public extension ReceiptValidationConfiguration {
    
    static func appStore(validation kind: ValidationKind, bundle: Bundle) -> ReceiptValidationConfiguration {
        return self.init(
            loader: AppStoreReceiptLoader(location: bundle),
            validationKind: kind
        )
    }
    
}
