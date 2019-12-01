//
//  PaymentsConfiguration.swift
//  
//
//  Created by Neil Smith on 26/08/2019.
//

import Foundation

public protocol PaymentsConfiguring {
    var productIdentifiers: Set<ProductIdentifier> { get }
    var simulateAskToBuy: Bool { get }
    var bundle: Bundle { get }
}
