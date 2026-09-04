import XCTest
@testable import WinPlusV

final class WinPlusVTests: XCTestCase {

    func testColorExtractorValidHex() {
        XCTAssertTrue(ColorExtractor.isHexColor("#fff"))
        XCTAssertTrue(ColorExtractor.isHexColor("#FFFFFF"))
        XCTAssertTrue(ColorExtractor.isHexColor("#ff00aaff"))
        XCTAssertTrue(ColorExtractor.isHexColor("#1A2B3C"))
    }

    func testColorExtractorInvalidHex() {
        XCTAssertFalse(ColorExtractor.isHexColor("hello world"))
        XCTAssertFalse(ColorExtractor.isHexColor("#12345"))
        XCTAssertFalse(ColorExtractor.isHexColor("#ZZZZZZ"))
        XCTAssertFalse(ColorExtractor.isHexColor(""))
    }

    func testClipboardItemSearch() {
        let textItem = ClipboardItem(
            type: .text,
            textValue: "SwiftUI macOS Clipboard Manager"
        )

        XCTAssertTrue(textItem.matches(query: "swiftui"))
        XCTAssertTrue(textItem.matches(query: "CLIPBOARD"))
        XCTAssertTrue(textItem.matches(query: "manager"))
        XCTAssertFalse(textItem.matches(query: "Android"))
    }

    @MainActor
    func testStorageDeduplicationAndPinning() {
        let storage = StorageManager.shared
        storage.clearHistory(preservePinned: false)

        let item1 = ClipboardItem(type: .text, textValue: "Primeiro texto", isPinned: true)
        let item2 = ClipboardItem(type: .text, textValue: "Segundo texto", isPinned: false)

        storage.addItem(item1)
        storage.addItem(item2)

        XCTAssertEqual(storage.items.count, 2)
        XCTAssertEqual(storage.items[0].textValue, "Segundo texto")

        // Re-adding item1 should bump it to the top while preserving pin
        storage.addItem(item1)
        XCTAssertEqual(storage.items.count, 2)
        XCTAssertEqual(storage.items[0].textValue, "Primeiro texto")
        XCTAssertTrue(storage.items[0].isPinned)

        // Clear without removing pinned
        storage.clearHistory(preservePinned: true)
        XCTAssertEqual(storage.items.count, 1)
        XCTAssertEqual(storage.items[0].textValue, "Primeiro texto")
    }

    func testScreenshotItemCodableBackwardCompatibility() throws {
        // JSON from prior app version without isScreenshot or filePath
        let legacyJSON = """
        {
            "id": "12345678-1234-1234-1234-123456789abc",
            "type": "image",
            "createdAt": "2026-09-01T12:00:00Z",
            "isPinned": false
        }
        """.data(using: .utf8)!

        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        let item = try decoder.decode(ClipboardItem.self, from: legacyJSON)

        XCTAssertFalse(item.isScreenshot)
        XCTAssertNil(item.filePath)
        XCTAssertEqual(item.type, .image)
    }

    func testScreenshotItemEncodingAndDecoding() throws {
        let originalItem = ClipboardItem(
            type: .image,
            imageData: Data([0x01, 0x02, 0x03]),
            isScreenshot: true,
            filePath: "/Users/test/Desktop/Captura de Tela 2026-09-03 às 10.00.00.png"
        )

        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        let encoded = try encoder.encode(originalItem)

        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        let decoded = try decoder.decode(ClipboardItem.self, from: encoded)

        XCTAssertTrue(decoded.isScreenshot)
        XCTAssertEqual(decoded.filePath, "/Users/test/Desktop/Captura de Tela 2026-09-03 às 10.00.00.png")
        XCTAssertEqual(decoded.type, .image)
        XCTAssertEqual(decoded.imageData, Data([0x01, 0x02, 0x03]))
    }

    func testScreenshotSearchMatching() {
        let screenshotItem = ClipboardItem(
            type: .image,
            isScreenshot: true,
            filePath: "/Users/test/Desktop/Captura de Tela 2026-09-03.png"
        )

        XCTAssertTrue(screenshotItem.matches(query: "captura"))
        XCTAssertTrue(screenshotItem.matches(query: "screenshot"))
        XCTAssertTrue(screenshotItem.matches(query: "2026-09-03"))
        XCTAssertFalse(screenshotItem.matches(query: "planilha"))
    }

    func testFilterTabsIncludeCapturas() {
        let tabs = FilterTab.allCases
        XCTAssertTrue(tabs.contains(.screenshots))
        XCTAssertEqual(FilterTab.screenshots.rawValue, "Capturas")
        XCTAssertEqual(FilterTab.screenshots.icon, "camera")
    }

    @MainActor
    func testLaunchAtLoginSetting() {
        let settings = AppSettings.shared
        let original = settings.launchAtLogin

        settings.launchAtLogin = true
        XCTAssertTrue(settings.launchAtLogin)

        settings.launchAtLogin = false
        XCTAssertFalse(settings.launchAtLogin)

        // Restore original value
        settings.launchAtLogin = original
    }
}
