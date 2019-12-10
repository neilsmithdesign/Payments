//
//  PaymentDeferredAlert.swift
//  
//
//  Created by Neil Smith on 10/12/2019.
//

import Foundation

public struct PaymentDeferredAlert {
    
    public let title: String
    public let message: String
    public let productIdentifier: String
    
    static func standardMessage(productIdentifier: String) -> PaymentDeferredAlert {
        return .init(
            title: "Waiting For Approval",
            message: "Thank you! You can continue to use the app whilst your purchase is pending approval from your family organizer.",
            productIdentifier: productIdentifier
        )
    }
    
}
