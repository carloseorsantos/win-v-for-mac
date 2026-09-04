import SwiftUI

public struct SettingsView: View {
    @ObservedObject var settings = AppSettings.shared
    @ObservedObject var storage = StorageManager.shared
    @State private var showingClearConfirmation = false
    @State private var accessibilityGranted = PasteService.isAccessibilityGranted

    public init() {}

    public var body: some View {
        TabView {
            generalTab
                .tabItem {
                    Label("Geral", systemImage: "gearshape")
                }

            accessibilityTab
                .tabItem {
                    Label("Acessibilidade", systemImage: "hand.raised")
                }

            aboutTab
                .tabItem {
                    Label("Sobre", systemImage: "info.circle")
                }
        }
        .frame(width: 480, height: 340)
        .padding()
        .onAppear {
            accessibilityGranted = PasteService.isAccessibilityGranted
        }
    }

    private var generalTab: some View {
        Form {
            Section("Comportamento") {
                Toggle("Colar automaticamente ao selecionar item", isOn: $settings.autoPasteOnSelect)
                    .help("Ao clicar ou pressionar Enter em um item, o app fecha e cola automaticamente no seu aplicativo atual.")

                Toggle("Reproduzir som ao colar", isOn: $settings.playSoundOnPaste)
            }

            Section("Capturas de Tela") {
                Toggle("Salvar screenshots automaticamente no histórico", isOn: $settings.monitorScreenshots)
                    .help("Salva capturas de tela tiradas no Mac automaticamente na aba Capturas e no histórico geral.")

                if settings.monitorScreenshots {
                    VStack(alignment: .leading, spacing: 6) {
                        HStack {
                            Text("Pasta monitorada:")
                            Spacer()
                            Text(folderDisplayName)
                                .foregroundColor(.secondary)
                                .lineLimit(1)
                                .truncationMode(.middle)
                        }

                        HStack(spacing: 8) {
                            Button("Alterar Pasta...") {
                                selectCustomScreenshotFolder()
                            }
                            .buttonStyle(.bordered)

                            if settings.customScreenshotsPath != nil {
                                Button("Restaurar Padrão do macOS") {
                                    settings.customScreenshotsPath = nil
                                }
                                .buttonStyle(.borderless)
                                .foregroundColor(.accentColor)
                            }
                        }
                    }
                }
            }

            Section("Armazenamento") {
                Picker("Limite máximo de itens no histórico:", selection: $settings.maxHistoryItems) {
                    Text("50 itens").tag(50)
                    Text("100 itens").tag(100)
                    Text("200 itens").tag(200)
                    Text("500 itens").tag(500)
                    Text("1000 itens").tag(1000)
                }

                HStack {
                    Text("Itens armazenados atualmente:")
                    Spacer()
                    Text("\(storage.items.count) itens (\(storage.items.filter(\.isPinned).count) fixados)")
                        .foregroundColor(.secondary)
                }

                Button(role: .destructive) {
                    showingClearConfirmation = true
                } label: {
                    Text("Limpar Histórico (Manter Fixados)")
                }
                .confirmationDialog("Deseja realmente limpar o histórico?", isPresented: $showingClearConfirmation) {
                    Button("Limpar não fixados", role: .destructive) {
                        storage.clearHistory(preservePinned: true)
                    }
                    Button("Limpar TUDO (inclusive fixados)", role: .destructive) {
                        storage.clearHistory(preservePinned: false)
                    }
                    Button("Cancelar", role: .cancel) {}
                }
            }
        }
        .formStyle(.grouped)
    }

    private var accessibilityTab: some View {
        VStack(spacing: 20) {
            Image(systemName: accessibilityGranted ? "checkmark.shield.fill" : "exclamationmark.shield.fill")
                .font(.system(size: 48))
                .foregroundColor(accessibilityGranted ? .green : .red)

            VStack(spacing: 6) {
                Text(accessibilityGranted ? "Acessibilidade Autorizada" : "Acessibilidade Não Detectada")
                    .font(.headline)

                Text(accessibilityGranted
                     ? "O macOS concedeu permissão para o Win+V simular o atalho ⌘+V. O Auto-Paste está 100% ativo."
                     : "O macOS está bloqueando a simulação de teclas. Se o WinPlusV já estiver ativado nos Ajustes, remova-o com o botão (-) e adicione novamente.")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            }

            VStack(spacing: 10) {
                Button("Abrir Ajustes de Acessibilidade") {
                    if let url = URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_Accessibility") {
                        NSWorkspace.shared.open(url)
                    }
                }
                .buttonStyle(.borderedProminent)

                Button("🔄 Verificar Status Novamente") {
                    accessibilityGranted = AXIsProcessTrusted()
                }
                .buttonStyle(.bordered)
            }
        }
        .padding()
        .onAppear {
            accessibilityGranted = AXIsProcessTrusted()
        }
    }

    private var aboutTab: some View {
        VStack(spacing: 16) {
            if let appIcon = NSApp.applicationIconImage {
                Image(nsImage: appIcon)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 64, height: 64)
            } else {
                Image(systemName: "clipboard.fill")
                    .font(.system(size: 44))
                    .foregroundColor(.accentColor)
            }

            VStack(spacing: 4) {
                Text("Win+V for Mac")
                    .font(.title2.bold())
                Text("Versão \(AppInfo.version) (Open Source)")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            Text("Recrie a experiência ágil do Windows + V no macOS com atalho flutuante no cursor do mouse, busca instantânea, favoritos e auto-paste.")
                .font(.subheadline)
                .multilineTextAlignment(.center)
                .foregroundColor(.secondary)
                .padding(.horizontal)

            Divider()

            VStack(alignment: .leading, spacing: 4) {
                Text("Atalhos rápidos:")
                    .font(.caption.bold())
                Text("• ⌥ + V : Abrir histórico no cursor")
                    .font(.caption)
                Text("• 1 a 9 : Colar item correspondente direto")
                    .font(.caption)
                Text("• ⏎ (Enter) : Colar item selecionado")
                    .font(.caption)
                Text("• Esc : Fechar janela")
                    .font(.caption)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal)
        }
        .padding()
    }

    private var folderDisplayName: String {
        let path = settings.effectiveScreenshotsURL.path
        let desktopPath = FileManager.default.urls(for: .desktopDirectory, in: .userDomainMask).first?.path ?? ""
        if path == desktopPath {
            return "Mesa (Padrão do macOS)"
        }
        return path
    }

    private func selectCustomScreenshotFolder() {
        let panel = NSOpenPanel()
        panel.canChooseFiles = false
        panel.canChooseDirectories = true
        panel.allowsMultipleSelection = false
        panel.prompt = "Selecionar"
        panel.message = "Escolha a pasta onde suas capturas de tela são salvas"
        panel.directoryURL = settings.effectiveScreenshotsURL

        if panel.runModal() == .OK, let selectedURL = panel.url {
            settings.customScreenshotsPath = selectedURL.path
        }
    }
}
