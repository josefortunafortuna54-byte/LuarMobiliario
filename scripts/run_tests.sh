#!/bin/bash
# =============================================================================
# Script de testes - Luar Company
# Roda todos os testes unitários e de widget com cobertura
# =============================================================================

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

FLUTTER_DIR="$(cd "$(dirname "$0")/../luar_company" && pwd)"

log_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

log_warn() {
    echo -e "${YELLOW}[AVISO]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERRO]${NC} $1"
    exit 1
}

# ---------------------------------------------------------------------------
# Verificar Flutter
# ---------------------------------------------------------------------------
command -v flutter &> /dev/null || log_error "Flutter não encontrado."

cd "$FLUTTER_DIR"

# ---------------------------------------------------------------------------
# Verificar se existem testes
# ---------------------------------------------------------------------------
if [ ! -d "test" ] || [ -z "$(ls -A test/ 2>/dev/null)" ]; then
    log_warn "Nenhum teste encontrado em test/. Pulando execução."
    exit 0
fi

# ---------------------------------------------------------------------------
# Rodar testes com cobertura
# ---------------------------------------------------------------------------
log_info "Executando testes com cobertura de código..."
flutter test --coverage \
    || log_error "Alguns testes falharam. Verifique os erros acima."

# ---------------------------------------------------------------------------
# Gerar relatório HTML da cobertura (se lcov estiver disponível)
# ---------------------------------------------------------------------------
COVERAGE_FILE="$FLUTTER_DIR/coverage/lcov.info"

if [ -f "$COVERAGE_FILE" ] && command -v genhtml &> /dev/null; then
    log_info "Gerando relatório HTML da cobertura..."
    genhtml "$COVERAGE_FILE" -o "$FLUTTER_DIR/coverage/html" --quiet
    log_info "Relatório disponível em: coverage/html/index.html"
fi

log_info "========================================="
log_info "Testes concluídos com sucesso!"
log_info "Relatório de cobertura: coverage/lcov.info"
log_info "========================================="
