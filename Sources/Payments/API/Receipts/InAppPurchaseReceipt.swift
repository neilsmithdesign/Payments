//
//  InAppPurchaseReceipt.swift
//  
//
//  Created by Neil Smith on 02/12/2019.
//

import Foundation

struct InAppPurchaseReceipt: Hashable, Decodable {
    let quantity: Int
    let id: IDs
    let date: Dates
}

extension InAppPurchaseReceipt {
    
    struct IDs: Hashable, Decodable {
        let product: ProductIdentifier
        let transaction: TransactionIdentifier
        let originalTransaction: TransactionIdentifier
        let webOrderLineItem: Int?
    }
    
    struct Dates: Hashable, Decodable {
        let purchase: Date
        let originalPurchase: Date
        let subscriptionExpiration: Date?
        let cancellation: Date?
    }
    
}

extension InAppPurchaseReceipt.IDs {
    
    init?(product: ProductIdentifier?, transaction: TransactionIdentifier?, originalTransaction: TransactionIdentifier?, webOrderLineItem: Int?) {
        guard let p = product, let t = transaction, let ot = originalTransaction else { return nil }
        self.product = p
        self.transaction = t
        self.originalTransaction = ot
        self.webOrderLineItem = webOrderLineItem
    }
    
}

extension InAppPurchaseReceipt.Dates {
    
    init?(purchase: Date?, originalPurchase: Date?, subscriptionExpiration: Date?, cancellation: Date?) {
        guard let p = purchase, let op = originalPurchase else { return nil }
        self.purchase = p
        self.originalPurchase = op
        self.subscriptionExpiration = subscriptionExpiration
        self.cancellation = cancellation
    }
    
}

extension InAppPurchaseReceipt {
    
    enum AttributeType: Int {
        case quantity = 1701
        case productIdentifier = 1702
        case transactionIdentifier = 1703
        case purchaseDate = 1704
        case originalTransactionIdentifier = 1705
        case originalPurchaseDate = 1706
        case subscriptionExpirationDate = 1708
        case webOrderLineItem = 1711
        case cancellationDate = 1712
        
        var asn1FieldType: Int {
            return self.rawValue
        }
        
        var jsonKey: String {
            switch self {
            case .quantity: return "quantity"
            case .productIdentifier: return "product_id"
            case .transactionIdentifier: return "transaction_id"
            case .purchaseDate: return "purchase_date"
            case .originalTransactionIdentifier: return "original_transaction_id"
            case .originalPurchaseDate: return "original_purchase_date"
            case .subscriptionExpirationDate: return "expires_date"
            case .webOrderLineItem: return "web_order_line_item_id"
            case .cancellationDate: return "cancellation_date"
            }
        }
    }
    
}

typealias TransactionIdentifier = String
