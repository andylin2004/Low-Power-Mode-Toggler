//
//  SettingsView.swift
//  Low Power Mode Toggler
//
//  Created by Andy Lin on 7/1/22.
//

import SwiftUI
import LaunchAtLogin

struct SettingsView: View {
    var body: some View {
        VStack{
            LaunchAtLogin.Toggle()
        }
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}
