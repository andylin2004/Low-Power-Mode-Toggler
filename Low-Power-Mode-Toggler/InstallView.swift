//
//  InstallView.swift
//  Low-Power-Mode-Toggler
//
//  Created by Andy Lin on 6/18/22.
//

import SwiftUI
import Blessed

struct InstallView: View {
    @Environment(\.openURL) var openURL
    var body: some View {
        VStack {
            Text("Just a few more steps to running the toggler!")
            HStack{
                Text("1. Install the shortcut, which the toggler will use")
                Button("Install"){
                    openURL(URL(string: "https://www.icloud.com/shortcuts/5d90c2dddb164c6bbdd2ea8d2c377fae")!)
                }
            }
            Text("2. Click on the Add Shortcut button")
            Text("3. Go back to this window and close this window or press Done.")
            Text("\nThe shortcut will ask for admin access when the toggler is used the first time.\nThe helper tool is no longer being used and it should be uninstalled.")
            Button("Done"){
                NSApp.keyWindow?.close()
            }
        }
        .frame(width: 400, height: 190)
    }
}

struct InstallView_Previews: PreviewProvider {
    static var previews: some View {
        InstallView()
    }
}
