//
//  ReceiptValidationError.swift
//  
//
//  Created by Neil Smith on 02/12/2019.
//

import Foundation

public enum ReceiptValidationError: Error {
    case local(LocalReceiptValidationError)
    case remote(RemoteReceiptValidationError)
}
