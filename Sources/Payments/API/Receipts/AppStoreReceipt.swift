//
//  AppStoreReceipt.swift
//  
//
//  Created by Neil Smith on 02/12/2019.
//

import Foundation

struct AppStoreReceipt: Hashable {
    let bundleID: BundleID
    let appVersion: AppVersion
    let hash: Hash
    let date: Dates
    let inAppPurchaseReceipts: [InAppPurchaseReceipt]
}

extension AppStoreReceipt {
    
    struct BundleID: Hashable {
        let name: String
        let data: NSData
    }
    
    struct AppVersion: Hashable {
        let current: String
        let original: String
    }
    
    struct Hash: Hashable {
        let sha1: NSData
        let opaqueValue: NSData
    }
    
    struct Dates: Hashable {
        let receiptCreation: Date
        let expiration: Date?
    }
    
}
