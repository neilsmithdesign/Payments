//
//  File.swift
//  
//
//  Created by Neil Smith on 30/11/2019.
//

import Foundation

public enum PaymentResult {
    case success(ProductIdentifier)
    case failure(Error?)
    case restored(ProductIdentifier)
    case deferred(ProductIdentifier)
}
