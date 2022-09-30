import Cocoa
import SwiftUI

class AppDelegate: NSObject, NSApplicationDelegate {
    private var statusItem: NSStatusItem!

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        let menu = NSMenu(title: "Howdy")
        
        menu.addItem(
            withTitle: "Start session",
            action: #selector(AppDelegate.onStart),
            keyEquivalent: ""
        )
        menu.addItem(
            withTitle: "Stop session",
            action: #selector(AppDelegate.onStop),
            keyEquivalent: ""
        )
        menu.addItem(NSMenuItem.separator())
        menu.addItem(
            withTitle: "Quit",
            action: #selector(AppDelegate.onQuit),
            keyEquivalent: "q"
        )
        
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        statusItem.menu = menu
        
        Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            guard let button = self.statusItem.button
            else { return }
            
            let output = self.pomo("--no-emoji --format=time")
            let trimmed = output.trimmingCharacters(in: .whitespacesAndNewlines)
            
            if trimmed == "" {
                button.title = ""
                button.image = NSImage(
                    systemSymbolName: "timer",
                    accessibilityDescription: "pomo"
                )
            } else {
                button.title = trimmed
                button.image = nil
            }
        }
    }
    
    @objc private func onQuit() {
        NSApp.terminate(self)
    }
    
    @objc private func onStart() {
        _ = pomo("start")
    }
    
    @objc private func onStop() {
        _ = pomo("stop")
    }
    
    private func pomo(_ args: String) -> String {
        let process = Process()
        let pipe = Pipe()
        let home = NSHomeDirectory()
        
        process.executableURL = URL(fileURLWithPath: "/bin/bash")
        process.arguments = ["-c", "\(home)/go/bin/pomo \(args)"]
        process.standardOutput = pipe
        process.standardError = pipe
        process.standardInput = nil
        
        try! process.run()
        
        return String(
            data: pipe.fileHandleForReading.readDataToEndOfFile(),
            encoding: .utf8
        )!
    }
}
