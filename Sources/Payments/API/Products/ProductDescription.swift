//
//  ProductDescription.swift
//  
//
//  Created by Neil Smith on 03/12/2019.
//

import Foundation

protocol ProductDescription: Hashable {
    var title: String { get }
    var description: String { get }
    var price: String { get }
    var numericalPrice: NSDecimalNumber { get }
    var identifier: String { get }
}
