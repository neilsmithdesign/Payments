//
//  ReceiptValidationErrors.swift
//  
//
//  Created by Neil Smith on 02/12/2019.
//

import Foundation

enum ReceiptValidationError: Error {
    case couldNotFindReceipt
    case couldNotLoadReceipt(Error?)
    case extractionError(ReceiptContainerExtractionError)
    case signatureError(ReceiptSignatureError)
    case parsingError(ReceiptParsingError)
    case incorrectHash
    case other(Error?)
}

enum ReceiptContainerExtractionError: Error {
    case emptyContents
}

enum ReceiptSignatureVerificationError: Error {
    case notSigned
    case rootCertificateNotFound
}

enum ReceiptSignatureAuthenticationError: Error {
    case invalid
}

enum ReceiptSignatureError: Error {
    case verificationError(ReceiptSignatureVerificationError)
    case authenticationError(ReceiptSignatureAuthenticationError)
}

enum ReceiptParsingError: Error {
    case malformed(ReceiptKind)
    enum ReceiptKind {
        case appReceipt
        case inAppPurchaseReceipt
    }
}
