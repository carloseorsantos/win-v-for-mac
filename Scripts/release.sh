#!/bin/bash
set -e

# ==============================================================================
# Script: Scripts/release.sh
# Uso: ./Scripts/release.sh <versão> [mensagem_de_release]
# Exemplo: ./Scripts/release.sh 1.1.0 "Suporte a novos atalhos e melhorias no auto-paste"
# Descrição: Executa testes, atualiza versão, compila, empacota .zip e .dmg,
#            cria commit e tag do Git, e instrui sobre o push para CI/CD.
# ==============================================================================

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

cd "$PROJECT_ROOT"

# Validação do argumento de versão
if [ "$1" = "-h" ] || [ "$1" = "--help" ]; then
    echo "📖 Uso: $0 <versão> [mensagem_de_release]"
    echo "💡 Exemplo: $0 1.1.0 \"Release de melhorias e correções\""
    exit 0
fi

if [ -z "$1" ]; then
    echo "❌ Erro: Versão não informada."
    echo "📖 Uso: $0 <versão> [mensagem_de_release]"
    echo "💡 Exemplo: $0 1.1.0 \"Release de melhorias e correções\""
    exit 1
fi

VERSION="$1"
# Remove o prefixo 'v' se o usuário passar v1.2.0 em vez de 1.2.0
VERSION="${VERSION#v}"
RELEASE_MSG="${2:-Release v$VERSION}"
APP_INFO_FILE="$PROJECT_ROOT/Sources/WinPlusV/Utilities/AppInfo.swift"

echo "=========================================================="
echo "🚀 Iniciando processo de Release para versão v$VERSION"
echo "📝 Mensagem: $RELEASE_MSG"
echo "=========================================================="

# 1. Executar suíte de testes unitários
echo "🧪 Executando suíte de testes unitários..."
swift test

# 2. Atualizar constante de versão no código-fonte (AppInfo.swift)
if [ -f "$APP_INFO_FILE" ]; then
    echo "📝 Atualizando versão para $VERSION em $APP_INFO_FILE..."
    # Atualiza a linha 'public static let version = "..."'
    sed -E -i '' "s/(public static let version = \")[^\"]+(\")/\1$VERSION\2/" "$APP_INFO_FILE"
fi

# 3. Compilar e empacotar .app e .zip
echo "🔨 Compilando e empacotando bundle e .zip..."
"$SCRIPT_DIR/build.sh" "$VERSION"

# 4. Gerar instalador .dmg
echo "💿 Gerando imagem instaladora DMG..."
"$SCRIPT_DIR/create_dmg.sh"

# 5. Criar commit de bump de versão no Git
echo "📦 Registrando commit de versão no Git..."
git add "$APP_INFO_FILE"
# Se houver outros arquivos rastreados modificados para este release, adiciona também
git commit -m "release: v$VERSION" || echo "ℹ️  Nenhuma alteração pendente para commit."

# 6. Criar tag Git anotada
TAG_NAME="v$VERSION"
echo "🏷️  Criando tag anotada $TAG_NAME..."
if git rev-parse "$TAG_NAME" >/dev/null 2>&1; then
    echo "⚠️  Tag $TAG_NAME já existe localmente. Atualizando tag..."
    git tag -d "$TAG_NAME"
fi
git tag -a "$TAG_NAME" -m "$RELEASE_MSG"

echo "=========================================================="
echo "🎉 Release local v$VERSION concluído com sucesso!"
echo "=========================================================="
echo "Artefatos gerados na pasta dist/:"
ls -lh "$PROJECT_ROOT/dist"
echo ""
echo "🚀 Para publicar no GitHub e disparar a Action de Release automatizada, execute:"
echo ""
echo "    git push origin main --tags"
echo ""
echo "Isso acionará o pipeline do GitHub Actions (.github/workflows/release.yml)"
echo "que criará automaticamente a release oficial com o .dmg e o .zip anexados."
echo "=========================================================="
