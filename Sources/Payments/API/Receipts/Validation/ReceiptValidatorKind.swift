//
//  File.swift
//  
//
//  Created by Neil Smith on 02/12/2019.
//

import Foundation

public enum ReceiptValidatorKind {
    case local(ReceiptValidatingLocally)
    case remote(ReceiptValidatingRemotely)
}
