//
//  ReceiptError.swift
//  
//
//  Created by Neil Smith on 03/12/2019.
//

import Foundation

public enum ReceiptError: Error {
    case loading(ReceiptLoadingError)
    case validation(ReceiptValidationError)
}
