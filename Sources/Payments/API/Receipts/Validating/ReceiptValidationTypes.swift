//
//  ReceiptValidationTypes.swift
//  
//
//  Created by Neil Smith on 02/12/2019.
//

import Foundation

typealias ReceiptContainer = UnsafeMutablePointer<PKCS7>
typealias VerifiedSignature = UnsafeMutablePointer<X509>
typealias AuthenticatedSignature = VerifiedSignature
