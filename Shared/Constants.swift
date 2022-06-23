//
//  Constants.swift
//  helper
//
//  Created by Andy Lin on 6/18/22.
//

import Foundation
import SecureXPC
import Authorized

struct Constants {
    static let changePowerMode = XPCRoute.named("changePowerMode")
        .withMessageType(LowPowerModeUpdate.self)
}

struct LowPowerModeUpdate: Encodable, Decodable {
    let lowPowerEnabled: Bool
    let authorization: Authorization
}
