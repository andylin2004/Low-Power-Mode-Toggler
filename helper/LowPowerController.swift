//
//  LowPowerController.swift
//  helper
//
//  Created by Andy Lin on 6/18/22.
//

import Foundation
import Blessed
import Authorized

enum AllowedCommandError: Error {
    case authorizationMissing
    case authorizationFailed
}

struct LowPowerController{
    private init(){}
    
    static let authorizationRight = AuthorizationRight(name: "com.andylin.Low-Power-Mode-Toggler.switch-action")
    
    static func changePowerMode(lowPowerUpdate: LowPowerModeUpdate) throws {
        do{
            let rights = try lowPowerUpdate.authorization.requestRights([authorizationRight], environment: [], options: [.preAuthorize, .interactionAllowed, .extendRights])
            if !rights.contains(where: { $0.name == authorizationRight.name }) {
                throw AllowedCommandError.authorizationFailed
            }
            let process = Process()
            process.executableURL = URL("/usr/bin/pmset")
            process.arguments = ["-a", "lowpowermode", lowPowerUpdate.lowPowerEnabled ? "1" : "0"]
            process.qualityOfService = .userInitiated
            let stdout = Pipe()
            process.standardOutput = stdout
            let stderr = Pipe()
            process.standardError = stderr
            process.launch()
            process.waitUntilExit()
        }catch{
            throw AllowedCommandError.authorizationMissing
        }
    }
}
