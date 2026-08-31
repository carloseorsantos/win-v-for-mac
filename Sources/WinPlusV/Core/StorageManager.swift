import Foundation
import SwiftUI
import Combine

@MainActor
public final class StorageManager: ObservableObject {
    public static let shared = StorageManager()

    @Published public private(set) var items: [ClipboardItem] = []

    private let fileManager = FileManager.default
    private let appSupportURL: URL
    private let historyFileURL: URL

    private init() {
        let baseDir = fileManager.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
        self.appSupportURL = baseDir.appendingPathComponent("WinPlusV", isDirectory: true)
        self.historyFileURL = appSupportURL.appendingPathComponent("history.json")

        createDirectoryIfNeeded()
        loadHistory()
    }

    private func createDirectoryIfNeeded() {
        if !fileManager.fileExists(atPath: appSupportURL.path) {
            try? fileManager.createDirectory(at: appSupportURL, withIntermediateDirectories: true)
        }
    }

    public func loadHistory() {
        guard fileManager.fileExists(atPath: historyFileURL.path) else { return }

        do {
            let data = try Data(contentsOf: historyFileURL)
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            let loaded = try decoder.decode([ClipboardItem].self, from: data)
            self.items = loaded
        } catch {
            print("[WinPlusV Storage] Erro ao carregar histórico: \(error)")
        }
    }

    public func saveHistory() {
        createDirectoryIfNeeded()
        do {
            let encoder = JSONEncoder()
            encoder.outputFormatting = [.prettyPrinted]
            encoder.dateEncodingStrategy = .iso8601
            let data = try encoder.encode(items)
            try data.write(to: historyFileURL, options: .atomic)
        } catch {
            print("[WinPlusV Storage] Erro ao salvar histórico: \(error)")
        }
    }

    public func addItem(_ newItem: ClipboardItem) {
        // If an item with identical content already exists, bump it to top
        if let existingIndex = items.firstIndex(where: { item in
            if item.type != newItem.type { return false }
            switch item.type {
            case .text, .url, .colorHex:
                return item.textValue == newItem.textValue
            case .image:
                return item.imageData == newItem.imageData
            }
        }) {
            let existing = items.remove(at: existingIndex)
            // Preserve pin status if it was pinned, but update timestamp
            let updated = ClipboardItem(
                id: existing.id,
                type: existing.type,
                textValue: existing.textValue,
                imageData: existing.imageData,
                htmlValue: existing.htmlValue,
                rtfData: existing.rtfData,
                createdAt: Date(),
                isPinned: existing.isPinned
            )
            items.insert(updated, at: 0)
        } else {
            items.insert(newItem, at: 0)
        }

        pruneExcessItems()
        saveHistory()
    }

    public func deleteItem(id: UUID) {
        items.removeAll { $0.id == id }
        saveHistory()
    }

    public func togglePin(id: UUID) {
        if let index = items.firstIndex(where: { $0.id == id }) {
            items[index].isPinned.toggle()
            saveHistory()
        }
    }

    public func clearHistory(preservePinned: Bool = true) {
        if preservePinned {
            items.removeAll { !$0.isPinned }
        } else {
            items.removeAll()
        }
        saveHistory()
    }

    private func pruneExcessItems() {
        let maxCount = AppSettings.shared.maxHistoryItems
        guard items.count > maxCount else { return }

        // Keep all pinned items + the most recent unpinned items up to maxCount
        var retained: [ClipboardItem] = []
        var unpinnedCount = 0

        for item in items {
            if item.isPinned {
                retained.append(item)
            } else if unpinnedCount < maxCount {
                retained.append(item)
                unpinnedCount += 1
            }
        }

        self.items = retained
    }
}
