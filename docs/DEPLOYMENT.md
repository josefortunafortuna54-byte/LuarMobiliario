# Guia de Deploy

Documento com as instruções para compilar e publicar a aplicação Luar Company Imobiliária em cada plataforma.

---

## Pré-requisitos

- Flutter SDK >= 3.12.1 configurado
- Conta Google Play Console (para Android)
- Conta Apple Developer (para iOS)
- Conta Supabase com o projeto configurado
- Ficheiro `.env` configurado em `luar_company/.env` (usado apenas em build via `--dart-define`; **não** é empacotado no app)

---

## Android

### Build APK (Instalação Direta)

```bash
cd luar_company
flutter build apk --release --dart-define-from-file=.env
```

O APK será gerado em: `build/app/outputs/flutter-apk/app-release.apk`

### Build AAB (Google Play)

```bash
flutter build appbundle --release --dart-define-from-file=.env
```

O AAB será gerado em: `build/app/outputs/bundle/release/app-release.aab`

> O workflow `Build & Release` (GitHub Actions) gera automaticamente um AAB assinado em cada push para `main`, disponível como artefacto `luar-mobiliario-aab-<run>`.

### Publicação na Google Play

1. Aceda à [Google Play Console](https://play.google.com/console)
2. Crie uma nova aplicação ou selecione a existente
3. Faça upload do ficheiro `.aab`
4. Preencha as informações da loja:
   - Título: "Luar Company Imobiliária"
   - Descrição curta e detalhada
   - Capturas de ecrã
   - Ícone (512x512)
   - Classificação etária
5. Configure a política de privacidade
6. Submeta para revisão

### Configuração de Assinatura

Para publicar na Play Store, configure a assinatura do APK:

```bash
# Gerar chave de assinatura (uma vez)
keytool -genkey -v -keystore luar-company-key.jks \
  -keyalg RSA -keysize 2048 -validity 10000 \
  -alias luar-company

# Criar ficheiro key.properties
cat > android/key.properties << EOF
storePassword=sua-senha
keyPassword=sua-senha
keyAlias=luar-company
storeFile=luar-company-key.jks
EOF
```

Referencie `key.properties` no `android/app/build.gradle.kts`.

### Compatibilidade e Distribuição do APK

**Requisitos mínimos do dispositivo**

| Item | Valor |
|---|---|
| Android mínimo | **7.0 (API 24)** — `minSdk` definido pelo Flutter 3.44 e exigido pelo plugin `app_links`; tentar baixar abaixo de 24 falha no manifest merge |
| ABIs incluídos | `arm64-v8a`, `armeabi-v7a`, `x86_64` (APK "fat" — cobre dispositivos 32 e 64 bits) |
| Assinatura | `android/app/android.jks` (alias `luar`) — a mesma usada localmente e no CI (secret `KEYSTORE_BASE64`) |

> **IMPORTANTE:** dispositivos com Android **inferior a 7.0** falham na primeira instalação com **"App não instalado"**. Isto não é um bug do APK — o sistema rejeita pacotes com `minSdk` superior à versão do dispositivo. Verifique a versão Android do dispositivo em **Definições → Sobre o telefone**.

**APK vs AAB — não confundir**

- Distribuição direta (loja de ficheiros/WhatsApp/site): usar **`app-release.apk`**.
- Google Play: usar **`app-release.aab`** (o AAB **não** pode ser instalado diretamente no telemóvel; tentar dá erro de parsing ou "App não instalado").

**Verificação de integridade**

O `scripts/build_apk.sh` imprime o `SHA-256` do APK gerado. Antes de instalar noutro dispositivo, confirme que o ficheiro transferido tem o mesmo tamanho e hash. Transferências truncadas (WhatsApp, Bluetooth, ligações lentas) causam "App não instalado" em alguns fabricantes.

**Troubleshooting — "App não instalado" na primeira instalação**

| Causa provável | Como confirmar | Solução |
|---|---|---|
| Android < 7.0 | Definições → Sobre o telefone | Dispositivo incompatível (mínimo Android 7.0) |
| Ficheiro corrompido/truncado | SHA-256 diferente do publicado | Re-transferir o APK (não via WhatsApp/compressão) |
| APK enviado por engano como AAB | Extensão/nome do ficheiro | Enviar `app-release.apk` |
| "Fontes desconhecidas" desativadas | Diálogo do sistema | Permitir instalação da app de ficheiros |
| Play Protect bloqueou | Diálogo "App bloqueado" | Aceitar "Instalar mesmo assim" (apenas para APKs oficiais verificados) |

> Os jobs de build do CI **falham** se os secrets de assinatura estiverem ausentes — nunca é distribuído um APK assinado com a chave de debug (que causaria conflitos de assinatura em atualizações).

---

## iOS

### Build

```bash
cd luar_company
flutter build ios --release --dart-define-from-file=.env
```

### Publicação na App Store

1. Abra o projeto no Xcode:
   ```bash
   open ios/Runner.xcworkspace
   ```
2. Configure a equipa e bundle identifier no target Runner
3. Configure ícones e splash screen
4. Selecione "Product > Archive"
5. Faça upload via Xcode Organizer
6. Aceda à [App Store Connect](https://appstoreconnect.apple.com)
7. Preencha as informações da aplicação
8. Submeta para revisão

### Configurações Necessárias

- Apple Developer Account ativa
- Bundle Identifier: `com.luarcompany.luar_company`
- Permissões no `Info.plist`:
  - `NSCameraUsageDescription` (para tirar fotos)
  - `NSPhotoLibraryUsageDescription` (para selecionar fotos)

---

## Web

### Build

```bash
cd luar_company
flutter build web --release --dart-define-from-file=.env
```

Os ficheiros serão gerados em: `build/web/`

### Deploy

#### Firebase Hosting

```bash
npm install -g firebase-tools
firebase login
firebase init  # Selecione Hosting e o diretório build/web
firebase deploy
```

#### Cloudflare Pages / Netlify / Vercel

Configure o build command:
```
Build: flutter build web --release --dart-define-from-file=.env
Output: build/web
```

#### Servidor Próprio

Copie o conteúdo de `build/web/` para o diretório de static files do seu servidor web (nginx, Apache, etc.).

---

## Variáveis de Ambiente por Ambiente

### Produção

```env
SUPABASE_URL=https://seu-projeto.supabase.co
SUPABASE_ANON_KEY=<chave-produção>
FCM_SENDER_ID=<sender-id-produção>
FCM_PROJECT_ID=<project-id-produção>
FCM_API_KEY=<api-key-produção>
FCM_APP_ID=<app-id-produção>
```

### Desenvolvimento

```env
SUPABASE_URL=https://seu-projeto-dev.supabase.co
SUPABASE_ANON_KEY=<chave-dev>
FCM_SENDER_ID=
FCM_PROJECT_ID=
FCM_API_KEY=
FCM_APP_ID=
```

---

## Checklist Pré-Deploy

- [ ] **Migrações do Supabase aplicadas** (ver [`docs/MIGRATIONS.md`](MIGRATIONS.md); estado atual: `001`–`026` aplicadas e em sync)
- [ ] Variáveis de ambiente configuradas para o ambiente alvo
- [ ] `flutter analyze` sem erros
- [ ] `flutter test` todos os testes a passar
- [ ] Ícones de aplicação configurados (Android e iOS)
- [ ] Splash screen configurado
- [ ] Nome da aplicação correto em todos os ficheiros de configuração
- [ ] Versão atualizada no `pubspec.yaml` (versão + build number)
- [ ] Bundle identifier correto (Android/iOS)
- [ ] Chave de assinatura configurada (Android)
- [ ] Permissões configuradas no AndroidManifest.xml e Info.plist
- [ ] Política de privacidade publicada
- [ ] Screenshots atualizados para as lojas
- [ ] Testado em dispositivo físico

---

## Versionamento

A versão da aplicação é definida no `pubspec.yaml`:

```yaml
version: 1.0.1+14
#         │     │
#         │     └─ Build number (incrementar a cada deploy)
#         └─ Versão semântica (major.minor.patch)
```

Incremente o build number a cada submissão às lojas. A versão semântica deve ser incrementada consoante a natureza das alterações.

---

## Rollback

Em caso de problema em produção:

1. **Android (Google Play)**: Na Play Console, faça rollback para a versão anterior na secção "Releases"
2. **iOS (App Store)**: Na App Store Connect, cancele a submissão e reative a versão anterior
3. **Web**: Redesploy da versão anterior ou restaurar backup do diretório `build/web`
