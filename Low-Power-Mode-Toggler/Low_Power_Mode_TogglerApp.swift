//
//  Low_Power_Mode_TogglerApp.swift
//  Low-Power-Mode-Toggler
//
//  Created by Andy Lin on 6/15/22.
//

import SwiftUI
import Foundation
import IOKit.ps
import AppKit

@main
struct Low_Power_Mode_TogglerApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}

class AppDelegate: NSObject, NSApplicationDelegate {
    private var statusItem: NSStatusItem!
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        let attribute = [NSAttributedString.Key.font: NSFont.systemFont(ofSize: 11)]
        let internalFinder = InternalFinder();
        if let internalBattery = internalFinder.getInternalBattery(){
            let str = NSAttributedString(string: "\(Int(internalBattery.charge!))%", attributes: attribute)
            statusItem.button?.attributedTitle = str
        }else{
            let str = NSAttributedString(string: "No Battery", attributes: attribute)
            statusItem.button?.attributedTitle = str
        }
    }
}
