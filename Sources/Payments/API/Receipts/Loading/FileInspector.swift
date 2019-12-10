//
//  FileInspector.swift
//  
//
//  Created by Neil Smith on 10/12/2019.
//

import Foundation

public protocol FileInspector {
    func fileExists(atPath path: String) -> Bool
}
