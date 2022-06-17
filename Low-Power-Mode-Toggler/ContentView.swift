//
//  ContentView.swift
//  Low-Power-Mode-Toggler
//
//  Created by Andy Lin on 6/15/22.
//

import SwiftUI

struct ContentView: View {
    @State var lowPoweModeEnabled = false
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
        }
        .padding(.horizontal, 15)
        .onChange(of: lowPoweModeEnabled){isLowPowerEnabled in
            let task = Process()
            task.executableURL = URL(fileURLWithPath: "/usr/bin/osascript")
            if isLowPowerEnabled{
                if let script = Bundle.main.path(forResource: "EnableLPM", ofType: "scpt"){
                    print(script)
                    task.arguments = [script]
                }
            }else{
                if let script = Bundle.main.path(forResource: "DisableLPM", ofType: "scpt"){
                    print(script)
                    task.arguments = [script]
                }
            }
            do{
                try task.run()
            }catch{
                print(error)
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
