//
//  LocalReceiptValidationError.swift
//  
//
//  Created by Neil Smith on 02/12/2019.
//

import Foundation

public enum LocalReceiptValidationError: Error {
    case extractionError(ReceiptContainerExtractionError)
    case signatureError(ReceiptSignatureError)
    case parsingError(ReceiptParsingError)
    case incorrectHash
    case other(Error?)
}

public enum ReceiptContainerExtractionError: Error {
    case emptyContents
}

public enum ReceiptSignatureVerificationError: Error {
    case notSigned
    case rootCertificateNotFound
}

public enum ReceiptSignatureAuthenticationError: Error {
    case invalid
}

public enum ReceiptSignatureError: Error {
    case verificationError(ReceiptSignatureVerificationError)
    case authenticationError(ReceiptSignatureAuthenticationError)
}

public enum ReceiptParsingError: Error {
    case malformed(ReceiptKind)
    public enum ReceiptKind {
        case appReceipt
        case inAppPurchaseReceipt
    }
}
