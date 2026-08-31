import Foundation
import AppKit

public enum ClipboardItemType: String, Codable, CaseIterable, Sendable {
    case text
    case image
    case colorHex
    case url

    public var title: String {
        switch self {
        case .text: return "Texto"
        case .image: return "Imagem"
        case .colorHex: return "Cor"
        case .url: return "Link"
        }
    }

    public var systemImage: String {
        switch self {
        case .text: return "doc.text"
        case .image: return "photo"
        case .colorHex: return "paintpalette"
        case .url: return "link"
        }
    }
}

public struct ClipboardItem: Identifiable, Codable, Equatable, Sendable {
    public let id: UUID
    public let type: ClipboardItemType
    public let textValue: String?
    public let imageData: Data?
    public let htmlValue: String?
    public let rtfData: Data?
    public let createdAt: Date
    public var isPinned: Bool

    public init(
        id: UUID = UUID(),
        type: ClipboardItemType,
        textValue: String? = nil,
        imageData: Data? = nil,
        htmlValue: String? = nil,
        rtfData: Data? = nil,
        createdAt: Date = Date(),
        isPinned: Bool = false
    ) {
        self.id = id
        self.type = type
        self.textValue = textValue
        self.imageData = imageData
        self.htmlValue = htmlValue
        self.rtfData = rtfData
        self.createdAt = createdAt
        self.isPinned = isPinned
    }

    public var previewTitle: String {
        switch type {
        case .text:
            return (textValue ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        case .url:
            return (textValue ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        case .colorHex:
            return (textValue ?? "").uppercased()
        case .image:
            if let data = imageData, let image = NSImage(data: data) {
                return "Imagem (\(Int(image.size.width)) × \(Int(image.size.height)))"
            }
            return "Imagem"
        }
    }

    public var characterCount: Int {
        return textValue?.count ?? 0
    }

    public var lineCount: Int {
        guard let text = textValue else { return 0 }
        return text.components(separatedBy: .newlines).count
    }

    public func matches(query: String) -> Bool {
        guard !query.isEmpty else { return true }
        let cleanQuery = query.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()

        if let text = textValue, text.localizedCaseInsensitiveContains(cleanQuery) {
            return true
        }

        if type.title.localizedCaseInsensitiveContains(cleanQuery) {
            return true
        }

        return false
    }
}
