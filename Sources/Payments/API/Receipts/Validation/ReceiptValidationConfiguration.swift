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
        case .local(let input): return ReceiptValidator(.local(LocalReceiptValidator(input)))
        case .remote(let url): return ReceiptValidator(.remote(RemoteReceiptValidator(url: url)))
        }
    }
    
    public enum ValidationKind {
        case local(LocalReceiptValidationInput)
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
