import Foundation
import AppKit
import SwiftUI

@MainActor
public final class SettingsWindowController: NSObject, NSWindowDelegate {
    public static let shared = SettingsWindowController()

    private var window: NSWindow?

    private override init() {
        super.init()
    }

    public func show() {
        if let window = window {
            NSApp.activate(ignoringOtherApps: true)
            window.makeKeyAndOrderFront(nil)
            window.orderFrontRegardless()
            return
        }

        let hostingController = NSHostingController(rootView: SettingsView())
        let newWindow = NSWindow(contentViewController: hostingController)
        newWindow.title = "Ajustes - Win+V for Mac"
        newWindow.styleMask = [.titled, .closable, .miniaturizable]
        newWindow.isReleasedWhenClosed = false
        newWindow.center()
        newWindow.setFrameAutosaveName("WinPlusVSettingsWindow")
        newWindow.delegate = self

        self.window = newWindow

        NSApp.activate(ignoringOtherApps: true)
        newWindow.makeKeyAndOrderFront(nil)
        newWindow.orderFrontRegardless()
    }
}
