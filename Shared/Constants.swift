//
//  Constants.swift
//  helper
//
//  Created by Andy Lin on 6/18/22.
//

import Foundation
import SecureXPC

struct Constants {
    static let changePowerMode = XPCRoute.named("changePowerMode")
        .withMessageType(Bool.self)
        .withReplyType(String.self)
}
