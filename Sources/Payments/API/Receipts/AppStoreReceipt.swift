//
//  AppStoreReceipt.swift
//  
//
//  Created by Neil Smith on 02/12/2019.
//

import Foundation

public struct AppStoreReceipt: Hashable, Decodable {
    public let bundleID: BundleID
    let appVersion: AppVersion
    let hash: Hash
    let date: Dates
    let inAppPurchaseReceipts: [InAppPurchaseReceipt]
}

public extension AppStoreReceipt {
    
    struct BundleID: Hashable, Decodable {
        public let name: String
        let data: Data
    }
    
    struct AppVersion: Hashable, Decodable {
        let current: String
        let original: String
    }
    
    struct Hash: Hashable, Decodable {
        let sha1: Data
        let opaqueValue: Data
    }
    
    struct Dates: Hashable, Decodable {
        let receiptCreation: Date
        let expiration: Date?
    }
    
}
