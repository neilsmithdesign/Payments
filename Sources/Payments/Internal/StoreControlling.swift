//
//  StoreControlling.swift
//  
//
//  Created by Neil Smith on 29/11/2019.
//

import StoreKit

protocol StoreControlling {
    var productIdentifiers: Set<ProductIdentifier> { get }
    var canMakePayments: Bool { get }
    func loadProducts(_ completion: @escaping (LoadedProductsResult) -> Void)
    func purchase(_ product: Product, completion: @escaping (PaymentResult) -> Void)
    func restorePurchases(_ completion: @escaping (PaymentResult) -> Void)
}
