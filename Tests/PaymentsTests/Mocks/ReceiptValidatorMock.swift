//
//  ReceiptValidatorMock.swift
//  
//
//  Created by Neil Smith on 02/12/2019.
//

import Foundation
@testable import Payments

struct ReceiptValidatorMock: ReceiptValidating {
    
    init(mockValidator: ReceiptValidatingLocally = LocalReceiptValidatorMock()) {
        self.mockValidator = mockValidator
    }
    
    private let mockValidator: ReceiptValidatingLocally
    
    func validate(receipt data: Data, completion: @escaping (ReceiptValidationResult) -> Void) {
        completion(mockValidator.validate(receipt: data))
    }
    
}
