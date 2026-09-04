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
    public var isScreenshot: Bool
    public var filePath: String?

    enum CodingKeys: String, CodingKey {
        case id, type, textValue, imageData, htmlValue, rtfData, createdAt, isPinned, isScreenshot, filePath
    }

    public init(
        id: UUID = UUID(),
        type: ClipboardItemType,
        textValue: String? = nil,
        imageData: Data? = nil,
        htmlValue: String? = nil,
        rtfData: Data? = nil,
        createdAt: Date = Date(),
        isPinned: Bool = false,
        isScreenshot: Bool = false,
        filePath: String? = nil
    ) {
        self.id = id
        self.type = type
        self.textValue = textValue
        self.imageData = imageData
        self.htmlValue = htmlValue
        self.rtfData = rtfData
        self.createdAt = createdAt
        self.isPinned = isPinned
        self.isScreenshot = isScreenshot
        self.filePath = filePath
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(UUID.self, forKey: .id)
        self.type = try container.decode(ClipboardItemType.self, forKey: .type)
        self.textValue = try container.decodeIfPresent(String.self, forKey: .textValue)
        self.imageData = try container.decodeIfPresent(Data.self, forKey: .imageData)
        self.htmlValue = try container.decodeIfPresent(String.self, forKey: .htmlValue)
        self.rtfData = try container.decodeIfPresent(Data.self, forKey: .rtfData)
        self.createdAt = try container.decode(Date.self, forKey: .createdAt)
        self.isPinned = try container.decodeIfPresent(Bool.self, forKey: .isPinned) ?? false
        self.isScreenshot = try container.decodeIfPresent(Bool.self, forKey: .isScreenshot) ?? false
        self.filePath = try container.decodeIfPresent(String.self, forKey: .filePath)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(type, forKey: .type)
        try container.encodeIfPresent(textValue, forKey: .textValue)
        try container.encodeIfPresent(imageData, forKey: .imageData)
        try container.encodeIfPresent(htmlValue, forKey: .htmlValue)
        try container.encodeIfPresent(rtfData, forKey: .rtfData)
        try container.encode(createdAt, forKey: .createdAt)
        try container.encode(isPinned, forKey: .isPinned)
        try container.encode(isScreenshot, forKey: .isScreenshot)
        try container.encodeIfPresent(filePath, forKey: .filePath)
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
            let prefix = isScreenshot ? "Captura de Tela" : "Imagem"
            if let data = imageData, let image = NSImage(data: data) {
                return "\(prefix) (\(Int(image.size.width)) × \(Int(image.size.height)))"
            }
            return prefix
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

        if isScreenshot && ("captura".localizedCaseInsensitiveContains(cleanQuery) || "screenshot".localizedCaseInsensitiveContains(cleanQuery)) {
            return true
        }

        if let filePath = filePath, (filePath as NSString).lastPathComponent.localizedCaseInsensitiveContains(cleanQuery) {
            return true
        }

        if let text = textValue, text.localizedCaseInsensitiveContains(cleanQuery) {
            return true
        }

        if type.title.localizedCaseInsensitiveContains(cleanQuery) {
            return true
        }

        return false
    }
}
