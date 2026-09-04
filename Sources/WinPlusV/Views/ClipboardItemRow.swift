import SwiftUI
import AppKit

public struct ClipboardItemRow: View {
    let item: ClipboardItem
    let index: Int?
    let isSelected: Bool
    let onSelect: () -> Void
    let onTogglePin: () -> Void
    let onDelete: () -> Void

    @State private var isHovered = false

    private static let relativeDateFormatter: RelativeDateTimeFormatter = {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .short
        return formatter
    }()

    public var body: some View {
        Button(action: onSelect) {
            HStack(alignment: .center, spacing: 10) {
                // Index number or Type Icon
                ZStack {
                    if let index = index, index <= 9 {
                        Text("\(index)")
                            .font(.system(size: 11, weight: .bold, design: .monospaced))
                            .foregroundColor(.secondary)
                            .frame(width: 22, height: 22)
                            .background(Color.primary.opacity(0.06))
                            .clipShape(RoundedRectangle(cornerRadius: 5))
                    } else {
                        Image(systemName: item.isScreenshot ? "camera.viewfinder" : item.type.systemImage)
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundColor(iconColor)
                            .frame(width: 22, height: 22)
                    }
                }

                // Content Preview
                contentView
                    .frame(maxWidth: .infinity, alignment: .leading)

                // Actions: Timestamp & Pin / Delete / Finder
                HStack(spacing: 6) {
                    if isHovered || isSelected {
                        if let filePath = item.filePath, FileManager.default.fileExists(atPath: filePath) {
                            Button(action: {
                                NSWorkspace.shared.selectFile(filePath, inFileViewerRootedAtPath: "")
                            }) {
                                Image(systemName: "folder")
                                    .font(.system(size: 11))
                                    .foregroundColor(.secondary)
                            }
                            .buttonStyle(.plain)
                            .help("Mostrar no Finder")
                        }

                        Button(action: onTogglePin) {
                            Image(systemName: item.isPinned ? "pin.fill" : "pin")
                                .font(.system(size: 11))
                                .foregroundColor(item.isPinned ? .orange : .secondary)
                        }
                        .buttonStyle(.plain)
                        .help(item.isPinned ? "Desafixar" : "Fixar no topo")

                        Button(action: onDelete) {
                            Image(systemName: "trash")
                                .font(.system(size: 11))
                                .foregroundColor(.red.opacity(0.8))
                        }
                        .buttonStyle(.plain)
                        .help("Remover do histórico")
                    } else {
                        if item.isPinned {
                            Image(systemName: "pin.fill")
                                .font(.system(size: 10))
                                .foregroundColor(.orange)
                        }

                        Text(timeString)
                            .font(.system(size: 10))
                            .foregroundColor(.secondary)
                    }
                }
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 7)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(backgroundColor)
            )
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .onHover { hovering in
            isHovered = hovering
        }
    }

    @ViewBuilder
    private var contentView: some View {
        switch item.type {
        case .text:
            VStack(alignment: .leading, spacing: 2) {
                Text(item.previewTitle)
                    .font(.system(size: 13))
                    .lineLimit(2)
                    .foregroundColor(.primary)

                if item.lineCount > 1 || item.characterCount > 50 {
                    Text("\(item.lineCount) linhas • \(item.characterCount) caracteres")
                        .font(.system(size: 9))
                        .foregroundColor(.secondary)
                }
            }

        case .colorHex:
            HStack(spacing: 8) {
                if let hex = item.textValue, let color = ColorExtractor.color(from: hex) {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(color)
                        .frame(width: 20, height: 20)
                        .overlay(
                            RoundedRectangle(cornerRadius: 4)
                                .stroke(Color.primary.opacity(0.15), lineWidth: 1)
                        )
                }

                VStack(alignment: .leading, spacing: 2) {
                    Text(item.previewTitle)
                        .font(.system(size: 13, weight: .semibold, design: .monospaced))
                        .foregroundColor(.primary)

                    Text("Cor HEX")
                        .font(.system(size: 9))
                        .foregroundColor(.secondary)
                }
            }

        case .url:
            VStack(alignment: .leading, spacing: 2) {
                Text(item.previewTitle)
                    .font(.system(size: 13))
                    .lineLimit(1)
                    .foregroundColor(.accentColor)

                if let urlString = item.textValue, let url = URL(string: urlString), let host = url.host {
                    Text(host)
                        .font(.system(size: 9, weight: .medium))
                        .foregroundColor(.secondary)
                }
            }

        case .image:
            HStack(spacing: 8) {
                if let data = item.imageData, let nsImage = NSImage(data: data) {
                    Image(nsImage: nsImage)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 32, height: 32)
                        .clipShape(RoundedRectangle(cornerRadius: 4))
                        .overlay(
                            RoundedRectangle(cornerRadius: 4)
                                .stroke(Color.primary.opacity(0.1), lineWidth: 1)
                        )
                }

                VStack(alignment: .leading, spacing: 2) {
                    Text(item.previewTitle)
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(.primary)

                    Text(item.isScreenshot ? "Captura de tela salva" : "Imagem da área de transferência")
                        .font(.system(size: 9))
                        .foregroundColor(.secondary)
                }
            }
        }
    }

    private var backgroundColor: Color {
        if isSelected {
            return Color.accentColor.opacity(0.2)
        } else if isHovered {
            return Color.primary.opacity(0.06)
        } else {
            return Color.clear
        }
    }

    private var iconColor: Color {
        if item.isScreenshot {
            return .teal
        }
        switch item.type {
        case .text: return .secondary
        case .image: return .purple
        case .colorHex: return .pink
        case .url: return .blue
        }
    }

    private var timeString: String {
        Self.relativeDateFormatter.localizedString(for: item.createdAt, relativeTo: Date())
    }
}
