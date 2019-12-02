//
//  ReceiptValidationFunctions.swift
//  
//
//  Created by Neil Smith on 02/12/2019.
//

import Foundation


func extractPKCS7Container(from receiptData: Data) -> ReceiptContainerExtractionResult {
    fatalError()
}

func verifySignature(of container: ReceiptContainer, rootCertificate name: String) -> SignatureVerificationResult {
    fatalError()
}

func verifyAuthenticity(of signature: VerifiedSignature, container: ReceiptContainer) -> SignatureAuthenticationResult {
    fatalError()
}

func parsedReceipt(from container: ReceiptContainer) -> ReceiptParsingResult {
    fatalError()
}

func parsedInAppPurchaseReceipt(currentPayloadLocation: inout PayloadLocation?, payloadLength: Int) -> InAppPurchaseReceiptParsingResult {
    
    var quantity: Int?
    var productId: String?
    var transactionId: String?
    var originalTransactionId: String?
    var purchaseDate: Date?
    var originalPurchaseDate: Date?
    var subscriptionExpirationDate: Date?
    var cancellationDate: Date?
    var webOrderLineItemId: Int?
    
    let endOfPayload = currentPayloadLocation!.advanced(by: payloadLength)
    var type = Int32(0)
    var xclass = Int32(0)
    var length = 0
    
    ASN1_get_object(&currentPayloadLocation, &length, &type, &xclass, payloadLength)
    
    // Payload must be an ASN1 Set
    guard type == V_ASN1_SET else {
        return .failure(.malformed(.inAppPurchaseReceipt))
    }
    
    // Decode Payload
    // Step through payload (ASN1 Set) and parse each ASN1 Sequence within (ASN1 Sets contain one or more ASN1 Sequences)
    while currentPayloadLocation! < endOfPayload {
        
        // Get next ASN1 Sequence
        ASN1_get_object(&currentPayloadLocation, &length, &type, &xclass, currentPayloadLocation!.distance(to: endOfPayload))
        
        // ASN1 Object type must be an ASN1 Sequence
        guard type == V_ASN1_SEQUENCE else {
            return .failure(.malformed(.inAppPurchaseReceipt))
        }
        
        // Attribute type of ASN1 Sequence must be an Integer
        guard let attributeTypeValue = ASN1.decode(integerFrom: &currentPayloadLocation, length: currentPayloadLocation!.distance(to: endOfPayload)) else {
            return .failure(.malformed(.inAppPurchaseReceipt))
        }
        
        // Attribute version of ASN1 Sequence must be an Integer
        guard ASN1.decode(integerFrom: &currentPayloadLocation, length: currentPayloadLocation!.distance(to: endOfPayload)) != nil else {
            return .failure(.malformed(.inAppPurchaseReceipt))
        }
        
        // Get ASN1 Sequence value
        ASN1_get_object(&currentPayloadLocation, &length, &type, &xclass, currentPayloadLocation!.distance(to: endOfPayload))
        
        // ASN1 Sequence value must be an ASN1 Octet String
        guard type == V_ASN1_OCTET_STRING else {
            return .failure(.malformed(.inAppPurchaseReceipt))
        }
        
        guard let attribute = InAppPurchaseReceipt.AttributeType(rawValue: attributeTypeValue) else {
            return .failure(.malformed(.inAppPurchaseReceipt))
        }
        
        // Decode attributes
        switch attribute {
        case .quantity:
            var startOfQuantity = currentPayloadLocation
            quantity = ASN1.decode(integerFrom: &startOfQuantity, length: length)
        case .productIdentifier:
            var startOfProductId = currentPayloadLocation
            productId = ASN1.decode(stringFrom: &startOfProductId, length: length)
        case .transactionIdentifier:
            var startOfTransactionId = currentPayloadLocation
            transactionId = ASN1.decode(stringFrom: &startOfTransactionId, length: length)
        case .originalTransactionIdentifier:
            var startOfOriginalTransactionId = currentPayloadLocation
            originalTransactionId = ASN1.decode(stringFrom: &startOfOriginalTransactionId, length: length)
        case .purchaseDate:
            var startOfPurchaseDate = currentPayloadLocation
            purchaseDate = ASN1.decode(dateFrom: &startOfPurchaseDate, length: length)
        case .originalPurchaseDate:
            var startOfOriginalPurchaseDate = currentPayloadLocation
            originalPurchaseDate = ASN1.decode(dateFrom: &startOfOriginalPurchaseDate, length: length)
        case .subscriptionExpirationDate:
            var startOfSubscriptionExpirationDate = currentPayloadLocation
            subscriptionExpirationDate = ASN1.decode(dateFrom: &startOfSubscriptionExpirationDate, length: length)
        case .cancellationDate:
            var startOfCancellationDate = currentPayloadLocation
            cancellationDate = ASN1.decode(dateFrom: &startOfCancellationDate, length: length)
        case .webOrderLineItem:
            var startOfWebOrderLineItemId = currentPayloadLocation
            webOrderLineItemId = ASN1.decode(integerFrom: &startOfWebOrderLineItemId, length: length)
        }
        
        currentPayloadLocation = currentPayloadLocation!.advanced(by: length)
    }
    
    guard
        let q = quantity,
        let ids = InAppPurchaseReceipt.IDs(product: productId, transaction: transactionId, originalTransaction: originalTransactionId, webOrderLineItem: webOrderLineItemId),
        let dates = InAppPurchaseReceipt.Dates(purchase: purchaseDate, originalPurchase: originalPurchaseDate, subscriptionExpiration: subscriptionExpirationDate, cancellation: cancellationDate)
        else {
            return .failure(.malformed(.inAppPurchaseReceipt))
    }
    
    let receipt = InAppPurchaseReceipt(quantity: q, id: ids, date: dates)
    
    return .success(receipt)
    
}

