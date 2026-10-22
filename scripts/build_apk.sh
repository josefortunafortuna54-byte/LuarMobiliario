#!/bin/bash
# =============================================================================
# Script de build do APK - Luar Company
# Gera o arquivo APK de release para distribuição
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

# ---------------------------------------------------------------------------
# Verificar assinatura de release (evita "App não instalado" por assinatura)
# ---------------------------------------------------------------------------
if [ ! -f "$FLUTTER_DIR/android/key.properties" ] || [ ! -f "$FLUTTER_DIR/android/app/android.jks" ]; then
    log_error "Assinatura de release ausente (key.properties e/ou android.jks). Um APK assinado com a chave de debug não pode ser atualizado nem instalado sobre versões assinadas com a chave de release."
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
# Gerar APK de release
# ---------------------------------------------------------------------------
log_info "Gerando APK de release..."
flutter build apk --release \
    --obfuscate \
    --split-debug-info=build/debug-info/apk \
    --dart-define=SUPABASE_URL="${SUPABASE_URL:-}" \
    --dart-define=SUPABASE_ANON_KEY="${SUPABASE_ANON_KEY:-}" \
    --dart-define=FCM_SENDER_ID="${FCM_SENDER_ID:-}" \
    --dart-define=FCM_PROJECT_ID="${FCM_PROJECT_ID:-}" \
    --dart-define=FCM_API_KEY="${FCM_API_KEY:-}" \
    --dart-define=FCM_APP_ID="${FCM_APP_ID:-}" \
    || log_error "Falha ao gerar APK."

APK_PATH="$FLUTTER_DIR/build/app/outputs/flutter-apk/app-release.apk"

if [ -f "$APK_PATH" ]; then
    APK_SIZE=$(du -h "$APK_PATH" | cut -f1)
    APK_SHA256=$(sha256sum "$APK_PATH" | cut -d' ' -f1)

    log_info "========================================="
    log_info "APK gerado com sucesso!"
    log_info "Arquivo: $APK_PATH"
    log_info "Tamanho: $APK_SIZE"
    log_info "SHA-256: $APK_SHA256"
    log_info "========================================="
    log_info "Verifique a integridade no dispositivo com o mesmo SHA-256"
    log_info "(o ficheiro deve ter exatamente $APK_SIZE; transferências"
    log_info "truncadas via WhatsApp/Bluetooth causam 'App não instalado')."

    # Metadados: versão, ABIs e assinatura (quando Android SDK disponível)
    BUILD_TOOLS_DIR="$(ls -d "${ANDROID_HOME:-$HOME/Android/Sdk}"/build-tools/*/ 2>/dev/null | sort -V | tail -1)"
    if [ -n "$BUILD_TOOLS_DIR" ] && [ -x "${BUILD_TOOLS_DIR}aapt2" ]; then
        BADGING=$("${BUILD_TOOLS_DIR}aapt2" dump badging "$APK_PATH" 2>/dev/null | grep -E "^package:|^minSdkVersion|^targetSdkVersion" | head -3)
        [ -n "$BADGING" ] && log_info "Pacote: $(echo "$BADGING" | tr '\n' ' ')"
        ABIS=$(unzip -l "$APK_PATH" | grep -oE "lib/[^/]+/" | sort -u | tr '\n' ' ')
        [ -n "$ABIS" ] && log_info "ABIs: $ABIS"
    fi
    if [ -n "$BUILD_TOOLS_DIR" ] && [ -x "${BUILD_TOOLS_DIR}apksigner" ]; then
        SIGNER=$("${BUILD_TOOLS_DIR}apksigner" verify --print-certs "$APK_PATH" 2>/dev/null | grep "SHA-256 digest" | head -1)
        [ -n "$SIGNER" ] && log_info "Assinatura: $SIGNER"
    fi

    # Compatibilidade: minSdk 24 = Android 7.0+; instalação em Android < 7
    # falha com "App não instalado".
    log_info "Requisito: Android 7.0 ou superior (minSdk 24)"
    log_info "========================================="
else
    log_error "Arquivo APK não encontrado após build."
fi
