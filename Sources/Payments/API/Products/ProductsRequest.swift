//
//  ProductsRequest.swift
//  
//
//  Created by Neil Smith on 03/12/2019.
//

import StoreKit

public protocol ProductsRequest {
    var delegate: SKProductsRequestDelegate? { get set }
    func start()
}

extension SKProductsRequest: ProductsRequest {}
