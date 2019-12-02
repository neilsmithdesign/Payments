//
//  ReceiptValidatingRemotely.swift
//  
//
//  Created by Neil Smith on 02/12/2019.
//

import Foundation

protocol ReceiptValidatingRemotely {
    init(url: URL) throws
    func validate(receipt data: Data, completion: @escaping (ReceiptValidationResult) -> Void)
}
