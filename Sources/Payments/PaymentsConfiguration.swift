//
//  PaymentsConfiguration.swift
//  
//
//  Created by Neil Smith on 26/08/2019.
//

import Foundation

public extension Payments {
    
    struct Configuration {
        
        let mode: Mode
        let productIdentifiers: Set<String>
        let simulatesAskToBuyInSandbox: Bool
        
        public init(mode: Mode, productIdentifiers: Set<String>, simulatesAskToBuyInSandbox: Bool = false) {
            self.mode = mode
            self.productIdentifiers = productIdentifiers
            self.simulatesAskToBuyInSandbox = simulatesAskToBuyInSandbox
        }
        
        public enum Mode {
            case sandbox
            case production
        }
    }
    
}
