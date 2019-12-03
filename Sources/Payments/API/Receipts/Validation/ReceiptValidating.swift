//
//  ReceiptValidating.swift
//  
//
//  Created by Neil Smith on 01/12/2019.
//

import Foundation

public protocol ReceiptValidating {
    func validate(receipt data: Data, completion: @escaping (ReceiptValidationResult) -> Void)
}


