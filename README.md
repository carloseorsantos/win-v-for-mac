# 📋 Win+V for Mac

<p align="center">
  <img src="assets/logo.png" alt="Win+V for Mac Logo" width="120" />
</p>

<p align="center">
  <b>Recreate the native Windows + V clipboard history experience on macOS.</b><br>
  Built with Swift 6 & SwiftUI. Lightweight, cursor-following, instant search, and zero-latency auto-paste.
</p>

<p align="center">
  <a href="#-english"><img src="https://img.shields.io/badge/Language-English-blue.svg" alt="English"/></a>
  <a href="#-português"><img src="https://img.shields.io/badge/Idioma-Português-green.svg" alt="Português"/></a>
  <img src="https://img.shields.io/badge/Platform-macOS%2014.0%2B-lightgrey.svg" alt="macOS 14+"/>
  <img src="https://img.shields.io/badge/Swift-6.0-orange.svg" alt="Swift 6"/>
  <img src="https://img.shields.io/badge/License-MIT-green.svg" alt="License MIT"/>
</p>

---

<p align="center">
  <a href="#-english"><b>🇺🇸 English Documentation</b></a> • 
  <a href="#-português"><b>🇧🇷 Documentação em Português</b></a>
</p>

---

<a name="-english"></a>
## 🇺🇸 English

### ✨ Key Features

- **Global Cursor Popup (`⌥ + V` / Option + V):** Floating history panel appears right adjacent to your mouse cursor without moving your workflow context.
- **Smart Auto-Paste:** Selecting any item (click, `Enter`, or number keys `1-9`) instantly hides the popup and pastes into your focused application.
- **Multi-Type Content Support:**
  - **Formatted Text & Code:** Multi-line preview, character and line counts.
  - **Images:** High-res thumbnail previews for copied screenshots and images.
  - **Hex Color Codes (`#HEX`):** Automatic detection with real-time color swatch preview.
  - **Links & URLs:** Smart URL parsing with domain badges.
- **Pin Items (Favorites 📌):** Pin frequently used snippets so they are never deleted from history.
- **Instant Search:** Real-time search with category tabs (*All, Pinned, Text, Images, Links, Colors*).
- **Non-Activating HUD Design:** Uses native macOS vibrancy / blur and doesn't steal window key focus.
- **Menu Bar Companion (`MenuBarExtra`):** Lives in the menu bar with zero Dock clutter (`LSUIElement`).
- **Local Persistence & Privacy:** Stored safely on-device in `~/Library/Application Support/WinPlusV/` with configurable history limits.

---

### ⌨️ Keyboard Shortcuts

| Shortcut | Action |
| :--- | :--- |
| **`⌥ + V`** (*Option + V*) | Open / Close clipboard history at mouse cursor |
| **`1` to `9`** | Instantly paste item 1–9 |
| **`↑` / `↓`** | Navigate list items |
| **`⏎` (*Enter*)** | Paste selected item |
| **`Esc`** | Dismiss window |

---

### 🚀 Installation & Setup

#### Option 1: Automatic 1-Click Install to Applications (Recommended)

```bash
git clone git@github.com:carloseorsantos/win-v-for-mac.git
cd win-v-for-mac
./scripts/install.sh
```

This compiles in Release mode, creates the signed `.app` bundle, moves it to `/Applications/WinPlusV.app`, and launches it.

#### Option 2: Build App Bundle manually

```bash
git clone git@github.com:carloseorsantos/win-v-for-mac.git
cd win-v-for-mac
./scripts/bundle_app.sh
open dist/WinPlusV.app
```

#### Option 3: Run via Swift CLI

```bash
swift run WinPlusV
```

---

### 🔒 Accessibility Permission (For Auto-Paste)

For Win+V to simulate the `⌘ + V` keystroke into other apps, macOS requires Accessibility permission:

1. Open **System Settings** > **Privacy & Security** > **Accessibility**.
2. If `WinPlusV` is already listed from an older build, select it and click **`-` (Minus)** to remove it.
3. Click **`+` (Plus)**, navigate to `/Applications/WinPlusV.app`, and enable the toggle.
4. You can verify permission status anytime under **Menu Bar Icon > Preferences > Accessibility**.

---

<a name="-português"></a>
## 🇧🇷 Português

### ✨ Funcionalidades Principais

- **Histórico Flutuante no Cursor (`⌥ + V` / Option + V):** O menu do histórico abre exatamente ao lado do cursor do mouse, mantendo seu foco onde você estiver trabalhando.
- **Auto-Paste Inteligente:** Ao clicar em um item, pressionar `Enter` ou apertar `1-9`, o texto/imagem é colado automaticamente no aplicativo ativo.
- **Suporte Multimídia Completo:**
  - **Texto & Código:** Pré-visualização elegante com contagem de linhas e caracteres.
  - **Imagens:** Miniaturas visuais para capturas de tela e imagens copiadas.
  - **Cores Hexadecimais (`#HEX`):** Reconhece códigos hexadecimais e exibe uma amostra visual da cor.
  - **Links e URLs:** Detecção de links web com ícone e domínio.
