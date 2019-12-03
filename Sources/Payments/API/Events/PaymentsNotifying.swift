//
//  PaymentsNotifying.swift
//  
//
//  Created by Neil Smith on 28/11/2019.
//

import Foundation

public protocol PaymentsNotifying {
    associatedtype Content
    var content: Content { get set }
    static var kind: Payments.EventKind { get }
    init(_ content: Content)
}

public extension PaymentsNotifying {
    init?(_ notification: Notification) {
        guard let content = notification.userInfo?[Self.key] as? Content else { return nil }
        self.init(content)
    }
    static var notification: Notification.Name { kind.notification }
}


extension PaymentsNotifying {
    static var key: String { kind.userInfoKey }
    static func notify(with content: Content) {
        NotificationCenter.default.post(
            name: Self.notification,
            object: nil,
            userInfo: [Self.key : content]
        )
    }
}

