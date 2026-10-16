#!/bin/bash
# =============================================================================
# Script de build do Android App Bundle - Luar Company
# Gera o AAB para publicação na Google Play Store
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
# Gerar App Bundle de release
# ---------------------------------------------------------------------------
log_info "Gerando Android App Bundle de release..."
flutter build appbundle --release \
    --obfuscate \
    --split-debug-info=build/debug-info/aab \
    --dart-define=SUPABASE_URL="${SUPABASE_URL:-}" \
    --dart-define=SUPABASE_ANON_KEY="${SUPABASE_ANON_KEY:-}" \
    --dart-define=FCM_SENDER_ID="${FCM_SENDER_ID:-}" \
    --dart-define=FCM_PROJECT_ID="${FCM_PROJECT_ID:-}" \
    --dart-define=FCM_API_KEY="${FCM_API_KEY:-}" \
    --dart-define=FCM_APP_ID="${FCM_APP_ID:-}" \
    || log_error "Falha ao gerar App Bundle."

AAB_PATH="$FLUTTER_DIR/build/app/outputs/bundle/release/app-release.aab"

if [ -f "$AAB_PATH" ]; then
    AAB_SIZE=$(du -h "$AAB_PATH" | cut -f1)
    log_info "========================================="
    log_info "App Bundle gerado com sucesso!"
    log_info "Arquivo: $AAB_PATH"
    log_info "Tamanho: $AAB_SIZE"
    log_info "========================================="
    echo ""
    log_info "Para publicar na Play Store, use:"
    log_info "  google-play-console → Nova versão → Upload do AAB"
else
    log_error "Arquivo AAB não encontrado após build."
fi
