#!/bin/bash
# =============================================================================
# Script de deploy do Supabase - Luar Company
# Aplica as migrações do banco de dados no Supabase
# =============================================================================

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
SUPABASE_DIR="$ROOT_DIR/luar_company/supabase"
MIGRATIONS_DIR="$SUPABASE_DIR/migrations"

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
# Verificar se o Supabase CLI está instalado
# ---------------------------------------------------------------------------
if ! command -v supabase &> /dev/null; then
    log_error "Supabase CLI não encontrado. Instale: https://supabase.com/docs/guides/cli"
fi

SUPABASE_VERSION=$(supabase --version 2>/dev/null | head -1)
log_info "Supabase CLI: $SUPABASE_VERSION"

# ---------------------------------------------------------------------------
# Verificar se existem migrações
# ---------------------------------------------------------------------------
if [ ! -d "$MIGRATIONS_DIR" ] || [ -z "$(ls -A "$MIGRATIONS_DIR" 2>/dev/null)" ]; then
    log_warn "Nenhuma migração encontrada em: $MIGRATIONS_DIR"
    exit 0
fi

MIGRATION_COUNT=$(ls -1 "$MIGRATIONS_DIR"/*.sql 2>/dev/null | wc -l)
log_info "Migrações encontradas: $MIGRATION_COUNT"

# ---------------------------------------------------------------------------
# Verificar se está logado no Supabase
# ---------------------------------------------------------------------------
log_info "Verificando autenticação do Supabase..."
if ! supabase projects list &> /dev/null 2>&1; then
    log_error "Não autenticado. Execute: supabase login"
fi

# ---------------------------------------------------------------------------
# Linkar ao projeto (se necessário)
# ---------------------------------------------------------------------------
if [ ! -f "$SUPABASE_DIR/config.toml" ]; then
    log_warn "Projeto não linkado. Execute manualmente:"
    log_warn "  cd luar_company/supabase && supabase link --project-ref <SEU-PROJECT-REF>"
    log_error "Link o projeto antes de aplicar migrações."
fi

# ---------------------------------------------------------------------------
# Aplicar migrações
# ---------------------------------------------------------------------------
log_info "Aplicando migrações do banco de dados..."
cd "$ROOT_DIR/luar_company"
supabase db push \
    || log_error "Falha ao aplicar migrações."

log_info "========================================="
log_info "Migrações aplicadas com sucesso!"
log_info "========================================="
echo ""
log_info "Para verificar o estado do banco:"
log_info "  supabase db diff"
echo ""
