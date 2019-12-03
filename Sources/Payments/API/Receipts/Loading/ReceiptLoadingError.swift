//
//  ReceiptLoadingError.swift
//  
//
//  Created by Neil Smith on 03/12/2019.
//

import Foundation

public enum ReceiptLoadingError: Error {
    case missingAtURL
    case unreachableAtURL
    case error(Error)
}
