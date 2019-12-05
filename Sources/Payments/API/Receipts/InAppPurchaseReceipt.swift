//
//  InAppPurchaseReceipt.swift
//  
//
//  Created by Neil Smith on 02/12/2019.
//

import Foundation

public struct InAppPurchaseReceipt: Hashable, Decodable {
    
    public let quantity: Int
    public let id: IDs
    public let purchaseDate: Date
    public let originalPurchaseDate: Date
    public let subscription: Subscription?
    
}


// MARK: - IDs
public extension InAppPurchaseReceipt {
    
    struct IDs: Hashable {
        public let product: ProductIdentifier
        public let transaction: TransactionIdentifier
        public let originalTransaction: TransactionIdentifier
        public let webOrderLineItem: Int?
        public let appItem: String?
        public let externalVersion: String?
    }
    
}


// MARK: - Subscriptions
public extension InAppPurchaseReceipt {
    
    struct Subscription: Hashable {
       
        public let expiration: Expiration
        public let periodKind: PeriodKind
        public let cancellation: Cancellation?
        public let autoRenewStatus: AutoRenewStatus
        public let autoRenewPreference: ProductIdentifier
        public let priceIncreaseConsent: PriceConsent?
        
        
        // MARK: Period kind
        public enum PeriodKind: Int {
            case freeTrial = 0
            case introductoryPrice = 1
            case normal = 2
        }
        
        
        // MARK: Expiration
        public struct Expiration: Hashable {
            
            public let date: Date
            public let intent: Intent
            public let isAppStoreAttemptingToRenew: Bool
            
            public enum Intent: Int, Decodable {
                case unknown = 0 // if an integer couldn't be parsed from Apple JSON
                case customerCancellation = 1
                case billingError = 2
                case customerPriceIncreaseRejection = 3
                case productUnavailableAtRenewal = 4
                case unknownError = 5
            }
            
        }

        
        // MARK: Cancellation
        public struct Cancellation: Hashable {
            let date: Date
            let reason: Reason
            
            public enum Reason: Int {
                case customerAccidentalPurchase = 0
                case customerIssueWithApp = 1
            }
        }
        
        
        // MARK: Renewal
        public enum AutoRenewStatus: Int {
            case off = 0
            case `on` = 1
        }
        
        public enum PriceConsent: Int {
            case hasNotAgreedIncreaseYet = 0
            case hasAgreedIncrease = 1
        }
        
    }
    
}



