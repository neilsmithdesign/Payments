//
//  AppStoreReceiptValidator.swift
//  
//
//  Created by Neil Smith on 02/12/2019.
//

import Foundation

public struct ReceiptValidator: ReceiptValidating {
    
    public init(_ validatorKind: ReceiptValidatorKind) {
        self.validatorKind = validatorKind
    }
    
    private let validatorKind: ReceiptValidatorKind

    public func validate(receipt data: Data, completion: @escaping (ReceiptValidationResult) -> Void) {
        switch validatorKind {
        case .local(let validator): completion(validator.validate(receipt: data))
        case .remote(let validator): validator.validate(receipt: data, completion: completion)
        }
    }
    
}
