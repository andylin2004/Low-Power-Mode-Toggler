//
//  Low_Power_Mode_TogglerApp.swift
//  Low-Power-Mode-Toggler
//
//  Created by Andy Lin on 6/15/22.
//

import SwiftUI
import Foundation
import IOKit.ps
import IOKit
import AppKit

@main
struct Low_Power_Mode_TogglerApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate
    
    var body: some Scene {
        Settings {
            EmptyView()
        }
    }
}

class AppDelegate: NSObject, NSApplicationDelegate {
    private var statusItem: NSStatusItem!
    let view = NSHostingView(rootView: ContentView())
    let menu = NSMenu()
    let menuItem = NSMenuItem()
    
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        view.frame = NSRect(x: 0, y: 0, width: 200, height: 200)
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        menuItem.view = view
        menu.addItem(menuItem)
        statusItem.menu = menu
        NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
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
    
//    func application
}
