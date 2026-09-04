import SwiftUI
import AppKit

public struct VisualEffectView: NSViewRepresentable {
    let material: NSVisualEffectView.Material
    let blendingMode: NSVisualEffectView.BlendingMode

    public init(
        material: NSVisualEffectView.Material = .hudWindow,
        blendingMode: NSVisualEffectView.BlendingMode = .behindWindow
    ) {
        self.material = material
        self.blendingMode = blendingMode
    }

    public func makeNSView(context: Context) -> NSVisualEffectView {
        let visualEffectView = NSVisualEffectView()
        visualEffectView.material = material
        visualEffectView.blendingMode = blendingMode
        visualEffectView.state = .active
        return visualEffectView
    }

    public func updateNSView(_ nsView: NSVisualEffectView, context: Context) {
        nsView.material = material
        nsView.blendingMode = blendingMode
    }
}

public enum FilterTab: String, CaseIterable, Identifiable {
    case all = "Todos"
    case pinned = "Fixados"
    case screenshots = "Capturas"
    case text = "Textos"
    case images = "Imagens"
    case urls = "Links"
    case colors = "Cores"

    public var id: String { rawValue }

    public var icon: String {
        switch self {
        case .all: return "square.grid.2x2"
        case .pinned: return "pin.fill"
        case .screenshots: return "camera"
        case .text: return "doc.text"
        case .images: return "photo"
        case .urls: return "link"
        case .colors: return "paintpalette"
        }
    }
}

public struct ClipboardPopupView: View {
    @ObservedObject var storage = StorageManager.shared
    @State private var searchText = ""
    @State private var selectedTab: FilterTab = .all
    @State private var selectedIndex = 0
    @FocusState private var isSearchFocused: Bool

    public init() {}

    private var filteredItems: [ClipboardItem] {
        var list = storage.items

        // Filter by tab
        switch selectedTab {
        case .all:
            break
        case .pinned:
            list = list.filter(\.isPinned)
        case .screenshots:
            list = list.filter(\.isScreenshot)
        case .text:
            list = list.filter { $0.type == .text }
        case .images:
            list = list.filter { $0.type == .image }
        case .urls:
            list = list.filter { $0.type == .url }
        case .colors:
            list = list.filter { $0.type == .colorHex }
        }

        // Filter by search text
        if !searchText.isEmpty {
            list = list.filter { $0.matches(query: searchText) }
        }

        return list
    }

