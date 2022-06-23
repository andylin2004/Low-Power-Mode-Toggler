//
//  main.swift
//  helper
//
//  Created by Andy Lin on 6/18/22.
//

import Foundation
import SecureXPC

if getppid() == 1 {
    let server = try XPCServer.forThisBlessedHelperTool()
    server.registerRoute(Constants.changePowerMode, handler: LowPowerController.changePowerMode(lowPowerUpdate:))
    server.setErrorHandler { error in
        if case .connectionInvalid = error {
            // this is when client disconnects, which is fine
        } else {
            NSLog("error: \(error)")
        }
    }
    server.startAndBlock()
}
