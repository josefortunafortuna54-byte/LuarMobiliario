# Play Store — Guia de Submissão

Ficheiros e passos para publicar a Luar Mobiliário na Google Play.

## Conteúdo desta pasta

| Ficheiro | Descrição |
|---|---|
| `listing-pt.md` | Nome, descrições e contactos (Português) |
| `listing-en.md` | Name, descriptions and contacts (English) |
| `icon-512.png` | Ícone da loja (512×512, PNG 32-bit) |
| `feature-graphic-1024x500.png` | Feature graphic (1024×500) |
| `screenshots/` | Capturas de ecrã (adicionar antes de submeter) |

## Assets obrigatórios da loja

| Asset | Especificação | Estado |
|---|---|---|
| Ícone | 512×512 PNG (32-bit, com/sem alpha) | `icon-512.png` (gerado) |
| Feature graphic | 1024×500 PNG/JPEG | `feature-graphic-1024x500.png` (gerado) |
| Capturas de telefone | 2 a 8, lado 320–3840 px, 16:9 ou 9:16 | a capturar (ver abaixo) |

## Ecrãs a capturar (recomendado)

Usar um dispositivo/emulador Android em **1080×1920** (retrato). Guardar em `screenshots/` como PNG.

1. `01-inicio.png` — **Início/Descoberta** (greeting + imóveis em destaque)
2. `02-pesquisa.png` — **Pesquisa com filtros** aplicados
3. `03-detalhe-imovel.png` — **Detalhe do imóvel** (galeria + preço + características)
4. `04-agendar-visita.png` — **Agendar visita** (data/hora + confirmação)
5. `05-favoritos.png` — **Favoritos**
6. `06-mensagens.png` — **Chat** com a equipa
7. `07-perfil.png` — **Perfil** do utilizador
8. `08-painel-admin.png` — **Painel de gestão** (agentes/admins), opcional

> Dica: esconder notificações/barra de estado sensível; não incluir dados pessoais reais.

## Data Safety (Segurança dos dados)

Respostas sugeridas para o formulário:

- **Dados recolhidos:** sim
  - *Informações pessoais* — Nome, Email, Telefone (finalidade: gestão de conta e comunicação; obrigatório; não encriptado em repouso no cliente, transmite-se por HTTPS)
  - *Mensagens* — Mensagens na app (finalidade: funcionalidade da app)
  - *Fotos e vídeos* — Fotos (finalidade: anúncios de imóveis, avatar)
  - *Informação financeira* — Não (preços de imóveis não são dados de pagamento; não há pagamentos na app)
- **Dados partilhados com terceiros:** Sim — Supabase (infraestrutura), Google Firebase (notificações). Sem venda de dados.
- **Segurança:** os dados são encriptados em trânsito; pode pedir a eliminação da conta.
- **Eliminação de dados:** disponível a pedido via geral@luarcompany.ao.

## Classificação de conteúdo

Preencher o questionário. Estimativa: **Livre / 3+** (sem violência, sexo, jogos de azar, conteúdo gerado por IA). Inclui comunicação entre utilizadores (chat) — declarar conforme aplicável.

## Passos na Play Console

1. Criar conta de programador e a aplicação.
2. Ativar **Play App Signing** (a chave `luar` é a *upload key*).
3. Preencher ficha da loja (usa `listing-pt.md` / `listing-en.md`).
4. Fazer upload do **AAB** (artefacto `luar-mobiliario-aab-<run>` do CI).
5. Preencher **Data safety**, **classificação de conteúdo** e **público-alvo**.
6. Adicionar **política de privacidade**: `https://josefortunafortuna54-byte.github.io/LuarMobiliario/privacy.html`.
7. Fornecer **acesso para revisão** (credenciais de teste do admin).
8. Testar via *Internal testing* → *Closed* → *Production*.
