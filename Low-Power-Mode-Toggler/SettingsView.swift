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
            GroupBox {
                if !isShortcutInstalled() {
                    Button("Install Shortcut"){
                        NotificationCenter.default.post(name: NSNotification.Name("openInstallWindow"), object: nil)
                    }
                    Text("This shortcut is required for the toggler to work without having to ask for admin password every time.")
                }else{
                    Text("Shortcut has been installed.")
                }
            } label: {
                Text("New Shortcuts Tool")
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
                    Text("The legacy helper tool has been deprecated as of this release and this helper tool is no longer being used to switch power modes.")
                } label: {
                    Text("Legacy Helper Tool")
                }
            }
        }
        .onAppear{
            helperToolInstalled = checkHelperTool()
            if let helperToolLabel = (Bundle.main.infoDictionary?["SMPrivilegedExecutables"] as? [String : Any])?.first?.key {
                let bundlePath = URL(fileURLWithPath: "Contents/Library/LaunchServices/\(helperToolLabel)", relativeTo: Bundle.main.bundleURL).absoluteURL
            }
        }
    }
}
struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView(xpcClient: .forXPCService(named: ""))
    }
}
