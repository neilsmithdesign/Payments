//
//  ReceiptLoading.swift
//  
//
//  Created by Neil Smith on 01/12/2019.
//

import Foundation

/// Interface for loading receipts.
/// Use concrete implementation of "AppStoreReceiptLoader"
/// for loading App Store receipts
public protocol ReceiptLoading {
    init(location: ReceiptLocation)
    func load(using fileInspector: FileInspector, completion: @escaping (ReceiptLoadingResult) -> Void)
}


public typealias ReceiptLoadingResult = Result<Data, ReceiptLoadingError>


public enum ReceiptLoadingError: Error {
    case loaded(Data)
    case missingAtURL
    case unreachableAtURL
    case error(Error)
}


public protocol FileInspector {
    func fileExists(atPath path: String) -> Bool
}

public protocol ReceiptLocation {
    var appStoreReceiptURL: URL? { get }
}
