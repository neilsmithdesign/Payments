//
//  MockReceiptValidator.swift
//  
//
//  Created by Neil Smith on 02/12/2019.
//

import Foundation

struct MockReceiptValidator: ReceiptValidating {
    
    init(mockValidator: ReceiptValidatingLocally = MockLocalReceiptValidator()) {
        self.mockValidator = mockValidator
    }
    
    private let mockValidator: ReceiptValidatingLocally
    
    func validate(receipt data: Data, completion: @escaping (ReceiptValidationResult) -> Void) {
        completion(mockValidator.validate(receipt: data))
    }
    
}