// MARK: - Decodable
public extension InAppPurchaseReceipt {
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: JSONKeys.self)
        let quantity = try Int(container.decode(String.self, forKey: .quantity)) ?? 0
        let productID = try container.decode(String.self, forKey: .productIdentifier)
        let transactionID = try container.decode(String.self, forKey: .transactionIdentifier)
        let originalTransactionID = try container.decode(String.self, forKey: .originalTransactionIdentifier)
        let purchaseDateString = try container.decode(String.self, forKey: .purchaseDate)
        let purchaseDate = try Date.from(RFC3339: purchaseDateString)
        let originalPurchaseDateString = try container.decode(String.self, forKey: .originalPurchaseDate)
        let originalPurchaseDate = try Date.from(RFC3339: originalPurchaseDateString)
        
        var expirationDateString: String?
        if let eds = try? container.decodeIfPresent(String.self, forKey: .subscriptionExpirationDate) {
            expirationDateString = eds
        }
        
        var expirationDateIntent: Int?
        if let edi = try? container.decodeIfPresent(String.self, forKey: .subscriptionExpirationIntent) {
            expirationDateIntent = Int(edi)
        }
        
        var isAppStoreAttemptingToRenew: Bool?
        if let atr = try? container.decodeIfPresent(String.self, forKey: .isAppStoreAttemptingToRenew), let atr_int = Int(atr) {
            isAppStoreAttemptingToRenew = atr_int == 0 ? false : true
        }
        
        var isFreeTrialPeriod: Bool?
        if let itp = try? container.decodeIfPresent(String.self, forKey: .isTrialPeriod), let itp_bool = Bool(itp) {
            isFreeTrialPeriod = itp_bool
        }
        
        var isIntroductoryPeriod: Bool?
        if let iip = try? container.decodeIfPresent(String.self, forKey: .isIntroductoryPeriod), let iip_bool = Bool(iip) {
            isIntroductoryPeriod = iip_bool
        }
        
        var cancellationDate: String?
        if let cd = try? container.decodeIfPresent(String.self, forKey: .cancellationDate) {
            cancellationDate = cd
        }
        
        var cancellationReason: Int?
        if let cr = try? container.decodeIfPresent(String.self, forKey: .cancellationReason), let cr_int = Int(cr) {
            cancellationReason = cr_int
        }
        
        var appItemID: String?
        if let aiid = try? container.decodeIfPresent(String.self, forKey: .appItemId) {
            appItemID = aiid
        }
        
        var externalVersion: String?
        if let ev = try? container.decodeIfPresent(String.self, forKey: .externalVersionIdentifier) {
            externalVersion = ev
        }
        
        var webOrderLineItemID: Int?
        if let woliid = try? container.decodeIfPresent(String.self, forKey: .webOrderLineItem), let woliid_int = Int(woliid) {
            webOrderLineItemID = woliid_int
        }
        
        var autoRenewStatusValue: Int?
        if let ars = try? container.decodeIfPresent(String.self, forKey: .subscriptionAutoRenew), let ars_int = Int(ars) {
            autoRenewStatusValue = ars_int
        }
        
        var autoRenewPreference: ProductIdentifier?
        if let arp = try? container.decodeIfPresent(ProductIdentifier.self, forKey: .subscriptionAutoRenewPreference) {
            autoRenewPreference = arp
        }
        
        var priceConsentValue: Int?
        if let pc = try? container.decodeIfPresent(String.self, forKey: .priceConsent), let pc_int = Int(pc) {
            priceConsentValue = pc_int
        }
        
        self.quantity = quantity
        self.id = .init(
            product: productID,
            transaction: transactionID,
            originalTransaction: originalTransactionID,
            webOrderLineItem: webOrderLineItemID,
            appItem: appItemID,
            externalVersion: externalVersion
        )
        self.purchaseDate = purchaseDate
        self.originalPurchaseDate = originalPurchaseDate
        let expiration = Subscription.Expiration(expirationDateRFC3339: expirationDateString, intentValue: expirationDateIntent, isAttemptingRenew: isAppStoreAttemptingToRenew)
        let periodKind = Subscription.PeriodKind(isFreeTrial: isFreeTrialPeriod, isIntroductoryPrice: isIntroductoryPeriod)
        let cancellation = Subscription.Cancellation(cancellationDateRFC3339: cancellationDate, cancellationReason: cancellationReason)
        let autoRenewStatus = Subscription.AutoRenewStatus(rawValue: autoRenewStatusValue ?? -1) // minus value returns zero (i.e. nil)
        let priceIncreaseConsent = Subscription.PriceConsent(rawValue: priceConsentValue ?? -1) // minus value returns zero (i.e. nil)
        self.subscription = Subscription(
            expiration: expiration,
            periodKind: periodKind,
            cancellation: cancellation,
            autoRenewStatus: autoRenewStatus,
            autoRenewPreference: autoRenewPreference,
            priceIncreaseConsent: priceIncreaseConsent
        )

    }
    
}


// MARK: - Decodable helpers
public extension InAppPurchaseReceipt.IDs {
    
    init?(product: ProductIdentifier?,
          transaction: TransactionIdentifier?,
          originalTransaction: TransactionIdentifier?,
          webOrderLineItem: Int?,
          appItem: String?,
          externalVersion: String?) {
        guard let p = product, let t = transaction, let ot = originalTransaction else { return nil }
        self.product = p
        self.transaction = t
        self.originalTransaction = ot
        self.webOrderLineItem = webOrderLineItem
        self.appItem = appItem
        self.externalVersion = externalVersion
    }
    
}

public extension InAppPurchaseReceipt.Subscription {
    
