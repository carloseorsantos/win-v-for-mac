import Foundation
import SwiftUI
import Combine

@MainActor
public final class AppSettings: ObservableObject {
    public static let shared = AppSettings()

    private enum Keys {
        static let autoPasteOnSelect = "autoPasteOnSelect"
        static let maxHistoryItems = "maxHistoryItems"
        static let playSoundOnPaste = "playSoundOnPaste"
        static let clearOnQuit = "clearOnQuit"
        static let launchAtLogin = "launchAtLogin"
        static let monitorScreenshots = "monitorScreenshots"
        static let customScreenshotsPath = "customScreenshotsPath"
    }

    @Published public var autoPasteOnSelect: Bool {
        didSet { UserDefaults.standard.set(autoPasteOnSelect, forKey: Keys.autoPasteOnSelect) }
    }

    @Published public var maxHistoryItems: Int {
        didSet { UserDefaults.standard.set(maxHistoryItems, forKey: Keys.maxHistoryItems) }
    }

    @Published public var playSoundOnPaste: Bool {
        didSet { UserDefaults.standard.set(playSoundOnPaste, forKey: Keys.playSoundOnPaste) }
    }

    @Published public var clearOnQuit: Bool {
        didSet { UserDefaults.standard.set(clearOnQuit, forKey: Keys.clearOnQuit) }
    }

    @Published public var launchAtLogin: Bool {
        didSet { UserDefaults.standard.set(launchAtLogin, forKey: Keys.launchAtLogin) }
    }

    @Published public var monitorScreenshots: Bool {
        didSet { UserDefaults.standard.set(monitorScreenshots, forKey: Keys.monitorScreenshots) }
    }

    @Published public var customScreenshotsPath: String? {
        didSet { UserDefaults.standard.set(customScreenshotsPath, forKey: Keys.customScreenshotsPath) }
    }

    public var defaultScreenshotsURL: URL {
        if let customLocation = CFPreferencesCopyAppValue("location" as CFString, "com.apple.screencapture" as CFString) as? String,
           !customLocation.isEmpty {
            let expandedPath = NSString(string: customLocation).expandingTildeInPath
            let url = URL(fileURLWithPath: expandedPath)
            if FileManager.default.fileExists(atPath: url.path) {
                return url
            }
        }
        return FileManager.default.urls(for: .desktopDirectory, in: .userDomainMask).first!
    }

    public var effectiveScreenshotsURL: URL {
        if let custom = customScreenshotsPath, !custom.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            let expanded = NSString(string: custom).expandingTildeInPath
            let url = URL(fileURLWithPath: expanded)
            if FileManager.default.fileExists(atPath: url.path) {
                return url
            }
        }
        return defaultScreenshotsURL
    }

    private init() {
        let defaults = UserDefaults.standard

        // Register default values
        defaults.register(defaults: [
            Keys.autoPasteOnSelect: true,
            Keys.maxHistoryItems: 200,
            Keys.playSoundOnPaste: false,
            Keys.clearOnQuit: false,
            Keys.launchAtLogin: false,
            Keys.monitorScreenshots: true
        ])

        self.autoPasteOnSelect = defaults.bool(forKey: Keys.autoPasteOnSelect)
        self.maxHistoryItems = defaults.integer(forKey: Keys.maxHistoryItems)
        self.playSoundOnPaste = defaults.bool(forKey: Keys.playSoundOnPaste)
        self.clearOnQuit = defaults.bool(forKey: Keys.clearOnQuit)
        self.launchAtLogin = defaults.bool(forKey: Keys.launchAtLogin)
        self.monitorScreenshots = defaults.bool(forKey: Keys.monitorScreenshots)
        self.customScreenshotsPath = defaults.string(forKey: Keys.customScreenshotsPath)
    }
}
