//
//  MockReceiptLoader.swift
//  
//
//  Created by Neil Smith on 03/12/2019.
//

import Foundation

struct MockReceiptLoader: ReceiptLoading {
    
    init(location: ReceiptLocation = Bundle.main) {}
    
    func load(using fileInspector: FileInspector, completion: @escaping (ReceiptLoadingResult) -> Void) {
        completion(.success(Data()))
    }
    
}
