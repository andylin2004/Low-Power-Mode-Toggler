//
//  ContentView.swift
//  Low-Power-Mode-Toggler
//
//  Created by Andy Lin on 6/15/22.
//

import SwiftUI
import SecureXPC

struct ContentView: View {
    @State var lowPowerModeEnabled = false
    @State var shortcutInstalled = false
    
    var body: some View {
        VStack{
            HStack{
                Text("Low Power Mode")
                    .bold()
                Spacer()
                Toggle("", isOn: $lowPowerModeEnabled)
                    .toggleStyle(.switch)
                    .disabled(!lowPowerModeSupported() || !shortcutInstalled)
            }
            Divider()
        }
        .padding(.horizontal, 15)
        .onChange(of: lowPowerModeEnabled){ isLowPowerEnabled in
            toggleShortcut(enable: isLowPowerEnabled)
        }
        .onAppear{
            Task {
                shortcutInstalled = isShortcutInstalled()
            }
            lowPowerModeEnabled = ProcessInfo.processInfo.isLowPowerModeEnabled
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
