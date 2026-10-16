#!/bin/bash
# =============================================================================
# Script de build web - Luar Company
# Gera a versão web do aplicativo para deploy
# =============================================================================

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m'

FLUTTER_DIR="$(cd "$(dirname "$0")/../luar_company" && pwd)"

log_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERRO]${NC} $1"
    exit 1
}

# ---------------------------------------------------------------------------
# Verificar Flutter
# ---------------------------------------------------------------------------
command -v flutter &> /dev/null || log_error "Flutter não encontrado."

# ---------------------------------------------------------------------------
# Verificar se o .env existe
# ---------------------------------------------------------------------------
if [ ! -f "$FLUTTER_DIR/.env" ]; then
    log_error "Arquivo .env não encontrado. Execute: ./scripts/setup.sh"
fi

# Carregar variáveis do .env (o .env NÃO é empacotado como asset;
# os valores são injetados via --dart-define em tempo de build)
set -a
# shellcheck disable=SC1091
source "$FLUTTER_DIR/.env"
set +a

# ---------------------------------------------------------------------------
# Limpar builds anteriores
# ---------------------------------------------------------------------------
log_info "Limpando builds anteriores..."
cd "$FLUTTER_DIR"
flutter clean

# ---------------------------------------------------------------------------
# Instalar dependências
# ---------------------------------------------------------------------------
log_info "Instalando dependências..."
flutter pub get

# ---------------------------------------------------------------------------
# Habilitar build web (se necessário)
# ---------------------------------------------------------------------------
log_info "Habilitando suporte web..."
flutter config --enable-web

# ---------------------------------------------------------------------------
# Gerar build de release para web
# ---------------------------------------------------------------------------
log_info "Gerando build web de release..."
flutter build web --release \
    --dart-define=SUPABASE_URL="${SUPABASE_URL:-}" \
    --dart-define=SUPABASE_ANON_KEY="${SUPABASE_ANON_KEY:-}" \
    --dart-define=FCM_SENDER_ID="${FCM_SENDER_ID:-}" \
    --dart-define=FCM_PROJECT_ID="${FCM_PROJECT_ID:-}" \
    --dart-define=FCM_API_KEY="${FCM_API_KEY:-}" \
    --dart-define=FCM_APP_ID="${FCM_APP_ID:-}" \
    || log_error "Falha ao gerar build web."

WEB_PATH="$FLUTTER_DIR/build/web"

if [ -d "$WEB_PATH" ]; then
    WEB_SIZE=$(du -sh "$WEB_PATH" | cut -f1)
    log_info "========================================="
    log_info "Build web gerado com sucesso!"
    log_info "Diretório: $WEB_PATH"
    log_info "Tamanho: $WEB_SIZE"
    log_info "========================================="
    echo ""
    log_info "Para testar localmente:"
    log_info "  cd luar_company/build/web && python3 -m http.server 8080"
    echo ""
    log_info "Para deploy, copie o conteúdo de build/web para seu servidor."
else
    log_error "Diretório de build web não encontrado."
fi
