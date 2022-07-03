//
//  Constants.swift
//  helper
//
//  Created by Andy Lin on 6/18/22.
//

import Foundation
import SecureXPC
import Blessed

struct Constants {
    static let changePowerMode = XPCRoute.named("changePowerMode")
        .withMessageType(LowPowerModeUpdate.self)
    
    static let uninstall = XPCRoute.named("uninstall")
    
    static let update = XPCRoute.named("update")
        .withMessageType(URL.self)
}

struct LowPowerModeUpdate: Codable {
    let lowPowerEnabled: Bool
    let authorization: Authorization
}
