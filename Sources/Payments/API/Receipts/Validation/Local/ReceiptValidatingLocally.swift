//
//  ReceiptValidatingLocally.swift
//  
//
//  Created by Neil Smith on 02/12/2019.
//

import Foundation

/// The necessary info required to perform local receipt validation
public struct LocalReceiptValidationInput {
    public let rootCertificateName: String
    public let bundle: Bundle
    public init(rootCertificateName: String, bundle: Bundle) {
        self.rootCertificateName = rootCertificateName
        self.bundle = bundle
    }
}

/// Conform your own custom implementation of a local receipt validator to this protocol
/// and supply as part of your AppStoreConfiguration initializer.
public protocol ReceiptValidatingLocally {
    init(_ input: LocalReceiptValidationInput)
    func validate(receipt data: Data) -> ReceiptValidationResult
}
