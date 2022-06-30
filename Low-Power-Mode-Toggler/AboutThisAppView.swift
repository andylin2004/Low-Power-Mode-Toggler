//
//  AboutThisAppView.swift
//  Low-Power-Mode-Toggler
//
//  Created by Andy Lin on 6/30/22.
//

import SwiftUI

struct AboutThisAppView: View {
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        VStack(spacing: 5){
            Image("AppIconImage")
                .resizable()
                .frame(maxWidth: 92, maxHeight: 92)
            Text("Low Power Mode Toggler")
                .bold()
            Text("Version \(Bundle.main.infoDictionary!["CFBundleShortVersionString"] as! String)")
            Text("Copyright © 2022 [Andy Lin](https://andylin2004.github.io). All rights reserved.")
            
            HStack{
                Link(destination: URL(string: "https://github.com/andylin2004")!){
                    if colorScheme == .dark {
                        Image("GithubDark")
                    }else{
                        Image("GithubLight")
                    }
                }
                Link(destination: URL(string: "mailto:robloxian12345@hotmail.com?subject=Low%20Power%20Mode%20Toggler%20Support")!){
                    Image(systemName: "envelope.fill")
                        .resizable()
                        .scaledToFit()
                        .frame(maxWidth: 32, maxHeight: 32)
                        .foregroundColor(.black)
                }
            }
        }
        .padding(.top, -10)
        .padding(.horizontal, 10)
        .frame(width: 320, height: 210)
    }
}

struct AboutThisAppView_Previews: PreviewProvider {
    static var previews: some View {
        AboutThisAppView()
    }
}
