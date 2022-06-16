//
//  ContentView.swift
//  Low-Power-Mode-Toggler
//
//  Created by Andy Lin on 6/15/22.
//

import SwiftUI

struct ContentView: View {
    @State var bruh = false
    var body: some View {
        VStack{
            Toggle("bruh", isOn: $bruh)
                .toggleStyle(.switch)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
