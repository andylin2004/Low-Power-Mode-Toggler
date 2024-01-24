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
import EmbeddedPropertyList
import TelemetryClient
import AckGen

@main
struct Low_Power_Mode_TogglerApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate
    
    var body: some Scene {
        Settings {
            SettingsView(xpcClient: appDelegate.xpcClient)
                .frame(minWidth: 400, minHeight: 200)
        }
    }
}

class AppDelegate: NSObject, NSApplicationDelegate, NSWindowDelegate {
    var statusItem: NSStatusItem!
    var isLowPowerEnabled = ProcessInfo.processInfo.isLowPowerModeEnabled
    var batteryPercentage = 0.0
    let menu = NSMenu()
    let menuItem = NSMenuItem()
    let settingsButton = NSMenuItem()
    let aboutButton = NSMenuItem()
    let quitButton = NSMenuItem()
    let xpcClient = XPCClient.forMachService(named: "com.andylin.Low-Power-Mode-Toggler.helper")
    let notifCenter = UNUserNotificationCenter.current()
    let lowPowerModeEnabledNotification = UNMutableNotificationContent()
    let chargedEnoughNotification = UNMutableNotificationContent()
    let notifTrigger = UNTimeIntervalNotificationTrigger(timeInterval: 0.1, repeats: false)
    let askLPMNotifId = "lowPoweModeNotif"
    let chargedEnoughNotifId = "chargedEnoughNotif"
    let internalFinder = InternalFinder();
    let telementryConfiguration = TelemetryManagerConfiguration(appID: Bundle.main.infoDictionary?["TELEMETRY_DECK_API_KEY"] as! String)
    
    
    var shortcutInstalled = isShortcutInstalled()
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        TelemetryManager.initialize(with: telementryConfiguration)
        TelemetryManager.send("appLaunched")
        
