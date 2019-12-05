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
    public let hash: Hash?
    public let date: Dates?
    public let inAppPurchaseReceipts: [InAppPurchaseReceipt]
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: JSONKeys.self)
        let bundleID = try container.decode(String.self, forKey: .bundleID)
        let appVersionNumber = try container.decode(String.self, forKey: .appVersion)
        let originalAppVersionNumber = try container.decode(String.self, forKey: .originalVersion)
        let creationDate = try container.decode(String.self, forKey: .creationDate)
        let expirationDate = try container.decode(String.self, forKey: .expirationDate)
        let inAppPurchaseReceipts = try container.decode([InAppPurchaseReceipt].self, forKey: .inAppPurchases)
        self.bundleID = .init(name: bundleID, data: nil)
        self.appVersion = .init(current: appVersionNumber, original: originalAppVersionNumber)
        self.hash = nil
        self.date = Dates.init(creation: creationDate, expiration: expirationDate)
        self.inAppPurchaseReceipts = inAppPurchaseReceipts
    }
    
}

public extension AppStoreReceipt {
    
    struct BundleID: Hashable {
        public let name: String
        public let data: Data?
    }
    
    struct AppVersion: Hashable {
        public let current: String
        public let original: String
    }
    
    struct Hash: Hashable {
        public let sha1: Data
        public let opaqueValue: Data
    }
    
    struct Dates: Hashable {
        public let receiptCreation: Date
        public let expiration: Date?
        
        init?(creation: String, expiration: String?) {
            guard let c = try? Date.from(RFC3339: creation) else { return nil }
            self.receiptCreation = c
            if let exp = expiration, let e = try? Date.from(RFC3339: exp) {
                self.expiration = e
            } else {
                self.expiration = nil
            }
        }
    }
    
}

extension AppStoreReceipt {
    
    enum JSONKeys: String, CodingKey {
        case bundleID = "bundle_id"
        case appVersion = "application_version"
        case originalVersion = "original_application_version"
        case creationDate = "receipt_creation_date"
        case expirationDate = "expiration_date"
        case inAppPurchases = "in_app"
    }
    
}
