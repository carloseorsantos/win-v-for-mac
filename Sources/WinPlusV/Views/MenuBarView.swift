import SwiftUI
import AppKit

public struct MenuBarView: View {
    @ObservedObject var storage = StorageManager.shared

    public init() {}

    public var body: some View {
        VStack {
            Button("Abrir Histórico (⌥ + V)") {
                FloatingPanelController.shared.showNearCursor()
            }
            .keyboardShortcut("v", modifiers: [.option])

            Divider()

            if storage.items.isEmpty {
                Text("Nenhum item copiado")
                    .foregroundColor(.secondary)
            } else {
                ForEach(storage.items.prefix(5)) { item in
                    Button(action: {
                        PasteService.shared.paste(item: item)
                    }) {
                        HStack {
                            Image(systemName: item.type.systemImage)
                            Text(item.previewTitle.prefix(30))
                        }
                    }
                }
            }

            Divider()

            Button("Preferências...") {
                NSApp.sendAction(Selector(("showSettingsWindow:")), to: nil, from: nil)
                NSApp.activate(ignoringOtherApps: true)
            }
            .keyboardShortcut(",", modifiers: [.command])

            Button("Limpar Histórico") {
                storage.clearHistory(preservePinned: true)
            }

            Divider()

            Button("Encerrar Win+V") {
                NSApplication.shared.terminate(nil)
            }
            .keyboardShortcut("q", modifiers: [.command])
        }
    }
}