        NotificationCenter.default.addObserver(self, selector: #selector(showInstallWindow), name: NSNotification.Name("openInstallWindow"), object: nil)
        
        if !isShortcutInstalled() {
            showInstallWindow()
        }
        
        UNUserNotificationCenter.current().delegate = self
        
        notifCenter.requestAuthorization(options: [.alert, .badge], completionHandler: { granted, error in
            if let error = error {
                print(error)
            } else if granted {
                self.lowPowerModeEnabledNotification.title = "Low Battery"
                self.lowPowerModeEnabledNotification.body = "20% battery remaining. You may enable Low Power Mode to extend your battery life."
                self.lowPowerModeEnabledNotification.categoryIdentifier = "lowPowerMode"
                self.lowPowerModeEnabledNotification.interruptionLevel = .timeSensitive
                
                self.chargedEnoughNotification.title = "Low Power Mode Turned Off"
                self.chargedEnoughNotification.body = "Battery sufficiently charged."
                self.chargedEnoughNotification.categoryIdentifier = "chargedEnough"
                self.lowPowerModeEnabledNotification.interruptionLevel = .timeSensitive
            }
        })
        
        
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        if #available(macOS 13.0, *) {
            let view = NSHostingView(rootView: ContentView(statusItem: statusItem))
            
            view.frame = NSRect(x: 0, y: 0, width: 250, height: 105)
            menuItem.view = view
        } else {
            menuItem.state = isLowPowerEnabled ? .on : .off
            menuItem.isEnabled = shortcutInstalled
            menuItem.title = "Low Power Mode"
            menuItem.action = #selector(togglePowerModeSelector(_:))
        }
        if #available(macOS 14, *) {
            settingsButton.view = NSHostingView(rootView: SettingsLink {
                Text("Low Power Mode Toggler Settings")
            }
                .buttonStyle(MenuButtonStyle(statusItem: statusItem)))
            settingsButton.view?.frame = NSRect(x: 0, y: 0, width: 250, height: 22)
        } else {
            settingsButton.title = "Low Power Mode Toggler Settings"
            settingsButton.action = #selector(showSettings)
        }
        
        aboutButton.title = "About Low Power Mode Toggler"
        aboutButton.action = #selector(showAboutThisApp)
        quitButton.title = "Quit"
        quitButton.action = #selector(quitApp(_:))
        menu.addItem(menuItem)
        
        if #unavailable(macOS 13){
            menu.addItem(settingsButton)
            menu.addItem(aboutButton)
            menu.addItem(quitButton)
        }
        
        statusItem.menu = menu
        statusItem.menu?.autoenablesItems = false
        
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
            if ProcessInfo.processInfo.isLowPowerModeEnabled {
                let attributes = [NSAttributedString.Key.font: NSFont.systemFont(ofSize: 11), .backgroundColor: NSColor(named: "menuBarBackgroundColor"), .foregroundColor: NSColor(named: "menuBarForegroundColor")]
                let str = NSAttributedString(string: "\(Int(internalBattery.charge ?? 0))%", attributes: attributes)
                statusItem.button?.attributedTitle = str
                if internalBattery.charge ?? 0 == 80 && batteryPercentage <= 79 {
                    changePowerMode()
                    notifCenter.getNotificationSettings(completionHandler: {(settings) in
                        if settings.authorizationStatus == .authorized{
                            let request = UNNotificationRequest(identifier: self.chargedEnoughNotifId, content: self.chargedEnoughNotification, trigger: self.notifTrigger)
                            let category = UNNotificationCategory(identifier: "chargedEnough", actions: [], intentIdentifiers: [])
                            self.notifCenter.setNotificationCategories([category])
                            self.notifCenter.add(request){(error) in
                                if let error = error {
                                    print(error)
                                }
                            }
                        }
                    })
                }
            } else {
                let attributes = [NSAttributedString.Key.font: NSFont.systemFont(ofSize: 11)]
                let str = NSAttributedString(string: "\(Int(internalBattery.charge ?? 0))%", attributes: attributes)
                statusItem.button?.attributedTitle = str
                if internalBattery.charge ?? 0 == 20 && batteryPercentage > 20 {
                    self.notifCenter.removeAllDeliveredNotifications()
                    notifCenter.getNotificationSettings(completionHandler: {(settings) in
                        if settings.authorizationStatus == .authorized{
                            let request = UNNotificationRequest(identifier: self.askLPMNotifId, content: self.lowPowerModeEnabledNotification, trigger: self.notifTrigger)
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
                } else if internalBattery.charge ?? 0 == 80 && batteryPercentage <= 79 {
                   self.notifCenter.removeAllDeliveredNotifications()
               }
            }
            batteryPercentage = internalBattery.charge ?? 0
        }else{
            let attributes = [NSAttributedString.Key.font: NSFont.systemFont(ofSize: 11)]
            let str = NSAttributedString(string: "No Battery", attributes: attributes)
            statusItem.button?.attributedTitle = str
        }
    }
    
    func windowWillClose(_ notification: Notification) {
        if (notification.object as! NSWindow).title == "Setup Low Power Mode Toggler" {
            shortcutInstalled = isShortcutInstalled()
            menuItem.isEnabled = shortcutInstalled
        }
    }
    
    func changePowerMode(){
        isLowPowerEnabled.toggle()
        toggleShortcut(enable: isLowPowerEnabled)
    }
    
    @objc public func togglePowerModeSelector(_: AnyObject){
        changePowerMode()
    }
    
    @objc public func showAboutThisApp(_: AnyObject){
        NSApp.windows.first { window in
            window.title == "About"
        }?.close()
        let aboutWindow = NSWindow(contentViewController: NSHostingController(rootView: AboutThisAppView()))
        aboutWindow.title = "About"
        aboutWindow.titleVisibility = .hidden
        aboutWindow.standardWindowButton(.miniaturizeButton)?.isEnabled = false
        aboutWindow.standardWindowButton(.zoomButton)?.isEnabled = false
        aboutWindow.center()
        aboutWindow.makeKeyAndOrderFront(nil)
    }
    
    @objc public func showSettings(_: AnyObject){
        if #available(macOS 13.0, *) {
            NSApp.sendAction(Selector(("showSettingsWindow:")), to: nil, from: nil)
        } else {
            NSApp.sendAction(Selector(("showPreferencesWindow:")), to: nil, from: nil)
        }
        NSApp.windows.last?.level = NSWindow.Level.normal + 1
        NSApp.windows.last?.center()
        NSApp.windows.last?.orderFrontRegardless()
    }
    
    @objc public func powerSourceUpdate(_: AnyObject) {
        DispatchQueue.main.async {
            self.updateBatteryInBar()
        }
    }
    
    @objc public func quitApp(_: AnyObject){
        NSApplication.shared.terminate(self)
    }
    
    @objc public func showInstallWindow() {
        let installWindow = NSWindow(contentViewController: NSHostingController(rootView: InstallView()))
        installWindow.title = "Setup Low Power Mode Toggler"
        installWindow.standardWindowButton(.miniaturizeButton)?.isEnabled = false
        installWindow.standardWindowButton(.zoomButton)?.isEnabled = false
        installWindow.level = NSWindow.Level.normal + 1
        installWindow.delegate = self
        installWindow.makeKeyAndOrderFront(self)
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

extension Acknowledgement: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(title)
    }
    
    public static func == (lhs: Acknowledgement, rhs: Acknowledgement) -> Bool {
        return lhs.title == rhs.title
    }
}

struct MenuButtonStyle: ButtonStyle {
    @State var isHovering = false
    var statusItem: NSStatusItem
    
    func makeBody(configuration: Configuration) -> some View {
        HStack {
            Spacer()
                .frame(width: 10)
            configuration.label
                .foregroundStyle(isHovering ? .white : .primary)
            Spacer()
        }
        .padding(.vertical, 3)
        .background(
            withAnimation {
                isHovering ? Color(red: 0.243, green: 0.573, blue: 0.988) : .clear
            }
        )
        .onHover(perform: { hovering in
            if !configuration.isPressed {
                isHovering = hovering
            }
        })
        .onChange(of: configuration.isPressed) { pressed in
            if pressed {
                Task(priority: .high) {
                    for _ in 0..<2 {
                        isHovering = false
                        usleep(75000)
                        isHovering = true
                        usleep(75000)
                    }
                    isHovering = false
                    
                    DispatchQueue.main.async {
                        statusItem.menu?.cancelTracking()
                    }
                }
            }
        }
        .cornerRadius(5)
        .padding(.horizontal, 5)
    }
}
