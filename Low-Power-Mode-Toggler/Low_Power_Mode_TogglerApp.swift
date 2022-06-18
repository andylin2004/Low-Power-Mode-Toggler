//
//  Low_Power_Mode_TogglerApp.swift
//  Low-Power-Mode-Toggler
//
//  Created by Andy Lin on 6/15/22.
//

import SwiftUI
import Foundation
import IOKit.ps
import SecureXPC

@main
struct Low_Power_Mode_TogglerApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate
    
    var body: some Scene {
//        Settings {
//            EmptyView()
//        }
        WindowGroup{
            InstallView()
        }
    }
}

class AppDelegate: NSObject, NSApplicationDelegate {
    private var statusItem: NSStatusItem!
    let menu = NSMenu()
    let menuItem = NSMenuItem()
    let xpcClient = XPCClient.forMachService(named: "com.andylin.Low-Power-Mode-Toggler.helper")
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        let view = NSHostingView(rootView: ContentView(xpcClient: xpcClient))
        
        view.frame = NSRect(x: 0, y: 0, width: 250, height: 200)
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        menuItem.view = view
        menu.addItem(menuItem)
        statusItem.menu = menu
        NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        
        updateBatteryInBar()
        
        NotificationCenter.default.addObserver(self, selector: #selector(powerSourceUpdate(_:)), name: Notification.Name(rawValue: "com.andylin.powerSourceChangedNotif"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(powerSourceUpdate(_:)), name: Notification.Name(rawValue: "com.andylin.powerSourceChangedNotif"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(powerSourceUpdate(_:)), name: NSNotification.Name.NSProcessInfoPowerStateDidChange, object: nil)
    }
    
    @objc public func powerSourceUpdate(_: AnyObject){
        DispatchQueue.main.async {
            self.updateBatteryInBar()
        }
    }
    
    func updateBatteryInBar(){
        let internalFinder = InternalFinder();
        if let internalBattery = internalFinder.getInternalBattery(){
            if ProcessInfo.processInfo.isLowPowerModeEnabled{
                let attributes = [NSAttributedString.Key.font: NSFont.systemFont(ofSize: 11), NSAttributedString.Key.foregroundColor: NSColor.systemYellow]
                let str = NSAttributedString(string: "\(Int(internalBattery.charge ?? 0))%", attributes: attributes)
                statusItem.button?.attributedTitle = str
                if internalBattery.charge ?? 0 >= 80 {
//                    toggleLowPowerMode(isLowPowerEnabled: false)
                }
            }else{
                let attributes = [NSAttributedString.Key.font: NSFont.systemFont(ofSize: 11)]
                let str = NSAttributedString(string: "\(Int(internalBattery.charge ?? 0))%", attributes: attributes)
                statusItem.button?.attributedTitle = str
                if internalBattery.charge ?? 0 <= 20 {
//                    toggleLowPowerMode(isLowPowerEnabled: true)
                }
            }
        }else{
            let attributes = [NSAttributedString.Key.font: NSFont.systemFont(ofSize: 11)]
            let str = NSAttributedString(string: "No Battery", attributes: attributes)
            statusItem.button?.attributedTitle = str
        }
    }
}