    public var body: some View {
        VStack(spacing: 0) {
            // Search & Filter Header
            headerView
                .padding(.horizontal, 12)
                .padding(.top, 12)
                .padding(.bottom, 8)

            Divider()
                .opacity(0.4)

            // Content List or Empty State
            if filteredItems.isEmpty {
                emptyStateView
            } else {
                itemsListView
            }

            Divider()
                .opacity(0.4)

            // Footer Bar
            footerView
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
        }
        .frame(width: 380, height: 480)
        .background(
            VisualEffectView(material: .popover, blendingMode: .behindWindow)
        )
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.primary.opacity(0.12), lineWidth: 1)
        )
        .onAppear {
            isSearchFocused = true
            selectedIndex = 0
        }
        .onReceive(FloatingPanelController.shared.$isVisible) { isVisible in
            if isVisible {
                searchText = ""
                selectedIndex = 0
                isSearchFocused = true
            }
        }
    }

    // MARK: - Header
    private var headerView: some View {
        VStack(spacing: 8) {
            HStack(spacing: 8) {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.secondary)
                    .font(.system(size: 13, weight: .medium))

                TextField("Buscar no histórico...", text: $searchText)
                    .textFieldStyle(.plain)
                    .font(.system(size: 13))
                    .focused($isSearchFocused)
                    .onSubmit {
                        pasteSelectedItem()
                    }

                if !searchText.isEmpty {
                    Button(action: { searchText = "" }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.secondary)
                            .font(.system(size: 12))
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, 8)
            .padding(.vertical, 6)
            .background(Color.primary.opacity(0.06))
            .clipShape(RoundedRectangle(cornerRadius: 8))

            // Filter Tabs
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 6) {
                    ForEach(FilterTab.allCases) { tab in
                        Button(action: {
                            selectedTab = tab
                            selectedIndex = 0
                        }) {
                            HStack(spacing: 4) {
                                Image(systemName: tab.icon)
                                    .font(.system(size: 10))
                                Text(tab.rawValue)
                                    .font(.system(size: 11, weight: selectedTab == tab ? .semibold : .regular))
                            }
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(selectedTab == tab ? Color.accentColor.opacity(0.18) : Color.primary.opacity(0.04))
                            .foregroundColor(selectedTab == tab ? .accentColor : .secondary)
                            .clipShape(Capsule())
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
        }
    }

    // MARK: - Items List
    private var itemsListView: some View {
        ScrollViewReader { proxy in
            ScrollView {
                LazyVStack(spacing: 2) {
                    ForEach(Array(filteredItems.enumerated()), id: \.element.id) { index, item in
                        ClipboardItemRow(
                            item: item,
                            index: index < 9 ? index + 1 : nil,
                            isSelected: index == selectedIndex,
                            onSelect: {
                                pasteItem(item)
                            },
                            onTogglePin: {
                                storage.togglePin(id: item.id)
                            },
                            onDelete: {
                                storage.deleteItem(id: item.id)
                                if selectedIndex >= filteredItems.count {
                                    selectedIndex = max(0, filteredItems.count - 1)
                                }
                            }
                        )
                        .id(item.id)
                    }
                }
                .padding(.horizontal, 6)
                .padding(.vertical, 6)
            }
        }
    }

    // MARK: - Empty State
    private var emptyStateView: some View {
        VStack(spacing: 12) {
            Spacer()
            Image(systemName: "clipboard")
                .font(.system(size: 38))
                .foregroundColor(.secondary.opacity(0.5))

            VStack(spacing: 4) {
                Text(searchText.isEmpty ? "Histórico vazio" : "Nenhum resultado")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(.primary)

                Text(searchText.isEmpty
                     ? "Copie textos, imagens ou links para vê-los aqui."
                     : "Tente buscar por outras palavras-chave.")
                    .font(.system(size: 11))
                    .foregroundColor(.secondary)
            }
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    // MARK: - Footer
    private var footerView: some View {
        HStack {
            Text("\(filteredItems.count) itens")
                .font(.system(size: 10, weight: .medium))
                .foregroundColor(.secondary)

            Spacer()

            HStack(spacing: 10) {
                keyboardHint(symbol: "⏎", text: "Colar")
                keyboardHint(symbol: "1-9", text: "Rápido")
                keyboardHint(symbol: "Esc", text: "Fechar")
            }

            Button(action: {
                openSettings()
            }) {
                Image(systemName: "gearshape")
                    .font(.system(size: 11))
                    .foregroundColor(.secondary)
            }
            .buttonStyle(.plain)
            .help("Preferências")
        }
    }

    private func keyboardHint(symbol: String, text: String) -> some View {
        HStack(spacing: 3) {
            Text(symbol)
                .font(.system(size: 9, weight: .bold, design: .monospaced))
                .padding(.horizontal, 4)
                .padding(.vertical, 2)
                .background(Color.primary.opacity(0.08))
                .clipShape(RoundedRectangle(cornerRadius: 3))

            Text(text)
                .font(.system(size: 10))
                .foregroundColor(.secondary)
        }
    }

    // MARK: - Actions
    private func pasteSelectedItem() {
        guard !filteredItems.isEmpty else { return }
        let itemToPaste = filteredItems[min(selectedIndex, filteredItems.count - 1)]
        pasteItem(itemToPaste)
    }

    private func pasteItem(_ item: ClipboardItem) {
        FloatingPanelController.shared.hide()
        PasteService.shared.paste(item: item)
    }

    private func openSettings() {
        FloatingPanelController.shared.hide()
        NSApp.sendAction(Selector(("showSettingsWindow:")), to: nil, from: nil)
    }
}
