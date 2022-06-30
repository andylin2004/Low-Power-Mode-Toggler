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
            Text("Copyright © 2022 Andy Lin. All rights reserved.")
            
            HStack{
                Link(destination: URL(string: "https://github.com/andylin2004")!){
                    if colorScheme == .dark {
                        Image("GithubDark")
                    }else{
                        Image("GithubLight")
                    }
                }
                Link("Hey", destination: URL(string: "https://github.com/andylin2004")!)
            }
        }
        .frame(width: 300, height: 250)
    }
}

struct AboutThisAppView_Previews: PreviewProvider {
    static var previews: some View {
        AboutThisAppView()
    }
}
