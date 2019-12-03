//
//  Product.swift
//  
//
//  Created by Neil Smith on 26/08/2019.
//

import Foundation

public class Product: ProductDescription {
    
    public var title: String
    public var description: String
    public var price: String
    public var numericalPrice: NSDecimalNumber
    public var identifier: String
    
    init(title: String, description: String, price: String, numericalPrice: NSDecimalNumber, identifier: String) {
        self.title = title
        self.description = description
        self.price = price
        self.numericalPrice = numericalPrice
        self.identifier = identifier
    }

}

extension Product: Hashable {
    
    public static func == (lhs: Product, rhs: Product) -> Bool {
        return lhs.identifier == rhs.identifier
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(identifier)
    }
    
}
