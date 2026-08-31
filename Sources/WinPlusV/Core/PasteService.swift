import Foundation
import AppKit
import ApplicationServices

@MainActor
public final class PasteService {
    public static let shared = PasteService()

    /// Flag used to signal ClipboardMonitor to ignore changes caused by our own paste action
    public private(set) var isInternalPasteInProgress = false

    private init() {}

    public static var isAccessibilityGranted: Bool {
        AXIsProcessTrusted()
    }

    public static func requestAccessibilityPermissions() {
        let options = [kAXTrustedCheckOptionPrompt.takeUnretainedValue() as String: true] as CFDictionary
        AXIsProcessTrustedWithOptions(options)
    }

    public func writeToPasteboard(item: ClipboardItem) {
        let pasteboard = NSPasteboard.general
        isInternalPasteInProgress = true
        pasteboard.clearContents()

        switch item.type {
        case .text, .url, .colorHex:
            if let text = item.textValue {
                pasteboard.setString(text, forType: .string)
            }
            if let html = item.htmlValue {
                pasteboard.setString(html, forType: .html)
            }
            if let rtf = item.rtfData {
                pasteboard.setData(rtf, forType: .rtf)
            }

        case .image:
            if let data = item.imageData {
                if let image = NSImage(data: data) {
                    pasteboard.writeObjects([image])
                } else {
                    pasteboard.setData(data, forType: .png)
                }
            }
        }

        // Reset internal paste flag after small delay
        Task {
            try? await Task.sleep(nanoseconds: 300_000_000)
            await MainActor.run {
                self.isInternalPasteInProgress = false
            }
        }
    }

    public func paste(item: ClipboardItem, autoPaste: Bool? = nil) {
        let shouldAutoPaste = autoPaste ?? AppSettings.shared.autoPasteOnSelect

        // 1. Put selected item in pasteboard
        writeToPasteboard(item: item)

        // 2. Play sound if configured
        if AppSettings.shared.playSoundOnPaste {
            NSSound(named: "Pop")?.play()
        }

        // 3. If autoPaste is enabled, simulate Cmd + V in the previous frontmost app
        if shouldAutoPaste {
            let targetApp = FloatingPanelController.shared.previousApp
            simulateCmdV(targetApp: targetApp)
        }
    }

    private func simulateCmdV(targetApp: NSRunningApplication?) {
        Task {
            // 1. Hide our accessory app to yield focus back to the target app
            await MainActor.run {
                NSApp.hide(nil)
            }

            // 2. Reactivate the target application if known
            if let app = targetApp {
                app.activate()
            }

            // 3. Wait for WindowServer to establish focus in the target application
            try? await Task.sleep(nanoseconds: 60_000_000) // 60ms

            let source = CGEventSource(stateID: .hidSystemState)
            let vKeyCode: CGKeyCode = 0x09 // Virtual Key code for 'V'

            guard let keyDown = CGEvent(keyboardEventSource: source, virtualKey: vKeyCode, keyDown: true),
                  let keyUp = CGEvent(keyboardEventSource: source, virtualKey: vKeyCode, keyDown: false) else {
                return
            }

            keyDown.flags = .maskCommand
            keyUp.flags = .maskCommand

            // Post single clean event to HID stream
            keyDown.post(tap: .cghidEventTap)
            try? await Task.sleep(nanoseconds: 10_000_000) // 10ms keypress duration
            keyUp.post(tap: .cghidEventTap)
        }
    }
}
