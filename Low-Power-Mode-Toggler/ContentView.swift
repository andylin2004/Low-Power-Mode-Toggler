//
//  ContentView.swift
//  Low-Power-Mode-Toggler
//
//  Created by Andy Lin on 6/15/22.
//

import SwiftUI
import SecureXPC
import Blessed

struct ContentView: View {
    @State var lowPoweModeEnabled = false
    let xpcClient: XPCClient!
    
    var body: some View {
        VStack{
            HStack{
                Text("Low Power Mode")
                    .bold()
                Spacer()
                Toggle("", isOn: $lowPoweModeEnabled)
                    .toggleStyle(.switch)
            }
            Button(action: {lowPoweModeEnabled.toggle()}, label: {Text("pp")})
            Button(action: {
                do{
                    try LaunchdManager.authorizeAndBless()
                } catch AuthorizationError.canceled {
                    
                } catch {
                    print(error)
                }
            }){
                Text("eeee")
            }
            Button(action: {
                NSApplication.shared.terminate(self)
            }){
                Text("Quit")
            }
        }
        .padding(.horizontal, 15)
        .onChange(of: lowPoweModeEnabled){ isLowPowerEnabled in
            xpcClient.sendMessage(lowPoweModeEnabled, to: Constants.changePowerMode, onCompletion: {_ in })
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(xpcClient: .forMachService(named: ""))
    }
}
