//
//  ReceiptValidating.swift
//  
//
//  Created by Neil Smith on 01/12/2019.
//

import Foundation

protocol ReceiptValidating {
    init(_ strategy: ReceiptValidationStrategy, localValidator: ReceiptValidatingLocally?, remoteValidator: ReceiptValidatingRemotely?)
    func validate(receipt data: Data, completion: @escaping (ReceiptValidationResult) -> Void)
}


