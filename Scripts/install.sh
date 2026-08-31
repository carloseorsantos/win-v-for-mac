#!/bin/bash
set -e

# ==============================================================================
# Script: Scripts/install.sh
# Descrição: Compila, assina com certificado ad-hoc, instala em /Applications,
#            remove quarentena do Gatekeeper e inicia a aplicação.
# ==============================================================================

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

cd "$PROJECT_ROOT"

APP_NAME="WinPlusV"
BUNDLE_ID="com.opensource.winplusv"
DIST_DIR="$PROJECT_ROOT/dist"
BUNDLE_DIR="$DIST_DIR/$APP_NAME.app"
DEST_PATH="/Applications/$APP_NAME.app"

echo "=========================================================="
echo "🚀 Iniciando instalação local do $APP_NAME em /Applications..."
echo "=========================================================="

# 1. Compilar e empacotar
"$SCRIPT_DIR/build.sh"

# 2. Limpar atributos de quarentena e assinar o bundle compilado
echo "🧹 Limpando atributos estendidos de quarentena..."
xattr -cr "$BUNDLE_DIR" || true
codesign --force --deep --sign - -i "$BUNDLE_ID" "$BUNDLE_DIR"

# 3. Finalizar processo em execução se existir
if pgrep -x "$APP_NAME" > /dev/null 2>&1; then
    echo "🛑 Finalizando instância em execução do $APP_NAME..."
    pkill -x "$APP_NAME" || true
    sleep 0.5
fi

# 4. Remover versão anterior em /Applications e copiar nova versão
echo "📂 Copiando para $DEST_PATH..."
rm -rf "$DEST_PATH"
cp -R "$BUNDLE_DIR" /Applications/

# 5. Limpar quarentena e assinar ad-hoc no diretório final de instalação
echo "🔏 Aplicando permissões e assinatura final em $DEST_PATH..."
xattr -cr "$DEST_PATH" || true
codesign --force --deep --sign - -i "$BUNDLE_ID" "$DEST_PATH"
xattr -cr "$DEST_PATH" || true

echo "=========================================================="
echo "✅ $APP_NAME instalado com sucesso em $DEST_PATH!"
echo "🚀 Abrindo aplicativo..."
echo "=========================================================="

open "$DEST_PATH"
