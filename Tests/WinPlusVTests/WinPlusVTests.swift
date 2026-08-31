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
}
