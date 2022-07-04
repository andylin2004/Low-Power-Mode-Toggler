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
    @State var helperToolInstalled = false
    @State var updateAvailible = false
    var body: some View {
        TabView{
            Form{
                LaunchAtLogin.Toggle()
            }
            .tabItem{
                Label("General", systemImage: "gearshape")
            }
            
            Form{
                if helperToolInstalled{
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
                }else{
                    Button("Install Helper Tool"){
                        do{
                            try LaunchdManager.authorizeAndBless(message: "This helper tool will be used to connect to this app to turn Low Power Mode on and off.")
                        } catch AuthorizationError.canceled {
                        } catch {
                            print(error)
                        }
                        helperToolInstalled = checkHelperTool()
                    }
                }
            }.onAppear{
                helperToolInstalled = checkHelperTool()
                if let helperToolLabel = (Bundle.main.infoDictionary?["SMPrivilegedExecutables"] as? [String : Any])?.first?.key {
                    let bundlePath = URL(fileURLWithPath: "Contents/Library/LaunchServices/\(helperToolLabel)", relativeTo: Bundle.main.bundleURL).absoluteURL
                    updateAvailible = try! HelperToolInfoPropertyList(from: bundlePath).version > HelperToolInfoPropertyList(from: URL(fileURLWithPath: Constants.installedHelperToolLocation)).version
                }
            }.tabItem{
                Label("Advanced", systemImage: "exclamationmark.triangle")
            }
        }
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView(xpcClient: .forXPCService(named: ""))
    }
}
