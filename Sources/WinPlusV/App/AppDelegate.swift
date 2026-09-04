import Foundation
import AppKit
import SwiftUI

@MainActor
public final class AppDelegate: NSObject, NSApplicationDelegate {
    public func applicationDidFinishLaunching(_ notification: Notification) {
        // Run as background accessory app (no Dock icon, status bar only)
        NSApp.setActivationPolicy(.accessory)

        // Setup Floating Window
        FloatingPanelController.shared.setup(contentView: AnyView(ClipboardPopupView()))

        // Start Clipboard Monitor
        ClipboardMonitor.shared.startMonitoring()

        // Start Screenshot Monitor
        ScreenshotMonitor.shared.startMonitoring()

        // Register Global Shortcut (Option + V)
        HotKeyManager.shared.registerDefaultHotKey {
            FloatingPanelController.shared.toggleNearCursor()
        }

        print("[WinPlusV] Aplicativo inicializado com sucesso. Atalho ⌥ + V ativo.")
    }

    public func applicationWillTerminate(_ notification: Notification) {
        ClipboardMonitor.shared.stopMonitoring()
        ScreenshotMonitor.shared.stopMonitoring()
        HotKeyManager.shared.unregisterHotKey()

        if AppSettings.shared.clearOnQuit {
            StorageManager.shared.clearHistory(preservePinned: false)
        }
    }

    @objc public func showSettingsWindow(_ sender: Any?) {
        SettingsWindowController.shared.show()
    }

    @objc public func showPreferencesWindow(_ sender: Any?) {
        SettingsWindowController.shared.show()
    }
}
