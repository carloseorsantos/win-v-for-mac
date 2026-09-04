import Foundation
import AppKit
import Combine

@MainActor
public final class ScreenshotMonitor: ObservableObject {
    public static let shared = ScreenshotMonitor()

    private var dispatchSource: DispatchSourceFileSystemObject?
    private var fileDescriptor: Int32 = -1
    private var monitoredURL: URL?
    private var processedFilePaths = Set<String>()
    private var sessionStartTime = Date()
    private var debounceTimer: Timer?
    private var cancellables = Set<AnyCancellable>()

    private init() {
        setupSettingsObservation()
    }

    private func setupSettingsObservation() {
        AppSettings.shared.$monitorScreenshots
            .dropFirst()
            .sink { [weak self] isEnabled in
                Task { @MainActor in
                    if isEnabled {
                        self?.restartMonitoring()
                    } else {
                        self?.stopMonitoring()
                    }
                }
            }
            .store(in: &cancellables)

        AppSettings.shared.$customScreenshotsPath
            .dropFirst()
            .sink { [weak self] _ in
                Task { @MainActor in
                    if AppSettings.shared.monitorScreenshots {
                        self?.restartMonitoring()
                    }
                }
            }
            .store(in: &cancellables)
    }

    public func startMonitoring() {
        guard AppSettings.shared.monitorScreenshots else { return }
        stopMonitoring()

        let folderURL = AppSettings.shared.effectiveScreenshotsURL
        self.monitoredURL = folderURL
        self.sessionStartTime = Date()

        // Index existing files to avoid capturing older desktop images
        indexExistingFiles(in: folderURL)

        let fd = open(folderURL.path, O_EVTONLY)
        guard fd >= 0 else {
            print("[WinPlusV ScreenshotMonitor] Falha ao abrir diretório para monitoramento: \(folderURL.path)")
            return
        }
        self.fileDescriptor = fd

        let source = DispatchSource.makeFileSystemObjectSource(
            fileDescriptor: fd,
            eventMask: [.write, .extend, .attrib],
            queue: .main
        )

        source.setEventHandler { [weak self] in
            self?.handleDirectoryChangeEvent()
        }

        source.setCancelHandler {
            close(fd)
        }

        self.dispatchSource = source
        source.resume()

        print("[WinPlusV ScreenshotMonitor] Monitorando screenshots em: \(folderURL.path)")
    }

    public func stopMonitoring() {
        debounceTimer?.invalidate()
        debounceTimer = nil

        if let source = dispatchSource {
            source.cancel()
            dispatchSource = nil
        }
        fileDescriptor = -1
        monitoredURL = nil
    }

    public func restartMonitoring() {
        stopMonitoring()
        startMonitoring()
    }

    private func indexExistingFiles(in folderURL: URL) {
        processedFilePaths.removeAll()
        let fileManager = FileManager.default
        guard let contents = try? fileManager.contentsOfDirectory(at: folderURL, includingPropertiesForKeys: nil, options: [.skipsHiddenFiles]) else {
            return
        }

        for file in contents {
            processedFilePaths.insert(file.path)
        }
    }

    private func handleDirectoryChangeEvent() {
        // Debounce slightly to allow macOS screencapture daemon to finish writing file
        debounceTimer?.invalidate()
        debounceTimer = Timer.scheduledTimer(withTimeInterval: 0.35, repeats: false) { [weak self] _ in
            Task { @MainActor [weak self] in
                self?.scanForNewScreenshots()
            }
        }
    }

    private func scanForNewScreenshots() {
        guard let folderURL = monitoredURL else { return }
        let fileManager = FileManager.default

        guard let files = try? fileManager.contentsOfDirectory(
            at: folderURL,
            includingPropertiesForKeys: [.contentModificationDateKey, .creationDateKey, .fileSizeKey],
            options: [.skipsHiddenFiles]
        ) else {
            return
        }

        let supportedExtensions = ["png", "jpg", "jpeg", "tiff", "heic"]

        for fileURL in files {
            let path = fileURL.path
            guard !processedFilePaths.contains(path) else { continue }

            let ext = fileURL.pathExtension.lowercased()
            guard supportedExtensions.contains(ext) else { continue }

            // Check attributes
            guard let attrs = try? fileManager.attributesOfItem(atPath: path),
                  let fileSize = attrs[.size] as? Int64, fileSize > 0 else {
                continue
            }

            // Check modification or creation date is after session start (with 5-second leeway)
            let modDate = (attrs[.modificationDate] as? Date) ?? (attrs[.creationDate] as? Date) ?? Date()
            if modDate < sessionStartTime.addingTimeInterval(-5) {
                // File was already created before session, skip
                processedFilePaths.insert(path)
                continue
            }

            // Check if file is a screenshot (by name pattern or if in dedicated screenshots folder)
            if isScreenshotFile(fileURL: fileURL) {
                processScreenshotFile(at: fileURL)
            }
        }
    }

    func isScreenshotFile(fileURL: URL) -> Bool {
        let filename = fileURL.lastPathComponent.lowercased()

        // Common localized macOS screencapture prefixes
        let prefixes = [
            "captura de tela",
            "captura de ecrã",
            "screenshot",
            "screen shot",
            "screen capture",
            "capture d’écran",
            "capture d'ecran",
            "bildschirmfoto",
            "schermopname"
        ]

        for prefix in prefixes {
            if filename.hasPrefix(prefix) || filename.contains(prefix) {
                return true
            }
        }

        // If user configured a dedicated custom screenshots folder, accept all images created in it
        if let custom = AppSettings.shared.customScreenshotsPath, !custom.isEmpty {
            return true
        }

        return false
    }

    private func processScreenshotFile(at fileURL: URL) {
        processedFilePaths.insert(fileURL.path)

        guard let image = NSImage(contentsOf: fileURL) else { return }
        guard let tiff = image.tiffRepresentation,
              let bitmap = NSBitmapImageRep(data: tiff),
              let pngData = bitmap.representation(using: .png, properties: [:]) else {
            return
        }

        let item = ClipboardItem(
            type: .image,
            imageData: pngData,
            isScreenshot: true,
            filePath: fileURL.path
        )

        StorageManager.shared.addItem(item)
        print("[WinPlusV ScreenshotMonitor] Novo screenshot adicionado ao histórico: \(fileURL.lastPathComponent)")
    }
}
