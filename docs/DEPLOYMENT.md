# Guia de Deploy

Documento com as instruções para compilar e publicar a aplicação Luar Company Imobiliária em cada plataforma.

---

## Pré-requisitos

- Flutter SDK >= 3.12.1 configurado
- Conta Google Play Console (para Android)
- Conta Apple Developer (para iOS)
- Conta Supabase com o projeto configurado
- Ficheiro `.env` configurado em `luar_company/.env`

---

## Android

### Build APK (Instalação Direta)

```bash
cd luar_company
flutter build apk --release
```

O APK será gerado em: `build/app/outputs/flutter-apk/app-release.apk`

### Build AAB (Google Play)

```bash
flutter build appbundle --release
```

O AAB será gerado em: `build/app/outputs/bundle/release/app-release.aab`

### Publicação na Google Play

1. Aceda à [Google Play Console](https://play.google.com/console)
2. Crie uma nova aplicação ou selecione a existente
3. Faça upload do ficheiro `.aab`
4. Preencha as informações商店:
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

---

## iOS

### Build

```bash
cd luar_company
flutter build ios --release
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
  - `NSLocationWhenInUseUsageDescription` (para mapas)

---

## Web

### Build

```bash
cd luar_company
flutter build web --release
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
Build: flutter build web --release
Output: build/web
```

#### Servidor Próprio

Copie o conteúdo de `build/web/` para o diretório de static files do seu servidor web (nginx, Apache, etc.).

---

## Variáveis de Ambiente por Ambiente

### Produção

```env
SUPABASE_URL=https://vgwaxjxkknogmwnmuiux.supabase.co
SUPABASE_ANON_KEY=<chave-produção>
FCM_SENDER_ID=<sender-id-produção>
FCM_PROJECT_ID=<project-id-produção>
```

### Desenvolvimento

```env
SUPABASE_URL=https://seu-projeto-dev.supabase.co
SUPABASE_ANON_KEY=<chave-dev>
FCM_SENDER_ID=
FCM_PROJECT_ID=
```

---

## Checklist Pré-Deploy

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
version: 1.0.0+1
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
