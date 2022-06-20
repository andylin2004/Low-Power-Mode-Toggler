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
    
    static func changePowerMode(lowPowerEnabled: Bool) throws -> String {
        do{
            let rights = try Authorization().requestRights([authorizationRight], environment: [], options: [.preAuthorize])
            if !rights.contains(where: { $0.name == authorizationRight.name }) {
                throw AllowedCommandError.authorizationFailed
            }
            let process = Process()
            process.executableURL = URL("/usr/bin/pmset")
            process.arguments = ["-a", "lowpowermode", lowPowerEnabled ? "1" : "0"]
            process.qualityOfService = .userInitiated
            let stdout = Pipe()
            process.standardOutput = stdout
            let stderr = Pipe()
            process.standardError = stderr
            process.launch()
            process.waitUntilExit()
            
            let terminationStatus = Int64(process.terminationStatus)
            var standardOutput: String?
            var standardError: String?
            if let output = String(data: stdout.fileHandleForReading.availableData,
                                   encoding: String.Encoding.utf8)?.trimmingCharacters(in: .whitespacesAndNewlines),
               output.count != 0 {
                standardOutput = output
            }
            if let error = String(data: stderr.fileHandleForReading.availableData,
                                  encoding: String.Encoding.utf8)?.trimmingCharacters(in: .whitespacesAndNewlines),
               error.count != 0 {
                standardError = error
            }
            stdout.fileHandleForReading.closeFile()
            stderr.fileHandleForReading.closeFile()
            
            return standardOutput ?? ""
        }catch{
            throw AllowedCommandError.authorizationMissing
        }
    }
}
