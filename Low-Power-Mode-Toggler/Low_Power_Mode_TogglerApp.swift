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
import EmbeddedPropertyList
import TelemetryClient

@main
struct Low_Power_Mode_TogglerApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate
    
    var body: some Scene {
        Settings {
            SettingsView()
                .frame(minWidth: 400, minHeight: 200)
        }
    }
}

class AppDelegate: NSObject, NSApplicationDelegate {
    private var statusItem: NSStatusItem!
    var isLowPowerEnabled = ProcessInfo.processInfo.isLowPowerModeEnabled
    var authorization: Authorization?
    var batteryPercentage = 0.0
    let aboutWindow = NSWindow(contentViewController: NSHostingController(rootView: AboutThisAppView()))
    let menu = NSMenu()
    let menuItem = NSMenuItem()
    let settingsButton = NSMenuItem()
    let aboutButton = NSMenuItem()
    let quitButton = NSMenuItem()
    let xpcClient = XPCClient.forMachService(named: "com.andylin.Low-Power-Mode-Toggler.helper")
    let notifCenter = UNUserNotificationCenter.current()
    let lowPowerModeEnabledNotification = UNMutableNotificationContent()
    let notifTrigger = UNTimeIntervalNotificationTrigger(timeInterval: 0.1, repeats: false)
    let notifId = "lowPoweModeNotif"
    let internalFinder = InternalFinder();
    let telementryConfiguration = TelemetryManagerConfiguration(appID: Bundle.main.infoDictionary?["TELEMETRY_DECK_API_KEY"] as! String)
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        TelemetryManager.initialize(with: telementryConfiguration)
        TelemetryManager.send("appLaunched")
        
        if !checkHelperTool(){
            do{
                try LaunchdManager.authorizeAndBless()
            } catch AuthorizationError.canceled {
            } catch {
                print(error)
            }
        }
        
        UNUserNotificationCenter.current().delegate = self
        
        notifCenter.requestAuthorization(options: [.alert, .badge], completionHandler: { granted, error in
            if let error = error{
                print(error)
            }else if granted{
                self.lowPowerModeEnabledNotification.title = "Low Battery"
                self.lowPowerModeEnabledNotification.body = "20% battery remaining. You may enable Low Power Mode to extend your battery life."
                self.lowPowerModeEnabledNotification.categoryIdentifier = "lowPowerMode"
                self.lowPowerModeEnabledNotification.interruptionLevel = .timeSensitive
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
        settingsButton.title = "Low Power Mode Toggler Settings"
        settingsButton.action = #selector(showSettings)
        aboutButton.title = "About Low Power Mode Toggler"
        aboutButton.action = #selector(showAboutThisApp)
        quitButton.title = "Quit"
        quitButton.action = #selector(quitApp(_:))
        menu.addItem(menuItem)
        menu.addItem(settingsButton)
        menu.addItem(aboutButton)
        menu.addItem(quitButton)
        statusItem.menu = menu
        
        aboutWindow.title = ""
        aboutWindow.standardWindowButton(.miniaturizeButton)?.isEnabled = false
        aboutWindow.standardWindowButton(.zoomButton)?.isEnabled = false
        
        NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        
        if let internalBattery = internalFinder.getInternalBattery(){
            batteryPercentage = internalBattery.charge ?? 0.0
        }
        
        updateBatteryInBar()
        
        NotificationCenter.default.addObserver(self, selector: #selector(powerSourceUpdate(_:)), name: Notification.Name(rawValue: "com.andylin.powerSourceChangedNotif"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(powerSourceUpdate(_:)), name: Notification.Name(rawValue: "com.andylin.powerSourceChangedNotif"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(powerSourceUpdate(_:)), name: NSNotification.Name.NSProcessInfoPowerStateDidChange, object: nil)
    }
    
    func updateBatteryInBar(){
        if let internalBattery = internalFinder.getInternalBattery(){
            isLowPowerEnabled = ProcessInfo.processInfo.isLowPowerModeEnabled
            menuItem.state = isLowPowerEnabled ? .on : .off
            if ProcessInfo.processInfo.isLowPowerModeEnabled{
                let attributes = [NSAttributedString.Key.font: NSFont.systemFont(ofSize: 11), NSAttributedString.Key.foregroundColor: NSColor.systemYellow]
                let str = NSAttributedString(string: "\(Int(internalBattery.charge ?? 0))%", attributes: attributes)
                statusItem.button?.attributedTitle = str
                if internalBattery.charge ?? 0 >= 80 && batteryPercentage < 80 {
                    
                }
            }else{
                let attributes = [NSAttributedString.Key.font: NSFont.systemFont(ofSize: 11)]
                let str = NSAttributedString(string: "\(Int(internalBattery.charge ?? 0))%", attributes: attributes)
                statusItem.button?.attributedTitle = str
                if internalBattery.charge ?? 0 == 20 && batteryPercentage > 20 {
                    notifCenter.getNotificationSettings(completionHandler: {(settings) in
                        if settings.authorizationStatus == .authorized{
                            let request = UNNotificationRequest(identifier: self.notifId, content: self.lowPowerModeEnabledNotification, trigger: self.notifTrigger)
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
                }
            }
            batteryPercentage = internalBattery.charge ?? 0
        }else{
            let attributes = [NSAttributedString.Key.font: NSFont.systemFont(ofSize: 11)]
            let str = NSAttributedString(string: "No Battery", attributes: attributes)
            statusItem.button?.attributedTitle = str
        }
    }
    
    func changePowerMode(){
        isLowPowerEnabled.toggle()
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
    
    @objc public func togglePowerModeSelector(_: AnyObject){
        changePowerMode()
    }
    
    @objc public func showAboutThisApp(_: AnyObject){
        aboutWindow.center()
        aboutWindow.makeKeyAndOrderFront(nil)
    }
    
    @objc public func showSettings(_: AnyObject){
        if #available(macOS 13.0, *) {
            NSApp.sendAction(Selector(("showSettingsWindow:")), to: nil, from: nil)
        } else {
            NSApp.sendAction(Selector(("showPreferencesWindow:")), to: nil, from: nil)
        }
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

extension AppDelegate: UNUserNotificationCenterDelegate {
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse) async {
        if response.notification.request.content.categoryIdentifier == "lowPowerMode" {
            switch response.actionIdentifier{
            case "enableLowPowerMode":
                changePowerMode()
                break
            default:
                print(response.actionIdentifier)
                break
            }
        }
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification) async -> UNNotificationPresentationOptions {
        return [.banner]
    }
}

func checkHelperTool() -> Bool {
    let process = Process()
    process.executableURL = URL("/bin/launchctl")
    process.arguments = ["print", "system/com.andylin.Low-Power-Mode-Toggler.helper"]
    process.qualityOfService = QualityOfService.userInitiated
    process.standardOutput = nil
    process.standardInput = nil
    
    process.launch()
    process.waitUntilExit()
    let registeredWithLaunchd = (process.terminationStatus == 0)
    
    do {
        let _ = try EmbeddedPropertyListReader.info.readExternal(from: URL(fileURLWithPath: "/Library/PrivilegedHelperTools/com.andylin.Low-Power-Mode-Toggler.helper"))
        return registeredWithLaunchd
    } catch {
        return false
    }
}
