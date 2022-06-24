//
//  Low_Power_Mode_TogglerApp.swift
//  Low-Power-Mode-Toggler
//
//  Created by Andy Lin on 6/15/22.
//

import SwiftUI
import Foundation
import UserNotifications
import IOKit.ps
import SecureXPC
import Blessed

@main
struct Low_Power_Mode_TogglerApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate
    
    var body: some Scene {
        Settings {
            EmptyView()
        }
    }
}

class AppDelegate: NSObject, NSApplicationDelegate, UNUserNotificationCenterDelegate {
    private var statusItem: NSStatusItem!
    var isLowPowerEnabled = ProcessInfo.processInfo.isLowPowerModeEnabled
    var authorization: Authorization?
    let menu = NSMenu()
    let menuItem = NSMenuItem()
    let quitButton = NSMenuItem()
    let xpcClient = XPCClient.forMachService(named: "com.andylin.Low-Power-Mode-Toggler.helper")
    let notifCenter = UNUserNotificationCenter.current()
    let lowPowerModeNotification = UNMutableNotificationContent()
    let notifTrigger = UNTimeIntervalNotificationTrigger(timeInterval: 0.1, repeats: false)
    let notifId = "lowPoweModeNotif"
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        do{
            try LaunchdManager.authorizeAndBless()
        } catch AuthorizationError.canceled {
        } catch {
            print(error)
        }
        
        notifCenter.requestAuthorization(options: [.alert, .badge], completionHandler: { granted, error in
            if let error = error{
                print(error)
            }else if granted{
                self.lowPowerModeNotification.title = "Low Battery"
                self.lowPowerModeNotification.body = "20% battery remaining. You may enable Low Power Mode to extend your battery life."
                self.lowPowerModeNotification.categoryIdentifier = "lowPowerMode"
                self.lowPowerModeNotification.interruptionLevel = .timeSensitive
            }
        })
        
        let view = NSHostingView(rootView: ContentView(xpcClient: xpcClient, authorization: authorization))
        
        view.frame = NSRect(x: 0, y: 0, width: 250, height: 40)
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        if #available(macOS 13.0, *) {
            menuItem.view = view
        } else {
            menuItem.state = isLowPowerEnabled ? .on : .off
            menuItem.title = "Low Power Mode"
            menuItem.action = #selector(togglePowerModeSelector(_:))
        }
        quitButton.title = "Quit"
        quitButton.action = #selector(quitApp(_:))
        menu.addItem(menuItem)
        menu.addItem(quitButton)
        statusItem.menu = menu
        NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        
        updateBatteryInBar()
        
        NotificationCenter.default.addObserver(self, selector: #selector(powerSourceUpdate(_:)), name: Notification.Name(rawValue: "com.andylin.powerSourceChangedNotif"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(powerSourceUpdate(_:)), name: Notification.Name(rawValue: "com.andylin.powerSourceChangedNotif"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(powerSourceUpdate(_:)), name: NSNotification.Name.NSProcessInfoPowerStateDidChange, object: nil)
    }
    
    func updateBatteryInBar(){
        let internalFinder = InternalFinder();
        if let internalBattery = internalFinder.getInternalBattery(){
            isLowPowerEnabled = ProcessInfo.processInfo.isLowPowerModeEnabled
            menuItem.state = isLowPowerEnabled ? .on : .off
            if ProcessInfo.processInfo.isLowPowerModeEnabled{
                let attributes = [NSAttributedString.Key.font: NSFont.systemFont(ofSize: 11), NSAttributedString.Key.foregroundColor: NSColor.systemYellow]
                let str = NSAttributedString(string: "\(Int(internalBattery.charge ?? 0))%", attributes: attributes)
                statusItem.button?.attributedTitle = str
                if internalBattery.charge ?? 0 >= 80 {
                    
                }
            }else{
                let attributes = [NSAttributedString.Key.font: NSFont.systemFont(ofSize: 11)]
                let str = NSAttributedString(string: "\(Int(internalBattery.charge ?? 0))%", attributes: attributes)
                statusItem.button?.attributedTitle = str
//                if internalBattery.charge ?? 0 == 20 {
                    notifCenter.getNotificationSettings(completionHandler: {(settings) in
                        if settings.authorizationStatus == .authorized{
                            let request = UNNotificationRequest(identifier: self.notifId, content: self.lowPowerModeNotification, trigger: self.notifTrigger)
                            let notifAction = UNNotificationAction(identifier: "enableLowPowerMode", title: "Enable Low Power Mode")
                            let category = UNNotificationCategory(identifier: "lowPowerMode", actions: [notifAction], intentIdentifiers: [])
                            self.notifCenter.setNotificationCategories([category])
                            self.notifCenter.add(request){(error) in
                                if let error = error {
                                    print(error)
                                }
                            }
                        }
                    })
//                }
            }
        }else{
            let attributes = [NSAttributedString.Key.font: NSFont.systemFont(ofSize: 11)]
            let str = NSAttributedString(string: "No Battery", attributes: attributes)
            statusItem.button?.attributedTitle = str
        }
    }
    
    func changePowerMode(){
        do{
            authorization = try Authorization()
            let msg = LowPowerModeUpdate(lowPowerEnabled: isLowPowerEnabled, authorization: authorization!)
            xpcClient.sendMessage(msg, to: Constants.changePowerMode, onCompletion: {_ in
            })
        }catch{
            print(error)
            return
        }
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse) async {
        if response.notification.request.content.categoryIdentifier == "lowPowerMode" {
            switch response.actionIdentifier{
            case "enableLowPowerMode":
                isLowPowerEnabled.toggle()
                changePowerMode()
                print("dne")
                break
            default:
                print(response.actionIdentifier)
                break
            }
        }
    }
    
    
    @objc public func togglePowerModeSelector(_: AnyObject){
        isLowPowerEnabled.toggle()
        changePowerMode()
    }
    
    @objc public func powerSourceUpdate(_: AnyObject){
        DispatchQueue.main.async {
            self.updateBatteryInBar()
        }
    }
    
    @objc public func quitApp(_: AnyObject){
        NSApplication.shared.terminate(self)
    }
}
