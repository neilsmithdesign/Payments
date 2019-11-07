//
//  File.swift
//  
//
//  Created by Neil Smith on 27/08/2019.
//

import Foundation
import StoreKit

public extension Payments {
    
    enum Notification {}
    
}


public extension Payments.Notification {
    
    
    // MARK: - Loaded
    struct LoadedProducts {
        
        public let products: Set<Product>
        
        public init?(_ notification: Notification) {
            guard let products = notification.userInfo?[LoadedProducts.key] as? Set<Product> else { return nil }
            self.products = products
        }

        public static var notification: Notification.Name {
            return .init("com.NeilSmithDesignLTD.payments.did.load.products")
        }
        public static var key: String {
            return notification.rawValue + ".user.info.key"
        }
        static func notify(with products: Set<Product>) {
            NotificationCenter.default.post(
                name: Payments.Notification.LoadedProducts.notification,
                object: nil,
                userInfo: [LoadedProducts.key : products]
            )
        }
        
    }
    
    
    // MARK: - Cannot make
    enum CannotMakePayments {
        
        public static var notification: Notification.Name {
            return .init("com.NeilSmithDesignLTD.payments.cannot.make.payments")
        }
        
        static func notify() {
            NotificationCenter.default.post(name: notification, object: nil)
        }
        
    }
    
    enum Payment {
        
        
        // MARK: - Complete
        public struct Complete {
            
            public let productIdentifier: String
            
            public init?(_ notification: Notification) {
                guard let id = notification.userInfo?[Complete.key] as? String else { return nil }
                self.productIdentifier = id
            }
            
            public static var notification: Notification.Name {
                return .init("com.NeilSmithDesignLTD.payments.payment.complete")
            }
            
            public static var key: String {
                return notification.rawValue + ".user.info.key"
            }
            
            static func notify(for productIdentifier: String) {
                NotificationCenter.default.post(
                    name: notification,
                    object: nil,
                    userInfo: [Complete.key : productIdentifier]
                )
            }
        }
        
        
        // MARK: - Restored
        public struct Restored {
            
            public let productIdentifier: String
            
            public init?(_ notification: Notification) {
                guard let id = notification.userInfo?[Restored.key] as? String else { return nil }
                self.productIdentifier = id
            }
            
            public static var notification: Notification.Name {
                return .init("com.NeilSmithDesignLTD.payments.payment.restored")
            }
            
            public static var key: String {
                return notification.rawValue + ".user.info.key"
            }
            
            static func notify(for productIdentifier: String) {
                NotificationCenter.default.post(
                    name: notification,
                    object: nil,
                    userInfo: [Restored.key : productIdentifier]
                )
            }
        }
    
    
        // MARK: - Deferred
        public struct Deferred {
            
            public let alert: Payments.Alert
            public let productIdentifier: String
            
            public init?(_ notification: Notification) {
                guard
                    let title = notification.userInfo?[Deferred.titleKey] as? String,
                    let message = notification.userInfo?[Deferred.messageKey] as? String,
                    let id = notification.userInfo?[Deferred.identifierKey] as? String
                else { return nil }
                self.alert = .init(title: title, message: message)
                self.productIdentifier = id
            }
            
            public static var notification: Notification.Name {
                return .init("com.NeilSmithDesignLTD.payments.payment.deferred")
            }
            
            public static var titleKey: String {
                return notification.rawValue + ".user.info.key.title"
            }
            public static var messageKey: String {
                return notification.rawValue + ".user.info.key.message"
            }
            public static var identifierKey: String {
                return notification.rawValue + ".user.info.key.identifier"
            }
            
            static func notify(for productIdentifier: String) {
                NotificationCenter.default.post(
                    name: notification,
                    object: nil,
                    userInfo: [
                        Deferred.titleKey : Payments.Alert.deferredAlert.title!,
                        Deferred.messageKey : Payments.Alert.deferredAlert.message!,
                        Deferred.identifierKey : productIdentifier
                    ]
                )
            }
            
        }
        
        
        // MARK: - Failed
        public struct Failed {
            
            public let error: SKError
            
            
            public init?(_ notification: Notification) {
                guard let error = notification.userInfo?[Failed.key] as? SKError else { return nil }
                self.error = error
            }
            
            public static var notification: Notification.Name {
                return .init("com.NeilSmithDesignLTD.payments.payment.failed")
            }
            
            public static var key: String {
                return notification.rawValue + ".user.info.key"
            }
            
            static func notify(for error: SKError) {
                NotificationCenter.default.post(
                    name: notification,
                    object: nil,
                    userInfo: [Failed.key : error]
                )
            }
            
        }
        
    }
    
}

