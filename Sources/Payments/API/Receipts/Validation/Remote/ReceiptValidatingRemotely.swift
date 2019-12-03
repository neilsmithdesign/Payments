//
//  ReceiptValidatingRemotely.swift
//  
//
//  Created by Neil Smith on 02/12/2019.
//

import Foundation

public protocol ReceiptValidatingRemotely {
    init(url: URL)
    func validate(receipt data: Data, completion: @escaping (ReceiptValidationResult) -> Void)
}
