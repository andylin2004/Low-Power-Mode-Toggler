//
//  Uninstall.swift
//  Low-Power-Mode-Toggler
//
//  Created by Andy Lin on 7/2/22.
//

import Foundation

struct Uninstaller {
    
    enum UninstallError: Error {
        /// Uninstall will not be performed because this code is not running from the blessed location.
        case notRunningFromBlessedLocation
        /// Attempting to unload using `launchctl` failed.
        ///
        /// The associated value is the underlying status code.
        case launchctlFailure(Int32)
        /// The argument provided must be a process identifier, but was not.
        case notProcessId
    }
    
    static func uninstallFromXPC() throws {
        let process = Process()
        process.executableURL = URL("/Library/PrivilegedHelperTools/com.andylin.Low-Power-Mode-Toggler.helper")
        process.qualityOfService = .utility
        process.arguments = ["uninstall", String(getpid())]
        process.launch()
        exit(0)
    }
    
    static func uninstallFromCommandLine(withArguments args: [String]) throws {
        if args.count == 1 {
            try uninstallImmediately()
        }else{
            guard let pid: pid_t = Int32(args[1]) else{
                throw UninstallError.notProcessId
            }
            try uninstallAfterProcessExits(pid: pid)
        }
    }
    
    private static func uninstallAfterProcessExits(pid: pid_t) throws {
        while kill(pid, 0) == 0 {
            NSLog("Still waiting for process to exit")
            usleep(50 * 1000)
        }
        NSLog("Process exited; time to uninstall")
        try uninstallImmediately()
    }
    
    private static func uninstallImmediately() throws{
        let process = Process()
        process.executableURL = URL("/bin/launchctl")
        process.qualityOfService = .utility
        process.arguments = ["unload", "/Library/PrivilegedHelperTools/com.andylin.Low-Power-Mode-Toggler.helper"]
        process.launch()
        NSLog("about to wait for launchctl")
        process.waitUntilExit()
        let terminationStatus = process.terminationStatus
        if terminationStatus == 0 {
            NSLog("unloaded from launchctl")
        } else {
            throw UninstallError.launchctlFailure(terminationStatus)
        }
        
        try FileManager.default.removeItem(at: URL("/Library/LaunchDaemons/com.andylin.Low-Power-Mode-Toggler.helper.plist")!)
        NSLog("property list deleted")
        
        try FileManager.default.removeItem(at: URL("/Library/PrivilegedHelperTools/com.andylin.Low-Power-Mode-Toggler.helper")!)
        NSLog("helper tool deleted")
        NSLog("uninstall completed, exiting...")
        exit(0)
    }
}
