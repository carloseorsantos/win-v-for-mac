# 📋 Win+V for Mac (Português)

<p align="center">
  <img src="assets/logo.png" alt="Win+V for Mac Logo" width="120" />
</p>

<p align="center">
  <b>Recrie a experiência nativa do Windows + V de histórico da área de transferência no macOS.</b><br>
  Desenvolvido em Swift 6 & SwiftUI. Leve, posicionado junto ao cursor, busca instantânea e colagem automática sem latência.
</p>

<p align="center">
  <a href="https://github.com/carloseorsantos/win-v-for-mac/releases/latest/download/WinPlusV-macOS.dmg">
    <img src="https://img.shields.io/badge/Download-DMG%20(Instalador%201--Clique)-007AFF?style=for-the-badge&logo=apple&logoColor=white" alt="Download DMG"/>
  </a>
</p>

<p align="center">
  <a href="README.md"><img src="https://img.shields.io/badge/Language-English-blue.svg" alt="English"/></a>
  <a href="README.pt-BR.md"><img src="https://img.shields.io/badge/Idioma-Português-green.svg" alt="Português"/></a>
  <a href="https://github.com/carloseorsantos/win-v-for-mac/releases/latest"><img src="https://img.shields.io/github/v/release/carloseorsantos/win-v-for-mac?label=Release&color=blue" alt="Release"/></a>
  <img src="https://img.shields.io/badge/Plataforma-macOS%2014.0%2B-lightgrey.svg" alt="macOS 14+"/>
  <img src="https://img.shields.io/badge/Swift-6.0-orange.svg" alt="Swift 6"/>
  <img src="https://img.shields.io/badge/Licença-MIT-green.svg" alt="Licença MIT"/>
</p>

---

<p align="center">
  <a href="README.md"><b>🇺🇸 English Documentation</b></a> • 
  <b>🇧🇷 Documentação em Português</b>
</p>

---

## ✨ Funcionalidades Principais

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

## ⌨️ Atalhos de Teclado

| Tecla / Atalho | Ação |
| :--- | :--- |
| **`⌥ + V`** (*Option + V*) | Abre ou fecha o pop-up do histórico no cursor |
| **`1` a `9`** | Cola imediatamente o item da posição correspondente |
| **`↑` / `↓`** | Navega pelos itens da lista |
| **`⏎` (*Enter*)** | Cola o item selecionado |
| **`Esc`** | Fecha a janela |

---

## 🚀 Instalação e Execução

### Opção 1: Download Direto do `.dmg` (Recomendado para Usuários)

Instale sem precisar de Xcode ou comandos no terminal:

1. **[Baixar o instalador `WinPlusV-macOS.dmg`](https://github.com/carloseorsantos/win-v-for-mac/releases/latest/download/WinPlusV-macOS.dmg)**
2. Dê um duplo-clique no arquivo `.dmg` baixado para abri-lo.
3. Arraste o ícone do **WinPlusV** para a pasta **Aplicativos** (`Applications`).
4. Abra o **WinPlusV** pelo Launchpad, Spotlight (`⌘ + Espaço`) ou pela pasta Aplicativos.

> [!TIP]
> Na primeira abertura, caso o macOS pergunte sobre aplicativo de desenvolvedor não identificado, basta clicar com o botão direito (ou Control + clique) no `WinPlusV.app` dentro de `/Applications` e selecionar **Abrir**.

---

### Opção 2: Compilar via Código-Fonte (Para Desenvolvedores)

Você pode compilar, assinar localmente com certificado ad-hoc e instalar diretamente pelo terminal:

```bash
# 1. Clonar o repositório
git clone https://github.com/carloseorsantos/win-v-for-mac.git
cd win-v-for-mac

# 2. Compilar, assinar e instalar em /Applications com 1 comando
./Scripts/install.sh
```

#### Outros Scripts Úteis de Desenvolvimento

- **Gerar Bundle `.app` e arquivo `.zip`:**
  ```bash
  ./Scripts/build.sh
  ```
- **Gerar Instalador `.dmg` localmente:**
  ```bash
  ./Scripts/create_dmg.sh
  ```
- **Executar Testes Unitários:**
  ```bash
  swift test
  ```
- **Executar em Modo Desenvolvimento:**
  ```bash
  swift run WinPlusV
  ```
- **Criar Release Automatizado:**
  ```bash
  ./Scripts/release.sh 1.1.0 "Descrição das novidades da versão"
  ```

---

## 🔒 Permissão de Acessibilidade (Para Colagem Automática)

Para que o macOS autorize o Win+V a simular o atalho de colar (`⌘ + V`):

1. Abra **Ajustes do Sistema** > **Privacidade e Segurança** > **Acessibilidade**.
2. Caso o `WinPlusV` já esteja na lista de versões anteriores, clique nele e clique no botão **`-` (Menos)** para removê-lo.
3. Clique em **`+` (Mais)**, selecione `/Applications/WinPlusV.app` e ative a chavinha.
4. Você pode confirmar o status da permissão em **Ícone da Barra de Menus > Preferências > Acessibilidade** (deve exibir o escudo verde ✅).

---

## 🏛️ Arquitetura do Projeto

```
Sources/WinPlusV/
├── App/
│   ├── WinPlusVApp.swift          # Ponto de entrada com MenuBarExtra e Scene de Ajustes
│   └── AppDelegate.swift          # Ciclo de vida AppKit, gerenciamento e cleanup de janelas
├── Core/
│   ├── ClipboardMonitor.swift     # Observador de NSPasteboard e motor de deduplicação
│   ├── HotKeyManager.swift        # Atalho global Option+V via Carbon Event API
│   ├── PasteService.swift         # Simulação de teclas via hardware (CGEvent / cghidEventTap)
│   ├── FloatingPanelController.swift # NSPanel não-ativante com vibrancy e ancoragem ao mouse
│   └── StorageManager.swift       # Persistência em disco (JSON), favoritos e poda do histórico
├── Models/
│   ├── ClipboardItem.swift        # Modelo para Texto, Imagens, Cores, URLs e Favoritos
│   └── AppSettings.swift          # Preferências do UserDefaults (auto-paste, limites)
├── Views/
│   ├── ClipboardPopupView.swift   # Interface flutuante principal com busca e abas
│   ├── ClipboardItemRow.swift     # Linha de item do histórico com atalhos numéricos
│   ├── SettingsView.swift         # Janela de Ajustes (Geral, Acessibilidade, Sobre)
│   └── MenuBarView.swift          # Menu do status item na barra de menus
└── Utilities/
    ├── AppInfo.swift              # Constantes de versão e metadados do app
    ├── CursorPositionHelper.swift # Cálculo de coordenadas do mouse respeitando telas
    └── ColorExtractor.swift       # Validador de regex hex e construtor SwiftUI Color
```

---

## 🤝 Contribuições

Contribuições são muito bem-vindas! Consulte o arquivo [CONTRIBUTING.md](CONTRIBUTING.md) para diretrizes sobre abertura de issues e envio de pull requests.

---

## 📄 Licença

Este projeto é distribuído sob a licença [MIT License](LICENSE).
