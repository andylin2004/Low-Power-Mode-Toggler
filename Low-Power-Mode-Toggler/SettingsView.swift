//
//  SettingsView.swift
//  Low Power Mode Toggler
//
//  Created by Andy Lin on 7/1/22.
//

import SwiftUI
import LaunchAtLogin
import SecureXPC
import Blessed

struct SettingsView: View {
    let xpcClient: XPCClient!
    var body: some View {
        TabView{
            Form{
                LaunchAtLogin.Toggle()
            }
            .tabItem{
                Label("General", systemImage: "gearshape")
            }
            
            AdvancedView(xpcClient: xpcClient)
            .tabItem{
                Label("Advanced", systemImage: "exclamationmark.triangle")
            }
        }
    }
}

struct AdvancedView: View {
    let xpcClient: XPCClient!
    @State var helperToolInstalled = false
    @State var updateAvailible = false
    var body: some View {
        Form{
            if !isShortcutInstalled() {
                GroupBox {
                    Button("Install Shortcut"){
                        NotificationCenter.default.post(name: NSNotification.Name("openInstallWindow"), object: nil)
                    }
                    Text("This shortcut is required for the toggler to work without having to ask for admin password every time.")
                    } label: {
                        Text("New Shortcuts Tool")
                    }
                }

            if helperToolInstalled{
                GroupBox{
                    Button("Uninstall Helper Tool"){
                        xpcClient.send(to: Constants.uninstall, onCompletion: { response in
                            if case .failure(let error) = response {
                                switch error {
                                case .connectionInterrupted:
                                    helperToolInstalled = false
                                    // It's expected the connection is interrupted as part of uninstalling the client
                                default:
                                    print(error)
                                    helperToolInstalled = checkHelperTool()
                                }
                            }
                        })
                    }
                    if let helperToolLabel = (Bundle.main.infoDictionary?["SMPrivilegedExecutables"] as? [String : Any])?.first?.key {
                        let bundlePath = URL(fileURLWithPath: "Contents/Library/LaunchServices/\(helperToolLabel)", relativeTo: Bundle.main.bundleURL).absoluteURL
                        if updateAvailible{
                            Button("Update Helper Tool"){
                                self.xpcClient.sendMessage(bundlePath, to: Constants.update) { response in
                                    if case .failure(let error) = response {
                                        switch error {
                                        case .connectionInterrupted:
                                            updateAvailible = false
                                            // It's expected the connection is interrupted as part of uninstalling the client
                                        default:
                                            print(error)
                                        }
                                    }
                                }
                            }
                        }
                    }
                } label: {
                    Text("Legacy Helper Tool")
                }
            }
        }
        .onAppear{
            helperToolInstalled = checkHelperTool()
            if let helperToolLabel = (Bundle.main.infoDictionary?["SMPrivilegedExecutables"] as? [String : Any])?.first?.key {
                let bundlePath = URL(fileURLWithPath: "Contents/Library/LaunchServices/\(helperToolLabel)", relativeTo: Bundle.main.bundleURL).absoluteURL
                updateAvailible = try! HelperToolInfoPropertyList(from: bundlePath).version > HelperToolInfoPropertyList(from: URL(fileURLWithPath: Constants.installedHelperToolLocation)).version
            }
        }
    }
}
struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView(xpcClient: .forXPCService(named: ""))
    }
}
