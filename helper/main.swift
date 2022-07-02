//
//  main.swift
//  helper
//
//  Created by Andy Lin on 6/18/22.
//

import Foundation
import SecureXPC

if CommandLine.arguments.count > 1 {
    // Remove the first argument, which represents the name (typically the full path) of this helper tool
    var arguments = CommandLine.arguments
    _ = arguments.removeFirst()
    
    if let firstArgument = arguments.first {
        if firstArgument == "uninstall" {
            try Uninstaller.uninstallFromCommandLine(withArguments: arguments)
        } else {
            NSLog("argument not recognized: \(firstArgument)")
        }
    }
} else if getppid() == 1 {
    let server = try XPCServer.forThisBlessedHelperTool()
    server.registerRoute(Constants.changePowerMode, handler: LowPowerController.changePowerMode(lowPowerUpdate:))
    server.registerRoute(Constants.uninstall, handler: Uninstaller.uninstallFromXPC)
    server.setErrorHandler { error in
        if case .connectionInvalid = error {
            // this is when client disconnects, which is fine
        } else {
            NSLog("error: \(error)")
        }
    }
    server.startAndBlock()
}
