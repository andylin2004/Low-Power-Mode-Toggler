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
    var body: some View {
        TabView{
            VStack{
                LaunchAtLogin.Toggle()
            }
            .tabItem{
                Label("General", systemImage: "gearshape")
            }
            VStack{
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
                    Button("Update Helper Tool"){
                        if let helperToolLabel = (Bundle.main.infoDictionary?["SMPrivilegedExecutables"] as? [String : Any])?.first?.key {
                            self.xpcClient.sendMessage(URL(fileURLWithPath: "Contents/Library/LaunchServices/\(helperToolLabel)", relativeTo: Bundle.main.bundleURL).absoluteURL, to: Constants.update) { response in
                                if case .failure(let error) = response {
                                    switch error {
                                    case .connectionInterrupted:
                                        () // It's expected the connection is interrupted as part of updating the client
                                    default:
                                        print(error)
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
            }.tabItem{
                Label("Advanced", systemImage: "gearshape")
            }
        }.onAppear{
            helperToolInstalled = checkHelperTool()
        }
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView(xpcClient: .forXPCService(named: ""))
    }
}