    init?(expiration: Expiration?, periodKind: PeriodKind?, cancellation: Cancellation?, autoRenewStatus: AutoRenewStatus?, autoRenewPreference: ProductIdentifier?, priceIncreaseConsent: PriceConsent?) {
        guard let e = expiration, let pk = periodKind, let ars = autoRenewStatus, let arp = autoRenewPreference else { return nil }
        self.expiration = e
        self.periodKind = pk
        self.cancellation = cancellation
        self.autoRenewStatus = ars
        self.autoRenewPreference = arp
        self.priceIncreaseConsent = priceIncreaseConsent
    }
    
}

public extension InAppPurchaseReceipt.Subscription.Expiration {
    
    init?(expirationDateRFC3339 dateString: String?, intentValue: Int?, isAttemptingRenew: Bool?) {
        guard let string = dateString, let iv = intentValue, let intent = Intent(rawValue: iv), let iar = isAttemptingRenew else { return nil }
        guard let date = try? Date.from(RFC3339: string) else { return nil }
        self.date = date
        self.intent = intent
        self.isAppStoreAttemptingToRenew = iar
    }
    
}

public extension InAppPurchaseReceipt.Subscription.PeriodKind {
    
    init?(isFreeTrial: Bool?, isIntroductoryPrice: Bool?) {
        guard let free = isFreeTrial, let intro = isIntroductoryPrice else { return nil }
        if free {
            self = .freeTrial
        } else if intro {
            self = .introductoryPrice
        } else {
            self = .normal
        }
    }
    
}

public extension InAppPurchaseReceipt.Subscription.Cancellation {
    
    init?(cancellationDateRFC3339 dateString: String?, cancellationReason: Int?) {
        guard let string = dateString, let date = try? Date.from(RFC3339: string), let cr = cancellationReason, let reason = Reason(rawValue: cr) else { return nil }
        self.date = date
        self.reason = reason
    }
    
}


// MARK: - Decoding keys
public extension InAppPurchaseReceipt {

    private typealias JSONKeys = Keys
    
    enum Keys: String, CodingKey, CaseIterable {
        case quantity = "quantity"
        case productIdentifier =  "product_id"
        case transactionIdentifier = "transaction_id"
        case originalTransactionIdentifier = "original_transaction_id"
        case purchaseDate = "purchase_date"
        case originalPurchaseDate = "original_purchase_date"
        case subscriptionExpirationDate = "expires_date"
        case subscriptionExpirationIntent = "expiration_intent"
        case isAppStoreAttemptingToRenew = "is_in_billing_retry_period"
        case isTrialPeriod = "is_trial_period"
        case isIntroductoryPeriod = "is_in_intro_offer_period"
        case cancellationDate = "cancellation_date"
        case cancellationReason = "cancellation_reason"
        case appItemId = "app_item_id"
        case externalVersionIdentifier = "version_external_identifier"
        case webOrderLineItem =  "web_order_line_item_id"
        case subscriptionAutoRenew = "auto_renew_status"
        case subscriptionAutoRenewPreference = "auto_renew_product_id"
        case priceConsent = "price_consent_status"
        
        public init?(asn1Field number: Int) {
            for n in Keys.allCases {
                guard n.asn1FieldTypeNumber == number else { continue }
                self = n
            }
            return nil
        }
        
        public var asn1FieldTypeNumber: Int? {
            switch self {
            case .quantity: return 1701
            case .productIdentifier: return 1702
            case .transactionIdentifier: return 1703
            case .originalTransactionIdentifier: return 1705
            case .purchaseDate: return 1704
            case .originalPurchaseDate: return 1706
            case .subscriptionExpirationDate: return 1708
            case .webOrderLineItem: return 1711
            case .cancellationDate: return 1712
            case .isIntroductoryPeriod: return 1719
            default: return nil
            }
        }
        
    }
    
}


// MARK: - Date helper
extension Date {
    
    enum RFC3339Error: Error {
        case malformedDateString
    }
    
    static func from(RFC3339 string: String) throws -> Date {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        guard let date = formatter.date(from: string) else { throw RFC3339Error.malformedDateString }
        return date
    }
    
}
