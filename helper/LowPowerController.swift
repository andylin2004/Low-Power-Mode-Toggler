//
//  LowPowerController.swift
//  helper
//
//  Created by Andy Lin on 6/18/22.
//

import Foundation
import Blessed

enum AllowedCommandError: Error {
    case authorizationMissing
    case authorizationFailed
}

struct LowPowerController{
    private init(){}
    
    static let authorizationRight = AuthorizationRight(name: "com.andylin.Low-Power-Mode-Toggler.switch-action")
    
    static func changePowerMode(lowPowerEnabled: Bool) throws {
        do{
            let rights = try Authorization().requestRights([authorizationRight], environment: [], options: [.preAuthorize])
            if !rights.contains(where: { $0.name == authorizationRight.name }) {
                throw AllowedCommandError.authorizationFailed
            }
            let process = Process()
            process.executableURL = URL("/usr/bin/pmset")
            process.arguments = ["-a", "lowpowermode", lowPowerEnabled ? "1" : "0"]
            process.launch()
            process.waitUntilExit()
        }catch{
            throw AllowedCommandError.authorizationMissing
        }
    }
}
