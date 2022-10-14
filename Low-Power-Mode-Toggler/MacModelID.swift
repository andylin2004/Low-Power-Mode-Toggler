//
//  MacModelID.swift
//  Low Power Mode Toggler
//
//  Created by Andy Lin on 10/13/22.
//

import IOKit
import Foundation

func getModelIdentifier() -> String? {
    let service = IOServiceGetMatchingService(kIOMainPortDefault,
                                              IOServiceMatching("IOPlatformExpertDevice"))
    var modelIdentifier: String?
    if let modelData = IORegistryEntryCreateCFProperty(service, "model" as CFString, kCFAllocatorDefault, 0).takeRetainedValue() as? Data {
        modelIdentifier = String(data: modelData, encoding: .utf8)?.trimmingCharacters(in: .controlCharacters)
    }

    IOObjectRelease(service)
    return modelIdentifier
}

func lowPowerModeSupported() -> Bool {
    if let identifier = getModelIdentifier() {
        let range = NSRange(identifier.startIndex..<identifier.endIndex, in: identifier)
        
        let capturePattern = #"(?<model>[A-Za-z]+)"# + #"(?<majorNumber>\d+)"# + "," + #"(?<minorNumber>\d+)"#
        
        let regex = try! NSRegularExpression(pattern: capturePattern)
        
        let matches = regex.matches(in: identifier, range: range)
        
        guard let match = matches.first else {
            return false
        }
        
        var captures: [String: String] = [:]
        
        for property in ["model", "majorNumber", "minorNumber"] {
            let matchRange = match.range(withName: property)
            if let substringRange = Range(matchRange, in: identifier) {
                let capture = String(identifier[substringRange])
                captures[property] = capture
            }
        }
        
        if let majorNumber = Int(captures["majorNumber"] ?? "0") {
            switch captures["model"]{
            case "MacBook":
                return majorNumber >= 9
            case "MacBookPro":
                return majorNumber >= 13
            case "MacBookAir":
                return majorNumber >= 8
            case "Mac":
                if let minorNumber = Int(captures["minorNumber"] ?? "0") {
                    return majorNumber == 14 && (minorNumber == 2 || minorNumber == 7)
                }else{
                    return false
                }
            default:
                return false
            }
        }
    }
    return false
}