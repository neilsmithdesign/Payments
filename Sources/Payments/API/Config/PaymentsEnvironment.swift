//
//  PaymentsEnvironment.swift
//  
//
//  Created by Neil Smith on 29/11/2019.
//

import Foundation

public extension Payments {
        
    enum Environment {
        case sandbox(simulateAskToBuy: Bool)
        case production
    }
    
}
