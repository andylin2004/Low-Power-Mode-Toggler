//
//  InstallView.swift
//  Low-Power-Mode-Toggler
//
//  Created by Andy Lin on 6/18/22.
//

import SwiftUI
import Blessed

struct InstallView: View {
    var body: some View {
        VStack{
            Button(action: {
                do{
                    try LaunchdManager.authorizeAndBless()
                } catch AuthorizationError.canceled {
                    
                } catch {
                    print(error)
                }
            }){
                Text("eeee")
            }
        }
    }
}

struct InstallView_Previews: PreviewProvider {
    static var previews: some View {
        InstallView()
    }
}
