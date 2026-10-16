# Luar Mobiliario

Plataforma imobiliária premium para Angola — aplicação Flutter multiplataforma (Android, iOS, Web).

## Como Executar

```bash
flutter pub get
# Injeta as variáveis de ambiente em tempo de build (o .env NÃO é empacotado)
flutter run --dart-define-from-file=.env
```

### Comandos Úteis

```bash
flutter run -d chrome --dart-define-from-file=.env   # Navegador
flutter build web --release --dart-define-from-file=.env
flutter build apk --release --dart-define-from-file=.env
flutter build ios --release --dart-define-from-file=.env
flutter test                   # Testes
flutter analyze                # Análise estática
```

## Variáveis de Ambiente

As credenciais são injetadas via `--dart-define` (o ficheiro `.env` **não** é
empacotado como asset). Crie um `.env` local (a partir de `.env.example`) com:

```env
SUPABASE_URL=https://seu-projeto.supabase.co
SUPABASE_ANON_KEY=sua-chave-anon
FCM_SENDER_ID=
FCM_PROJECT_ID=
FCM_API_KEY=
FCM_APP_ID=
```

Em builds de release os scripts (`scripts/build_*.sh`) e o CI leem os valores do
ambiente/`.env` e passam-nos via `--dart-define`, sem os incluir no bundle final.

## Arquitetura

```
UI (Screen) → Provider → Repository → Supabase Service → Supabase API
```