- **Fixação de Itens (Pin 📌):** Fixe seus textos e snippets favoritos no topo para nunca serem excluídos.
- **Busca em Tempo Real:** Filtragem instantânea por texto ou por abas (*Todos, Fixados, Textos, Imagens, Links, Cores*).
- **Interface Nativa macOS:** Blur/vibrancy translúcido e janela não-ativante que não rouba o foco do cursor.
- **Barra de Menus Discreta:** Roda em segundo plano na barra de status superior, sem ocupar espaço no Dock (`LSUIElement`).
- **Armazenamento Seguro Local:** Persistência no seu Mac em `~/Library/Application Support/WinPlusV/` com limite de itens personalizável.

---

### ⌨️ Atalhos de Teclado

| Tecla / Atalho | Ação |
| :--- | :--- |
| **`⌥ + V`** (*Option + V*) | Abre ou fecha o pop-up do histórico no cursor |
| **`1` a `9`** | Cola imediatamente o item da posição correspondente |
| **`↑` / `↓`** | Navega pelos itens da lista |
| **`⏎` (*Enter*)** | Cola o item selecionado |
| **`Esc`** | Fecha a janela |

---

### 🚀 Instalação e Execução

#### Opção 1: Instalação Automática em /Applications (Recomendado)

```bash
git clone git@github.com:carloseorsantos/win-v-for-mac.git
cd win-v-for-mac
./scripts/install.sh
```

O script compilará a aplicação, assinará o pacote `.app`, moverá para `/Applications/WinPlusV.app` e iniciará o aplicativo.

#### Opção 2: Gerar pacote .app manualmente

```bash
git clone git@github.com:carloseorsantos/win-v-for-mac.git
cd win-v-for-mac
./scripts/bundle_app.sh
open dist/WinPlusV.app
```

#### Opção 3: Executar pelo terminal em modo desenvolvimento

```bash
swift run WinPlusV
```

---

### 🔒 Permissão de Acessibilidade (Para Colagem Automática)

Para que o macOS autorize o Win+V a simular o atalho de colar (`⌘ + V`):

1. Abra **Ajustes do Sistema** > **Privacidade e Segurança** > **Acessibilidade**.
2. Caso o `WinPlusV` já esteja na lista de versões anteriores, clique nele e clique no botão **`-` (Menos)** para removê-lo.
3. Clique em **`+` (Mais)**, selecione `/Applications/WinPlusV.app` e ative a chavinha.
4. Você pode confirmar o status da permissão em **Ícone da Barra de Menus > Preferências > Acessibilidade** (deve exibir o escudo verde ✅).

---

## 🏛️ Architecture & Tech Stack

```
Sources/WinPlusV/
├── App/
│   ├── WinPlusVApp.swift          # Main entrypoint with MenuBarExtra and Settings Scene
│   └── AppDelegate.swift          # AppKit lifecycle, window initialization & cleanup
├── Core/
│   ├── ClipboardMonitor.swift     # NSPasteboard observer & deduplication engine
│   ├── HotKeyManager.swift        # Global Option+V hotkey via Carbon Event API
│   ├── PasteService.swift         # Hardware-level key simulation (CGEvent / cghidEventTap)
│   ├── FloatingPanelController.swift # Non-activating NSPanel with vibrancy & mouse anchoring
│   └── StorageManager.swift       # Disk persistence (JSON), pinning & history pruning
├── Models/
│   ├── ClipboardItem.swift        # Model supporting Text, Images, Colors, URLs and Pins
│   └── AppSettings.swift          # UserDefaults preferences (auto-paste, history limits)
├── Views/
│   ├── ClipboardPopupView.swift   # Main floating popup interface with search & tabs
│   ├── ClipboardItemRow.swift     # List item row view with shortcuts and actions
│   ├── SettingsView.swift         # Preferences window (General, Accessibility, About)
│   └── MenuBarView.swift          # MenuBarExtra status item menu
└── Utilities/
    ├── CursorPositionHelper.swift # Screen-aware mouse coordinate calculation
    └── ColorExtractor.swift       # Hex color regex validator and SwiftUI color builder
```

---

## 🤝 Contributing

Contributions are very welcome! Please check out [CONTRIBUTING.md](CONTRIBUTING.md) for guidelines on submitting issues and pull requests.

---

## 📄 License

This project is licensed under the [MIT License](LICENSE).
