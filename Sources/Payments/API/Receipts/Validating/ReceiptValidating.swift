//
//  ReceiptValidating.swift
//  
//
//  Created by Neil Smith on 01/12/2019.
//

import Foundation

protocol ReceiptValidating {
    init(_ strategy: ReceiptValidationStrategy)
    func validate(receipt data: Data, completion: @escaping (ReceiptValidationResult) -> Void)
}

typealias ReceiptValidationResult = Result<AppStoreReceipt, ReceiptValidationError>
