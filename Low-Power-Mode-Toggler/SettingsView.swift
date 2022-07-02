//
//  SettingsView.swift
//  Low Power Mode Toggler
//
//  Created by Andy Lin on 7/1/22.
//

import SwiftUI
import LaunchAtLogin
import SecureXPC

struct SettingsView: View {
    let xpcClient: XPCClient!
    var body: some View {
        TabView{
            VStack{
                LaunchAtLogin.Toggle()
            }
            .tabItem{
                Label("General", systemImage: "gearshape")
            }
            VStack{
                Button("Uninstall Helper Tool"){
                    xpcClient.send(to: Constants.uninstall, onCompletion: { response in
                        if case .failure(let error) = response {
                            switch error {
                                case .connectionInterrupted:
                                    () // It's expected the connection is interrupted as part of uninstalling the client
                                default:
                                    print(error)
                            }
                        }
                    })
                }
            }.tabItem{
                Label("Advanced", systemImage: "gearshape")
            }
        }
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView(xpcClient: .forXPCService(named: ""))
    }
}
