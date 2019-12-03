//
//  AppStoreReceipt.swift
//  
//
//  Created by Neil Smith on 02/12/2019.
//

import Foundation

public struct AppStoreReceipt: Hashable, Decodable {
    public let bundleID: BundleID
    public let appVersion: AppVersion
    public let hash: Hash
    public let date: Dates
    public let inAppPurchaseReceipts: [InAppPurchaseReceipt]
}

public extension AppStoreReceipt {
    
    struct BundleID: Hashable, Decodable {
        public let name: String
        public let data: Data
    }
    
    struct AppVersion: Hashable, Decodable {
        public let current: String
        public let original: String
    }
    
    struct Hash: Hashable, Decodable {
        public let sha1: Data
        public let opaqueValue: Data
    }
    
    struct Dates: Hashable, Decodable {
        public let receiptCreation: Date
        public let expiration: Date?
    }
    
}
