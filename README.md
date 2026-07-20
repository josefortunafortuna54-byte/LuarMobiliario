# Luar Mobiliario

Plataforma imobiliária premium para Angola — aplicação Flutter multiplataforma (Android, iOS, Web).

## Como Executar

```bash
flutter pub get
flutter run
```

### Comandos Úteis

```bash
flutter run -d chrome          # Navegador
flutter build web --release    # Build Web
flutter build apk --release    # Build APK Android
flutter build ios --release    # Build iOS
flutter test                   # Testes
flutter analyze                # Análise estática
```

## Variáveis de Ambiente

O ficheiro `.env` deve conter:

```env
SUPABASE_URL=https://seu-projeto.supabase.co
SUPABASE_ANON_KEY=sua-chave-anon
FCM_SENDER_ID=
FCM_PROJECT_ID=
```

## Arquitetura

```
UI (Screen) → Provider → Repository → Supabase Service → Supabase API
```