typealias PayloadLocation = UnsafePointer<UInt8>



#warning("Remove types and replace with types from OpenSSL and other libraries.")
struct PKCS7 {}
struct X509 {}


@discardableResult
func ASN1_get_object(_ pp: UnsafeMutablePointer<UnsafePointer<UInt8>?>!, _ plength: UnsafeMutablePointer<Int>!, _ ptag: UnsafeMutablePointer<Int32>!, _ pclass: UnsafeMutablePointer<Int32>!, _ omax: Int) -> Int32 {
    fatalError()
}
func c2i_ASN1_INTEGER(_ a: UnsafeMutablePointer<UnsafeMutablePointer<ASN1_INTEGER>?>!, _ pp: UnsafeMutablePointer<UnsafePointer<UInt8>?>!, _ length: Int) -> UnsafeMutablePointer<ASN1_INTEGER>! {
    fatalError()
}

func ASN1_INTEGER_get(_ a: UnsafePointer<ASN1_INTEGER>!) -> Int {
    fatalError()
}

func ASN1_INTEGER_free(_ a: UnsafeMutablePointer<ASN1_INTEGER>!) {
    fatalError()
}

struct ASN1_INTEGER {}
var V_ASN1_SET: Int32 { fatalError() }
var V_ASN1_SEQUENCE: Int32 { fatalError() }
var V_ASN1_INTEGER: Int32 { fatalError() }
var V_ASN1_UTF8STRING: Int32 { fatalError() }
var V_ASN1_IA5STRING: Int32 { fatalError() }
var V_ASN1_OCTET_STRING: Int32 { fatalError() }


struct ASN1 {
    
    static func decode(integerFrom pointer: inout UnsafePointer<UInt8>?, length: Int) -> Int? {
        var type = Int32(0)
        var xclass = Int32(0)
        var intLength = 0
        
        ASN1_get_object(&pointer, &intLength, &type, &xclass, length)
        
        guard type == V_ASN1_INTEGER else { return nil }
        
        let integer = c2i_ASN1_INTEGER(nil, &pointer, intLength)
        let result = ASN1_INTEGER_get(integer)
        ASN1_INTEGER_free(integer)
        
        return result
    }
    
    static func decode(stringFrom pointer: inout UnsafePointer<UInt8>?, length: Int) -> String? {
        var type = Int32(0)
        var xclass = Int32(0)
        var stringLength = 0
        
        ASN1_get_object(&pointer, &stringLength, &type, &xclass, length)
        
        if type == V_ASN1_UTF8STRING {
            let mutableStringPointer = UnsafeMutableRawPointer(mutating: pointer!)
            return String(bytesNoCopy: mutableStringPointer, length: stringLength, encoding: String.Encoding.utf8, freeWhenDone: false)
        }
        
        if type == V_ASN1_IA5STRING {
            let mutableStringPointer = UnsafeMutableRawPointer(mutating: pointer!)
            return String(bytesNoCopy: mutableStringPointer, length: stringLength, encoding: String.Encoding.ascii, freeWhenDone: false)
        }
        
        return nil
    }
    
    static func decode(dateFrom pointer: inout UnsafePointer<UInt8>?, length: Int) -> Date? {
        fatalError()
    }
    
}
