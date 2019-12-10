//
//  ReceiptLoading.swift
//  
//
//  Created by Neil Smith on 01/12/2019.
//

import Foundation

protocol ReceiptLoading {
    init(location: ReceiptLocation)
    func load(using fileInspector: FileInspector, completion: @escaping (ReceiptLoadingResult) -> Void)
}
