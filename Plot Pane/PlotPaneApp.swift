import SwiftUI

@main
struct PlotPaneApp: App {
    
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    @State var data: [String] = []
    @State var active = 0
    
    var body: some Scene {
        WindowGroup {
            ContentView(data: $data, active: $active)
                .frame(minWidth: 400, minHeight: 300)
                .onAppear {
                    NSWindow.allowsAutomaticWindowTabbing = false
                }
                .toolbar {
                    ToolbarItemGroup {
                        Button(action: {
                            if NSEvent.modifierFlags.contains(.option) {
                                self.active = 0
                            } else {
                                self.active -= 1
                            }
                        }) {
                            Label("Previous Plot", systemImage: "chevron.backward")
                        }
                        .disabled(active <= 0)
                        
                        Button(action: {
                            if NSEvent.modifierFlags.contains(.option) {
                                active = data.endIndex-1
                            } else {
                                active += 1
                            }
                        }) {
                            Label("Next Plot", systemImage: "chevron.forward")
                        }
                        .disabled(active >= data.endIndex-1)
                    }
                }
                .onOpenURL { url in
                    let url = url.absoluteString
                    let prefix = "plot-pane:"
                    
                    if url.starts(with: prefix) {
                        let newData = String(url.dropFirst(prefix.count))
                        
                        data.append(newData)
                        active = data.endIndex - 1
                    }
                }
                .handlesExternalEvents(preferring: Set(arrayLiteral: "*"), allowing: Set(arrayLiteral: "*"))
                
        }
        .commands {
            CommandGroup(replacing: .newItem, addition: {})
            CommandMenu("Navigate") {
                Button("Previous Plot") { active -= 1 }
                    .keyboardShortcut(.leftArrow, modifiers: [])
                    .disabled(active <= 0)
                Button("Next Plot") { active += 1 }
                    .keyboardShortcut(.rightArrow, modifiers: [])
                    .disabled(active >= data.endIndex-1)
                Divider()
                Button("First Plot") { active = 0 }
                    .keyboardShortcut(.leftArrow, modifiers: .option)
                    .disabled(active <= 0)
                Button("Last Plot") { active = data.endIndex-1 }
                    .keyboardShortcut(.rightArrow, modifiers: .option)
                    .disabled(active >= data.endIndex-1)
            }
        }
    }
}

class AppDelegate: NSObject, NSApplicationDelegate {
    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        return true
    }
}
