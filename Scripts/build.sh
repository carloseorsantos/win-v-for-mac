#!/bin/bash
set -e

# ==============================================================================
# Script: Scripts/build.sh
# Descrição: Compila o projeto em modo Release, monta o Bundle .app do macOS,
#            assina com certificado ad-hoc e gera o pacote .zip para distribuição.
# ==============================================================================

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

cd "$PROJECT_ROOT"

APP_NAME="WinPlusV"
APP_DISPLAY_NAME="Win+V for Mac"
BUNDLE_ID="com.opensource.winplusv"
MIN_MACOS_VERSION="14.0"

# Extrair versão do AppInfo.swift ou usar parâmetro/fallback
APP_INFO_FILE="$PROJECT_ROOT/Sources/WinPlusV/Utilities/AppInfo.swift"
if [ -n "$1" ]; then
    VERSION="$1"
elif [ -f "$APP_INFO_FILE" ]; then
    VERSION=$(grep -E 'static let version' "$APP_INFO_FILE" | sed -E 's/.*"([^"]+)".*/\1/' | head -n 1)
fi
VERSION="${VERSION:-1.0.0}"

BUILD_NUMBER="1"
if [ -f "$APP_INFO_FILE" ]; then
    BUILD_NUMBER=$(grep -E 'static let buildNumber' "$APP_INFO_FILE" | sed -E 's/.*"([^"]+)".*/\1/' | head -n 1)
fi
BUILD_NUMBER="${BUILD_NUMBER:-1}"

echo "=========================================================="
echo "🔨 Compilando $APP_DISPLAY_NAME v$VERSION em modo Release..."
echo "=========================================================="

swift build -c release

BUILD_BIN="$PROJECT_ROOT/.build/release/$APP_NAME"
if [ ! -f "$BUILD_BIN" ]; then
    echo "❌ Erro: Binário compilado não foi encontrado em: $BUILD_BIN"
    exit 1
fi

DIST_DIR="$PROJECT_ROOT/dist"
BUNDLE_DIR="$DIST_DIR/$APP_NAME.app"
CONTENTS_DIR="$BUNDLE_DIR/Contents"
MACOS_DIR="$CONTENTS_DIR/MacOS"
RESOURCES_DIR="$CONTENTS_DIR/Resources"
ZIP_PATH="$DIST_DIR/$APP_NAME.zip"

echo "📦 Estruturando macOS App Bundle em $BUNDLE_DIR..."
mkdir -p "$DIST_DIR"
rm -rf "$BUNDLE_DIR"
mkdir -p "$MACOS_DIR"
mkdir -p "$RESOURCES_DIR"

# 1. Copiar binário executável e definir permissões
cp "$BUILD_BIN" "$MACOS_DIR/$APP_NAME"
chmod +x "$MACOS_DIR/$APP_NAME"

# 2. Copiar ícones de recursos se existirem
if [ -f "$PROJECT_ROOT/assets/AppIcon.icns" ]; then
    cp "$PROJECT_ROOT/assets/AppIcon.icns" "$RESOURCES_DIR/AppIcon.icns"
fi

# 3. Gerar Info.plist com metadados do macOS
cat <<EOF > "$CONTENTS_DIR/Info.plist"
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>CFBundleExecutable</key>
    <string>$APP_NAME</string>
    <key>CFBundleIconFile</key>
    <string>AppIcon</string>
    <key>CFBundleIconName</key>
    <string>AppIcon</string>
    <key>CFBundleIdentifier</key>
    <string>$BUNDLE_ID</string>
    <key>CFBundleName</key>
    <string>$APP_DISPLAY_NAME</string>
    <key>CFBundleDisplayName</key>
    <string>$APP_NAME</string>
    <key>CFBundlePackageType</key>
    <string>APPL</string>
    <key>CFBundleShortVersionString</key>
    <string>$VERSION</string>
    <key>CFBundleVersion</key>
    <string>$BUILD_NUMBER</string>
    <key>LSMinimumSystemVersion</key>
    <string>$MIN_MACOS_VERSION</string>
    <key>LSUIElement</key>
    <true/>
    <key>NSHighResolutionCapable</key>
    <true/>
    <key>NSSupportsAutomaticGraphicsSwitching</key>
    <true/>
</dict>
</plist>
EOF

# 4. Limpar atributos de quarentena e assinar com assinatura ad-hoc
echo "🔏 Aplicando assinatura ad-hoc no pacote..."
xattr -cr "$BUNDLE_DIR" || true
codesign --force --deep --sign - -i "$BUNDLE_ID" "$BUNDLE_DIR"

# 5. Compactar bundle .app em .zip com ditto mantendo metadados do macOS
echo "🗜️  Criando arquivo compactado $ZIP_PATH..."
rm -f "$ZIP_PATH"
export COPYFILE_DISABLE=1
ditto -c -k --keepParent --noextattr --norsrc "$BUNDLE_DIR" "$ZIP_PATH"

echo "=========================================================="
echo "✅ Build e empacotamento concluídos com sucesso!"
echo "📍 Bundle .app: $BUNDLE_DIR"
echo "📍 Pacote .zip: $ZIP_PATH"
echo "=========================================================="
