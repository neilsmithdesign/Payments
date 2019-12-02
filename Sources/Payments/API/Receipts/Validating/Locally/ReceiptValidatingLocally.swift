//
//  ReceiptValidatingLocally.swift
//  
//
//  Created by Neil Smith on 02/12/2019.
//

import Foundation

struct LocalReceiptValidationInput {
    let rootCertificateName: String
    let bundle: Bundle
}

protocol ReceiptValidatingLocally {
    init(_ input: LocalReceiptValidationInput)
    func validate(receipt data: Data) -> ReceiptValidationResult
}
