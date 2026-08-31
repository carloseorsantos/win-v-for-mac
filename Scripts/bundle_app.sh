#!/bin/bash
# Wrapper de compatibilidade legada apontando para build.sh
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
"$SCRIPT_DIR/build.sh" "$@"
