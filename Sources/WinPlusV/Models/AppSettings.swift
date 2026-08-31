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

    private init() {
        let defaults = UserDefaults.standard

        // Register default values
        defaults.register(defaults: [
            Keys.autoPasteOnSelect: true,
            Keys.maxHistoryItems: 200,
            Keys.playSoundOnPaste: false,
            Keys.clearOnQuit: false,
            Keys.launchAtLogin: false
        ])

        self.autoPasteOnSelect = defaults.bool(forKey: Keys.autoPasteOnSelect)
        self.maxHistoryItems = defaults.integer(forKey: Keys.maxHistoryItems)
        self.playSoundOnPaste = defaults.bool(forKey: Keys.playSoundOnPaste)
        self.clearOnQuit = defaults.bool(forKey: Keys.clearOnQuit)
        self.launchAtLogin = defaults.bool(forKey: Keys.launchAtLogin)
    }
}
