#!/bin/bash
set -e

echo "🔨 Compilando Win+V for Mac em modo Release..."
swift build -c release

APP_NAME="WinPlusV"
BUILD_DIR=".build/release"
DIST_DIR="dist"
BUNDLE_DIR="$DIST_DIR/$APP_NAME.app"
CONTENTS_DIR="$BUNDLE_DIR/Contents"
MACOS_DIR="$CONTENTS_DIR/MacOS"
RESOURCES_DIR="$CONTENTS_DIR/Resources"

echo "📦 Criando bundle da aplicação em $BUNDLE_DIR..."
mkdir -p "$DIST_DIR"
rm -rf "$BUNDLE_DIR"
mkdir -p "$MACOS_DIR"
mkdir -p "$RESOURCES_DIR"

# Copiar executável e recursos
cp "$BUILD_DIR/$APP_NAME" "$MACOS_DIR/$APP_NAME"
if [ -f "assets/AppIcon.icns" ]; then
    cp "assets/AppIcon.icns" "$RESOURCES_DIR/AppIcon.icns"
fi

# Criar Info.plist
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
    <string>com.opensource.winplusv</string>
    <key>CFBundleName</key>
    <string>Win+V for Mac</string>
    <key>CFBundleDisplayName</key>
    <string>Win+V</string>
    <key>CFBundlePackageType</key>
    <string>APPL</string>
    <key>CFBundleShortVersionString</key>
    <string>1.0.0</string>
    <key>CFBundleVersion</key>
    <string>1</string>
    <key>LSMinimumSystemVersion</key>
    <string>14.0</string>
    <key>LSUIElement</key>
    <true/>
    <key>NSHighResolutionCapable</key>
    <true/>
    <key>NSSupportsAutomaticGraphicsSwitching</key>
    <true/>
</dict>
</plist>
EOF

echo "🔏 Assinando o App Bundle com assinatura ad-hoc..."
codesign --force --deep --sign - -i com.opensource.winplusv "$BUNDLE_DIR"

echo "✅ App Bundle criado e assinado com sucesso: $BUNDLE_DIR"
echo "🚀 Para executar o app, use: open $BUNDLE_DIR"
