import Foundation
import AppKit
import Combine

@MainActor
public final class ClipboardMonitor: ObservableObject {
    public static let shared = ClipboardMonitor()

    private let pasteboard = NSPasteboard.general
    private var lastChangeCount: Int
    private var timer: Timer?

    private init() {
        self.lastChangeCount = pasteboard.changeCount
    }

    public func startMonitoring() {
        stopMonitoring()
        self.lastChangeCount = pasteboard.changeCount
        // Poll every 350ms
        timer = Timer.scheduledTimer(withTimeInterval: 0.35, repeats: true) { [weak self] _ in
            Task { @MainActor [weak self] in
                self?.checkForChanges()
            }
        }
    }

    public func stopMonitoring() {
        timer?.invalidate()
        timer = nil
    }

    private func checkForChanges() {
        let currentChangeCount = pasteboard.changeCount
        guard currentChangeCount != lastChangeCount else { return }
        lastChangeCount = currentChangeCount

        // If this change was initiated by our own paste action, ignore it
        if PasteService.shared.isInternalPasteInProgress {
            return
        }

        extractAndSaveCurrentItem()
    }

    private func extractAndSaveCurrentItem() {
        // 1. Check for Image content
        if pasteboard.canReadItem(withDataConformingToTypes: [NSPasteboard.PasteboardType.png.rawValue, NSPasteboard.PasteboardType.tiff.rawValue]) {
            if let imgData = pasteboard.data(forType: .png) ?? pasteboard.data(forType: .tiff) {
                if let image = NSImage(data: imgData), let tiff = image.tiffRepresentation,
                   let bitmap = NSBitmapImageRep(data: tiff),
                   let pngData = bitmap.representation(using: .png, properties: [:]) {
                    var isScreenshot = false
                    var filePath: String? = nil

                    // Check if pasteboard has a file URL to a screenshot
                    if let fileURLs = pasteboard.readObjects(forClasses: [NSURL.self], options: nil) as? [URL],
                       let firstURL = fileURLs.first {
                        filePath = firstURL.path
                        if ScreenshotMonitor.shared.isScreenshotFile(fileURL: firstURL) {
                            isScreenshot = true
                        }
                    }

                    // Direct screenshot to clipboard (Cmd+Ctrl+Shift+3/4)
                    // Screencapture utility places pure image data without web markup or text
                    if !isScreenshot {
                        let types = pasteboard.types ?? []
                        let hasWebMarkup = types.contains { $0.rawValue.contains("html") || $0.rawValue.contains("webarchive") }
                        let hasString = pasteboard.string(forType: .string) != nil
                        if !hasWebMarkup && !hasString {
                            isScreenshot = true
                        }
                    }

                    let item = ClipboardItem(
                        type: .image,
                        imageData: pngData,
                        isScreenshot: isScreenshot,
                        filePath: filePath
                    )
                    StorageManager.shared.addItem(item)
                    return
                }
            }
        }

        // 2. Check for Textual / URL / Color content
        if let stringValue = pasteboard.string(forType: .string) {
            let trimmed = stringValue.trimmingCharacters(in: .whitespacesAndNewlines)
            guard !trimmed.isEmpty else { return }

            let htmlValue = pasteboard.string(forType: .html)
            let rtfData = pasteboard.data(forType: .rtf)

            let itemType: ClipboardItemType
            if ColorExtractor.isHexColor(trimmed) {
                itemType = .colorHex
            } else if let url = URL(string: trimmed), let scheme = url.scheme?.lowercased(), ["http", "https", "ftp", "mailto"].contains(scheme) {
                itemType = .url
            } else {
                itemType = .text
            }

            let item = ClipboardItem(
                type: itemType,
                textValue: stringValue,
                htmlValue: htmlValue,
                rtfData: rtfData
            )

            StorageManager.shared.addItem(item)
        }
    }
}
