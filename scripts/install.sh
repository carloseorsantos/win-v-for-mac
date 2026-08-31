#!/bin/bash
set -e

echo "🚀 Compilando e instalando Win+V em /Applications..."
./scripts/bundle_app.sh

DEST="/Applications/WinPlusV.app"

pkill -f WinPlusV || true
rm -rf "$DEST"
cp -R dist/WinPlusV.app /Applications/

# Assinar no local de destino
codesign --force --deep --sign - -i com.opensource.winplusv "$DEST"

echo "✅ Instalado com sucesso em $DEST"
echo "🚀 Abrindo Win+V..."
open "$DEST"
