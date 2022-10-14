//
//  ShortcutInteraction.swift
//  Low Power Mode Toggler
//
//  Created by Andy Lin on 10/14/22.
//

import Foundation

func isShortcutInstalled() -> Bool {
    let process = Process()
    process.executableURL = URL("/usr/bin/shortcuts")
    process.arguments = ["list"]
    process.qualityOfService = .userInteractive
    let stdout = Pipe()
    process.standardOutput = stdout
    let stderr = Pipe()
    process.standardError = stderr
    process.launch()
    process.waitUntilExit()
    return String(data: stdout.fileHandleForReading.availableData, encoding: .utf8)?.contains("PowerToggler") ?? false
}
