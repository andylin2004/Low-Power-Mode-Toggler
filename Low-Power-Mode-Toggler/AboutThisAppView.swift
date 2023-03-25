//
//  AboutThisAppView.swift
//  Low-Power-Mode-Toggler
//
//  Created by Andy Lin on 6/30/22.
//

import SwiftUI
import AckGen

struct AboutThisAppView: View {
    @Environment(\.colorScheme) var colorScheme
    @State var showAcks = false
    
    var body: some View {
        VStack(spacing: 5){
            Image("AppIconImage")
                .resizable()
                .frame(maxWidth: 92, maxHeight: 92)
            Text("Low Power Mode Toggler")
                .bold()
            Text("Version \(Bundle.main.infoDictionary!["CFBundleShortVersionString"] as! String)")
            Text("Copyright © 2023 [Andy Lin](https://andylin2004.github.io). All rights reserved.")
            Button(action: {
                showAcks.toggle()
            }){
                Text("Acknowledgements")
            }
            .popover(isPresented: $showAcks){
                ScrollView{
                    ForEach(Acknowledgement.all(), id: \.self) { acknowledgement in
                        if acknowledgement.title != "SwiftClient"{
                            Text("\(acknowledgement.title):\n\(acknowledgement.license)".trimmingCharacters(in: .whitespacesAndNewlines))
                        }
                    }
                    .padding(.all)
                }
                .frame(maxWidth: 400, maxHeight: 400)
            }
            
            
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
                        .foregroundColor(colorScheme == .light ? .black : .white)
                }
            }
        }
        .padding(.top, -10)
        .padding(.horizontal, 10)
        .frame(width: 320, height: 250)
    }
}

struct AboutThisAppView_Previews: PreviewProvider {
    static var previews: some View {
        AboutThisAppView()
    }
}
