//
//  RemoteReceiptValidationError.swift
//  
//
//  Created by Neil Smith on 02/12/2019.
//

import Foundation

enum RemoteReceiptValidationError: Error {
    case attemptToCallAppStoreEndPointFromClientDevice
    case serverError(Error)
    case missingResponse
    case missingData
    case malformedData
    case unexpectedResponse(code: Int)
    case other(Error?)
}
