//
//  AppStoreReceiptValidator.swift
//  
//
//  Created by Neil Smith on 02/12/2019.
//

import Foundation

struct AppStoreReceiptValidator: ReceiptValidating {
    
    init(_ strategy: ReceiptValidationStrategy) {
        self.strategy = strategy
    }
    

    private let strategy: ReceiptValidationStrategy
    
    
}

extension AppStoreReceiptValidator {
    
    
    func validate(receipt data: Data, completion: @escaping (ReceiptValidationResult) -> Void) {
        
    }
    
}

extension AppStoreReceiptValidator {
    
    private func locallyValidate(receipt data: Data, completion: @escaping (ReceiptValidationResult) -> Void) {
        
    }
    
}
