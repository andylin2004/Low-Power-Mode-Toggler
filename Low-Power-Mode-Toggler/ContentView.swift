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
    @State var lowPowerModeEnabled = false
    let xpcClient: XPCClient!
    @State var authorization: Authorization?
    
    var body: some View {
        VStack{
            HStack{
                Text("Low Power Mode")
                    .bold()
                Spacer()
                Toggle("", isOn: $lowPowerModeEnabled)
                    .toggleStyle(.switch)
                    .disabled(!lowPowerModeSupported())
            }
            Divider()
        }
        .padding(.horizontal, 15)
        .onChange(of: lowPowerModeEnabled){ isLowPowerEnabled in
            do{
                authorization = try Authorization()
                let msg = LowPowerModeUpdate(lowPowerEnabled: isLowPowerEnabled, authorization: authorization!)
                xpcClient.sendMessage(msg, to: Constants.changePowerMode, onCompletion: {_ in})
            }catch{
                print(error)
                lowPowerModeEnabled.toggle()
                return
            }
        }
        .onAppear{
            lowPowerModeEnabled = ProcessInfo.processInfo.isLowPowerModeEnabled
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(xpcClient: .forMachService(named: ""))
    }
}
