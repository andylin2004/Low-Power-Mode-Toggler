//
//  ContentView.swift
//  Low-Power-Mode-Toggler
//
//  Created by Andy Lin on 6/15/22.
//

import SwiftUI

struct ContentView: View {
    let task = Process()
    @State var lowPoweModeEnabled = false
    var body: some View {
        HStack{
            Text("Low Power Mode")
                .bold()
            Spacer()
            Toggle("", isOn: $lowPoweModeEnabled)
                .toggleStyle(.switch)
        }
        .padding(.horizontal, 15)
        .onChange(of: lowPoweModeEnabled){isLowPowerEnabled in
            let valueToPass = isLowPowerEnabled ? 1 : 0
            
            task.arguments = ["-c", "sudo pmset -a lowpowermode \(valueToPass)"]
            task.executableURL = URL(fileURLWithPath: "/bin/zsh")
            
            do {
                try task.run()
            } catch {
                print("Error: \(error)")
                lowPoweModeEnabled.toggle()
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
