//
//  ReceiptValidationResultTypes.swift
//  
//
//  Created by Neil Smith on 02/12/2019.
//

import Foundation

typealias ReceiptContainerExtractionResult = Result<ReceiptContainer, ReceiptContainerExtractionError>
typealias SignatureVerificationResult = Result<VerifiedSignature, ReceiptSignatureVerificationError>
typealias SignatureAuthenticationResult = Result<AuthenticatedSignature, ReceiptSignatureAuthenticationError>
typealias ReceiptParsingResult = Result<AppStoreReceipt, ReceiptParsingError>
typealias InAppPurchaseReceiptParsingResult = Result<InAppPurchaseReceipt, ReceiptParsingError>
