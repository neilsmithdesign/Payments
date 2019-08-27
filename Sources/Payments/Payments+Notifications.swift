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
        static var key: String {
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
            
            static var key: String {
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
            
            static var key: String {
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
            
            public init?(_ notification: Notification) {
                guard
                    let title = notification.userInfo?[Deferred.titleKey] as? String,
                    let message = notification.userInfo?[Deferred.messageKey] as? String
                else { return nil }
                self.alert = .init(title: title, message: message)
            }
            
            public static var notification: Notification.Name {
                return .init("com.NeilSmithDesignLTD.payments.payment.deferred")
            }
            
            static var titleKey: String {
                return notification.rawValue + ".user.info.key.title"
            }
            static var messageKey: String {
                return notification.rawValue + ".user.info.key.message"
            }
            
            static func notify() {
                NotificationCenter.default.post(
                    name: notification,
                    object: nil,
                    userInfo: [
                        Deferred.titleKey : Payments.Alert.deferredAlert.title!,
                        Deferred.messageKey : Payments.Alert.deferredAlert.message!
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
            
            static var key: String {
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

