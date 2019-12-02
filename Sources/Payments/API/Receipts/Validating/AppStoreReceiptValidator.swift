//
//  AppStoreReceiptValidator.swift
//  
//
//  Created by Neil Smith on 02/12/2019.
//

import Foundation

struct AppStoreReceiptValidator: ReceiptValidating {
    
    init(_ strategy: ReceiptValidationStrategy, localValidator: ReceiptValidatingLocally? = nil, remoteValidator: ReceiptValidatingRemotely? = nil) {
        self.strategy = strategy
        self.localValidator = localValidator
        self.remoteValidator = remoteValidator
    }
    
    private let strategy: ReceiptValidationStrategy
    
    private let localValidator: ReceiptValidatingLocally?
    private let remoteValidator: ReceiptValidatingRemotely?
    
}

extension AppStoreReceiptValidator {
    
    
    func validate(receipt data: Data, completion: @escaping (ReceiptValidationResult) -> Void) {
        switch strategy {
        case .local: locallyValidate(receipt: data, completion: completion)
        case .remote: remotelyValidate(receipt: data, completion: completion)
        }
    }
    
}

extension AppStoreReceiptValidator {
    
    private func locallyValidate(receipt data: Data, completion: @escaping (ReceiptValidationResult) -> Void) {
        guard let validator = localValidator else {
            completion(.failure(.local(.other(AppStoreReceiptValidatorError.missingLocalValidator))))
            return
        }
        completion(validator.validate(receipt: data))
    }
    
}

extension AppStoreReceiptValidator {
    
    private func remotelyValidate(receipt data: Data, completion: @escaping (ReceiptValidationResult) -> Void) {
        guard let validator = remoteValidator else {
            completion(.failure(.remote(.other(AppStoreReceiptValidatorError.missingRemoteValidator))))
            return
        }
        validator.validate(receipt: data, completion: completion)
    }
    
}

enum AppStoreReceiptValidatorError: Error {
    case missingLocalValidator
    case missingRemoteValidator
}
