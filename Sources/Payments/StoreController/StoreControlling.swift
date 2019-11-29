//
//  File.swift
//  
//
//  Created by Neil Smith on 29/11/2019.
//

import StoreKit

public protocol StoreControlling {
    var productIdentifiers: Set<ProductIdentifier> { get }
    var canMakePayments: Bool { get }
    func loadProducts(_ completion: @escaping (LoadedProductsResult) -> Void)
    func purchase(product: Product, simulateAskToBuy: Bool, completion: @escaping (PaymentResult) -> Void)
    func restorePurchases(_ completion: @escaping (PaymentResult) -> Void)
}


public typealias LoadedProductsResult = Result<Set<Product>, Error>
public enum PaymentResult {
    case success(ProductIdentifier)
    case failure(Error?)
    case restored(ProductIdentifier)
    case deferred(ProductIdentifier)
}
