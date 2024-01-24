//
//  ContentView.swift
//  Low-Power-Mode-Toggler
//
//  Created by Andy Lin on 6/15/22.
//

import SwiftUI
import SecureXPC

struct ContentView: View {
    @State var lowPowerModeEnabled = false
    @State var shortcutInstalled = false
    @State var statusItem: NSStatusItem!
    
    var body: some View {
        VStack(spacing: 0) {
            HStack{
                Text("Low Power Mode")
                    .bold()
                Spacer()
                Toggle("", isOn: $lowPowerModeEnabled)
                    .toggleStyle(.switch)
                    .disabled(!lowPowerModeSupported() || !shortcutInstalled)
            }
            .padding(.horizontal, 9)
            .padding(.vertical, 5)
            .padding(.bottom, 2.5)
            Divider()
                .padding(.horizontal, 9)
                .padding(.bottom, 2.5)
            if #available(macOS 14, *) {
                SettingsLink {
                    Text("Settings")
                        .padding(.horizontal, 10)
                        .padding(.vertical, 3)
                }
                .buttonStyle(ControlCenterButtonStyle(statusItem: statusItem))
            } else {
                Button {
                    Task {
                        try await Task.sleep(nanoseconds:100000000)
                        NSApp.sendAction(Selector(("showSettingsWindow:")), to: nil, from: nil)
                        NSApp.windows.last?.level = NSWindow.Level.normal + 1
                        NSApp.windows.last?.center()
                        NSApp.windows.last?.orderFrontRegardless()
                    }
                } label: {
                    Text("Settings")
                        .padding(.horizontal, 10)
                        .padding(.vertical, 3)
                }
                .buttonStyle(ControlCenterButtonStyle(statusItem: statusItem))}
            Button {
                Task {
                    try await Task.sleep(nanoseconds:100000000)
                    for window in NSApp.windows {
                        if window.title == "About" {
                            window.close()
                        }
                    }
                    let aboutWindow = NSWindow(contentViewController: NSHostingController(rootView: AboutThisAppView()))
                    aboutWindow.title = "About"
                    aboutWindow.titleVisibility = .hidden
                    aboutWindow.standardWindowButton(.miniaturizeButton)?.isEnabled = false
                    aboutWindow.standardWindowButton(.zoomButton)?.isEnabled = false
                    aboutWindow.center()
                    aboutWindow.makeKeyAndOrderFront(nil)
                }
            } label: {
                Text("About Low Power Mode Toggler")
                    .padding(.horizontal, 10)
                    .padding(.vertical, 3)
            }
            .buttonStyle(ControlCenterButtonStyle(statusItem: statusItem))
            Button {
                Task {
                    try await Task.sleep(nanoseconds:100000000)
                    NSApplication.shared.terminate(self)
                }
            } label: {
                Text("Quit")
                    .padding(.horizontal, 10)
                    .padding(.vertical, 3)
            }
            .buttonStyle(ControlCenterButtonStyle(statusItem: statusItem))
        }
        .padding(5)
        .onChange(of: lowPowerModeEnabled){ isLowPowerEnabled in
            toggleShortcut(enable: isLowPowerEnabled)
        }
        .onAppear{
            Task {
                shortcutInstalled = isShortcutInstalled()
            }
            lowPowerModeEnabled = ProcessInfo.processInfo.isLowPowerModeEnabled
        }
    }
}

struct ControlCenterButtonStyle: ButtonStyle {
    @State var hovering = false
    @State var clickAnim = false
    @State var flashIndicatorOn = true
    @State var task: Task<(), Error>?
    @State var statusItem: NSStatusItem!
    @Environment(\.colorScheme) var scheme
    
    func makeBody(configuration: Configuration) -> some View {
        HStack {
            configuration.label
                .foregroundStyle(scheme == .light ? .black : .white)
            Spacer()
        }
        .background(.quaternary.opacity(hovering && ((clickAnim && flashIndicatorOn) || !clickAnim) ? 1 : 0), in: RoundedRectangle(cornerRadius: 5))
        .onChange(of: configuration.isPressed) { pressed in
            if pressed {
                task?.cancel()
                task = Task(priority: .userInitiated) {
                    clickAnim = true
                    flashIndicatorOn = false
                    try await Task.sleep(nanoseconds: 100000000)
                    flashIndicatorOn = true
                    clickAnim = false
                    
                    DispatchQueue.main.async {
                        statusItem.menu?.cancelTracking()
                    }
                }
            }
        }
        .onHover { hover in
            hovering = hover
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
