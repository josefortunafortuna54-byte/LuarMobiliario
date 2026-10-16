#!/bin/bash
# =============================================================================
# Script de configuração do projeto Luar Company Flutter
# Configura o ambiente de desenvolvimento completo
# =============================================================================

set -e

# Cores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Diretório do projeto Flutter
FLUTTER_DIR="$(cd "$(dirname "$0")/../luar_company" && pwd)"
ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"

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
# 1. Verificar se o Flutter está instalado
# ---------------------------------------------------------------------------
log_info "Verificando instalação do Flutter..."
if ! command -v flutter &> /dev/null; then
    log_error "Flutter não encontrado. Instale: https://flutter.dev/docs/get-started/install"
fi

FLUTTER_VERSION=$(flutter --version 2>/dev/null | head -1)
log_info "Flutter encontrado: $FLUTTER_VERSION"

# ---------------------------------------------------------------------------
# 2. Copiar .env.example para .env (se não existir)
# ---------------------------------------------------------------------------
ENV_FILE="$FLUTTER_DIR/.env"
ENV_EXAMPLE="$ROOT_DIR/.env.example"

if [ ! -f "$ENV_FILE" ]; then
    if [ -f "$ENV_EXAMPLE" ]; then
        log_info "Criando arquivo .env a partir do .env.example..."
        cp "$ENV_EXAMPLE" "$ENV_FILE"
        log_warn "Arquivo .env criado. Edite-o em: $ENV_FILE"
        log_warn "Preencha SUPABASE_URL, SUPABASE_ANON_KEY e outras variáveis."
    else
        log_warn "Arquivo .env.example não encontrado. Pulando cópia."
    fi
else
    log_info "Arquivo .env já existe."
fi

# ---------------------------------------------------------------------------
# 3. Instalar dependências do Flutter
# ---------------------------------------------------------------------------
log_info "Instalando dependências (flutter pub get)..."
cd "$FLUTTER_DIR"
flutter pub get || log_error "Falha ao instalar dependências."
log_info "Dependências instaladas com sucesso."

# ---------------------------------------------------------------------------
# 4. Rodar análise estática do código
# ---------------------------------------------------------------------------
log_info "Executando flutter analyze..."
flutter analyze || log_warn "Análise encontrou problemas. Verifique os warnings acima."

log_info "========================================="
log_info "Configuração concluída com sucesso!"
log_info "========================================="
echo ""
log_info "Próximos passos:"
log_info "  1. Edite o arquivo .env com suas credenciais"
log_info "  2. Execute: ./scripts/run_tests.sh (para rodar testes)"
log_info "  3. Execute: ./scripts/build_apk.sh (para gerar APK)"
echo ""
