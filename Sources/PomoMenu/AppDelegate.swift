import Cocoa
import SwiftUI

class AppDelegate: NSObject, NSApplicationDelegate {
    private var statusItem: NSStatusItem!

    func applicationDidFinishLaunching(_: Notification) {
        let menu = NSMenu(title: "Pomo")

        menu.addItem(
            withTitle: "Start focus session",
            action: #selector(AppDelegate.onFocus),
            keyEquivalent: "f"
        )
        menu.addItem(
            withTitle: "Start break",
            action: #selector(AppDelegate.onBreak),
            keyEquivalent: "b"
        )
        menu.addItem(
            withTitle: "Stop session",
            action: #selector(AppDelegate.onStop),
            keyEquivalent: "s"
        )
        menu.addItem(NSMenuItem.separator())
        menu.addItem(
            withTitle: "Quit",
            action: #selector(AppDelegate.onQuit),
            keyEquivalent: "q"
        )

        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        statusItem.menu = menu
        statusItem.isVisible = false

        // Set the status immediately when the app starts
        update()

        // Update every second
        Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            self.update()
        }
    }

    @objc private func onFocus() {
        writeStatus(status: Status(
            type: .Focus,
            start: Date(),
            end: Date().addingTimeInterval(30 * 60),
            lastNotified: nil
        ))
    }

    @objc private func onBreak() {
        writeStatus(status: Status(
            type: .Break,
            start: Date(),
            end: Date().addingTimeInterval(5 * 60),
            lastNotified: nil
        ))
    }

    @objc private func onStop() {
        writeStatus(status: Status(
            type: .Idle,
            start: Date(),
            end: Date(),
            lastNotified: nil
        ))
    }

    @objc private func onQuit() {
        NSApp.terminate(self)
    }

    private func update() {
        guard let button = statusItem.button
        else { return }

        let status = getStatus()

        // Show/hide the status item if there is an active session
        statusItem.isVisible = status.type != StatusType.Idle

        // Bail early if there is no active session
        if status.type == StatusType.Idle {
            return
        }

        // TODO: duration
        let duration = status.end.timeIntervalSinceNow
        button.title = formatDuration(duration)
        button.image = NSImage(
            systemSymbolName: "timer",
            accessibilityDescription: "pomo"
        )

        // To prevent the menu item resizing as time ticks (no monospace font),
        // we set the length of the status item to an estimated length of the title.
        statusItem.length = measure(button.title)
    }

    private func getStatus() -> Status {
        do {
            let data = try Data(contentsOf: getStatusURL())
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .formatted(getDateFormatter())
            decoder.keyDecodingStrategy = .convertFromSnakeCase

            let status = try decoder.decode(Status.self, from: data)
            return status
        } catch {
            return Status(
                type: .Idle,
                start: Date(),
                end: Date(),
                lastNotified: Date()
            )
        }
    }

    private func writeStatus(status: Status) {
        do {
            let encoder = JSONEncoder()
            encoder.dateEncodingStrategy = .formatted(getDateFormatter())
            encoder.keyEncodingStrategy = .convertToSnakeCase

            let data = try encoder.encode(status)
            try data.write(to: getStatusURL())
        } catch {
            print("error: failed to write status")
        }
    }

    private func getStatusURL() -> URL {
        let home = NSHomeDirectory()
        let filePath = "\(home)/.config/pomo/status.json"
        return URL(fileURLWithPath: filePath)
    }

    private func getDateFormatter() -> DateFormatter {
        let formatter = DateFormatter()

        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
        formatter.timeZone = TimeZone(secondsFromGMT: 0)

        return formatter
    }

    private func formatDuration(_ duration: TimeInterval) -> String {
        let hours = abs(Int(duration) / 3600)
        let minutes = abs(Int(duration / 60) % 60)
        let seconds = abs(Int(duration) % 60)
        let sign = duration < 0 ? "-" : ""

        if hours >= 1 {
            return String(format: "%@%dh%02dm", sign, hours, minutes)
        } else if minutes >= 1 {
            return String(format: "%@%dm%02ds", sign, minutes, seconds)
        } else {
            return String(format: "%@%2ds", sign, seconds)
        }
    }

    private func measure(_ title: String) -> CGFloat {
        return CGFloat(title.count * 12)
    }
}
