//
//  ContentView.swift
//  Low-Power-Mode-Toggler
//
//  Created by Andy Lin on 6/15/22.
//

import SwiftUI
import SecureXPC

struct ContentView: View {
    @State var powerMode = 0
    @State var lowPowerModeEnabled = false
    @State var shortcutInstalled = false
    @State var hovering0 = false
    @State var hovering1 = false
    @State var hovering2 = false
    
    @ViewBuilder
    var body: some View {
        Group{
            if !highPowerModeSupported() {
                VStack(alignment: .leading, spacing: 0){
                    Text("Power Mode")
                        .bold()
                        .padding(.leading, 10)
                        .padding(.bottom, 10)
                    Button {
                        powerMode = 1
                    } label: {
                        ZStack {
                            RoundedRectangle(cornerRadius: 5)
                                .fill(hovering0 ? Color.gray.opacity(0.3) : Color.clear)
                                .frame(width: 240, height: 35)
                            HStack {
                                ZStack {
                                    Circle()
                                        .frame(height: 30)
                                        .foregroundColor(powerMode == 1 ? .accentColor : .gray.opacity(0.6))
                                    Image(systemName: "gauge.low")
                                        .font(.system(size: 20))
                                }
                                Text("Low Power Mode")
                                Spacer()
                            }
                            .padding(.leading, 10)
                        }
                    }
                    .buttonStyle(.borderless)
                    .onHover { hover in
                        hovering0 = hover
                    }
                    Button {
                        powerMode = 0
                    } label: {
                        ZStack {
                            RoundedRectangle(cornerRadius: 5)
                                .fill(hovering1 ? Color.gray.opacity(0.3) : Color.clear)
                                .frame(width: 240, height: 35)
                            HStack {
                                ZStack {
                                    Circle()
                                        .frame(height: 30)
                                        .foregroundColor(powerMode == 0 ? .accentColor : .gray.opacity(0.6))
                                    Image(systemName: "gauge.medium")
                                        .font(.system(size: 20))
                                }
                                Text("Normal")
                                Spacer()
                            }
                            .padding(.leading, 10)
                        }
                    }
                    .buttonStyle(.borderless)
                    .onHover { hover in
                        hovering1 = hover
                    }
                    Button {
                        powerMode = 2
                    } label: {
                        ZStack {
                            RoundedRectangle(cornerRadius: 5)
                                .fill(hovering2 ? Color.gray.opacity(0.3) : Color.clear)
                                .frame(width: 240, height: 35)
                            HStack {
                                ZStack {
                                    Circle()
                                        .frame(height: 30)
                                        .foregroundColor(powerMode == 2 ? .accentColor : .gray.opacity(0.6))
                                    Image(systemName: "gauge.high")
                                        .font(.system(size: 20))
                                }
                                Text("High Power Mode")
                                Spacer()
                            }
                            .padding(.leading, 10)
                        }
                        
                    }
                    .buttonStyle(.borderless)
                    .onHover { hover in
                        hovering2 = hover
                    }
                }
                .onChange(of: powerMode) { newValue in
                    toggleShortcut(state: newValue)
                }
            }else{
                VStack{
                    HStack{
                        Text("Low Power Mode")
                            .bold()
                        Spacer()
                        Toggle("", isOn: $lowPowerModeEnabled)
                            .toggleStyle(.switch)
                            .disabled(!lowPowerModeSupported() || !shortcutInstalled)
                    }
                }
                .onChange(of: lowPowerModeEnabled){ isLowPowerEnabled in
                    toggleShortcut(enable: isLowPowerEnabled)
                }
            }
            Divider()
        }
        .padding(.horizontal, 15)
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
