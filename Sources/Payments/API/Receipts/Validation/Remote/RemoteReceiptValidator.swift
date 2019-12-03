//
//  RemoteAppStoreReceiptValidator.swift
//  
//
//  Created by Neil Smith on 02/12/2019.
//

import Foundation

struct RemoteReceiptValidator: ReceiptValidatingRemotely {
    
    private let url: URL
    
    init(url: URL) {
        let sandboxURL = URL(string: "https://sandbox.itunes.apple.com/verifyReceipt")!
        let productionURL = URL(string: "https://buy.itunes.apple.com/verifyReceipt")!
        guard url != sandboxURL && url != productionURL else {
            preconditionFailure("App Store receipt verification end point used directly from device. This approach is subject to man-in-the-middle attacks.")
        }
        self.url = url
    }
    
    func validate(receipt data: Data, completion: @escaping (ReceiptValidationResult) -> Void) {
        let encodedData = data.base64EncodedData()
        var request = URLRequest(url: url)
        request.httpBody = encodedData
        request.httpMethod = "POST"
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            if let err = error {
                completion(.failure(.remote(.serverError(err))))
                return
            }
            guard let r = response as? HTTPURLResponse else {
                completion(.failure(.remote(.missingResponse)))
                return
            }
            guard r.statusCode >= 200 && r.statusCode < 300 else {
                completion(.failure(.remote(.unexpectedResponse(code: r.statusCode))))
                return
            }
            guard let d = data else {
                completion(.failure(.remote(.missingData)))
                return
            }
            do {
                let receipt = try JSONDecoder().decode(AppStoreReceipt.self, from: d)
                completion(.success(receipt))
            } catch {
                completion(.failure(.remote(.malformedData)))
            }
        }
        task.resume()
    }
    
    
}
