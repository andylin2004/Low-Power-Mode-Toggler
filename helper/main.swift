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
    server.registerRoute(<#T##route: XPCRouteWithoutMessageWithoutReply##XPCRouteWithoutMessageWithoutReply#>, handler: <#T##() throws -> Void#>)
}
