#!/bin/bash
set -e

# ==============================================================================
# Script: Scripts/create_dmg.sh
# Descrição: Gera a imagem de disco instaladora (.dmg) com suporte a instalação
#            drag-and-drop para a pasta /Applications.
# ==============================================================================

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

cd "$PROJECT_ROOT"

APP_NAME="WinPlusV"
APP_DISPLAY_NAME="Win+V for Mac"
BUNDLE_ID="com.opensource.winplusv"
DIST_DIR="$PROJECT_ROOT/dist"
BUNDLE_DIR="$DIST_DIR/$APP_NAME.app"
DMG_PATH="$DIST_DIR/$APP_NAME-macOS.dmg"

# Se o bundle .app ainda não existir, executa o build primeiro
if [ ! -d "$BUNDLE_DIR" ]; then
    echo "ℹ️  Bundle $BUNDLE_DIR não encontrado. Executando build..."
    "$SCRIPT_DIR/build.sh"
fi

echo "=========================================================="
echo "💿 Gerando instalador DMG para $APP_DISPLAY_NAME..."
echo "=========================================================="

# Criar diretório temporário para staging do DMG
STAGING_DIR=$(mktemp -d /tmp/winplusv_dmg_staging.XXXXXX)

# Garantir limpeza do diretório de staging ao encerrar o script
cleanup() {
    if [ -d "$STAGING_DIR" ]; then
        rm -rf "$STAGING_DIR"
    fi
}
trap cleanup EXIT

echo "📁 Preparando ambiente de staging em $STAGING_DIR..."
cp -R "$BUNDLE_DIR" "$STAGING_DIR/"
ln -s /Applications "$STAGING_DIR/Applications"

# Limpar atributos estendidos e reafirmar assinatura ad-hoc no staging
xattr -cr "$STAGING_DIR/$APP_NAME.app" || true
codesign --force --deep --sign - -i "$BUNDLE_ID" "$STAGING_DIR/$APP_NAME.app"

# Remover DMG anterior se já existir
rm -f "$DMG_PATH"

echo "⚙️  Criando imagem comprimida (UDZO) com hdiutil..."
hdiutil create \
    -volname "$APP_DISPLAY_NAME" \
    -srcfolder "$STAGING_DIR" \
    -ov \
    -format UDZO \
    "$DMG_PATH"

echo "=========================================================="
echo "✅ Instalador DMG gerado com sucesso!"
echo "📍 Arquivo: $DMG_PATH"
if [ -f "$DMG_PATH" ]; then
    DMG_SIZE=$(du -h "$DMG_PATH" | cut -f1)
    echo "📊 Tamanho: $DMG_SIZE"
fi
echo "=========================================================="
