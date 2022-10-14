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
            let process = Process()
            process.executableURL = URL("/usr/bin/shortcuts")
            if isLowPowerEnabled {
                process.arguments = ["run", "PowerToggler", "-i", Bundle.main.path(forResource: "1", ofType: "txt")!.description]
                
            } else {
                process.arguments = ["run", "PowerToggler", "-i", Bundle.main.path(forResource: "0", ofType: "txt")!.description]
            }
            process.qualityOfService = .userInteractive
            let stdout = Pipe()
            process.standardOutput = stdout
            let stderr = Pipe()
            process.standardError = stderr
            process.launch()
            process.waitUntilExit()
        }
        .onAppear{
            lowPowerModeEnabled = ProcessInfo.processInfo.isLowPowerModeEnabled
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
