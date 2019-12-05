//
//  ReceiptValidatingLocally.swift
//  
//
//  Created by Neil Smith on 02/12/2019.
//

import Foundation

public struct LocalReceiptValidationInput {
    public let rootCertificateName: String
    public let bundle: Bundle
    public init(rootCertificateName: String, bundle: Bundle) {
        self.rootCertificateName = rootCertificateName
        self.bundle = bundle
    }
}

public protocol ReceiptValidatingLocally {
    init(_ input: LocalReceiptValidationInput)
    func validate(receipt data: Data) -> ReceiptValidationResult
}
