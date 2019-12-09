//
//  AppStoreReceiptLoader.swift
//  
//
//  Created by Neil Smith on 01/12/2019.
//

import StoreKit

final class AppStoreReceiptLoader: NSObject, ReceiptLoading {
    
    
    // MARK: Receipt Loading
    init(location: ReceiptLocation) {
        self.location = location
        self.refreshAttempts = 0
        super.init()
    }
    
    func load(using fileInspector: FileInspector = FileManager.default, completion: @escaping (ReceiptLoadingResult) -> Void) {
        if let url = location.appStoreReceiptURL {
            guard fileInspector.fileExists(atPath: url.path) else {
                if refreshAttempts < 1 {
                    self.completionHandler = completion
                    refreshRequest.start()
                    refreshAttempts += 1
                } else {
                    completion(.failure(.unreachableAtURL))                    
                }
                return
            }
            do {
                let data = try Data(contentsOf: url)
                completion(.success(data))
            } catch {
                completion(.failure(.error(error)))
            }
        } else if refreshAttempts < 1 {
            self.completionHandler = completion
            refreshRequest.start()
            refreshAttempts += 1
        } else {
            completion(.failure(.missingAtURL))
        }
    }
    
    
    
    // MARK: Private
    private let location: ReceiptLocation
    
    private var completionHandler: ((ReceiptLoadingResult) -> Void)?
    
    private lazy var refreshRequest: SKReceiptRefreshRequest = {
        let req = SKReceiptRefreshRequest()
        req.delegate = self
        return req
    }()
    
    private var refreshAttempts: Int

}

extension AppStoreReceiptLoader: SKRequestDelegate {
    
    func requestDidFinish(_ request: SKRequest) {
        guard request is SKReceiptRefreshRequest, let completion = self.completionHandler else { return }
        self.load(completion: completion)
    }
    
}

extension FileManager: FileInspector {}
extension Bundle: ReceiptLocation {}
