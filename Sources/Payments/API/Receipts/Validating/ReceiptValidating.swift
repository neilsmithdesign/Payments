//
//  ReceiptValidating.swift
//  
//
//  Created by Neil Smith on 01/12/2019.
//

import Foundation

protocol ReceiptValidating {
    init(_ strategy: ReceiptValidationStrategy)
    func validate(receipt data: Data, completion: @escaping () -> Void)
}

typealias ReceiptValidationResult = Result<Receipt, ReceiptValidationError>

struct Receipt {
    #warning("TO DO: Contents of the receipt as swift properties - see Strongr.")
}

enum ReceiptValidationError: Error {
    case couldNotFindReceipt
    case couldNotLoadReceipt(Error?)
    case emptyReceiptContents
    case receiptNotSigned
    case appleRootCertificateNotFound
    case receiptSignatureInvalid
    case malformedReceipt
    case malformedInAppPurchaseReceipt
    case incorrectHash
    case other(Error?)
}
