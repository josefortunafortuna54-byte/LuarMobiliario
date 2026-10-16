# Documentação de Segurança

Documento com as práticas de segurança, políticas e recomendações para a plataforma Luar Company Imobiliária.

---

## Visão Geral

A segurança da plataforma é garantida por uma combinação de:

- Supabase Row Level Security (RLS)
- Autenticação via Supabase Auth
- Variáveis de ambiente para chaves sensíveis
- Boas práticas de desenvolvimento Flutter

---

## Autenticação

### Supabase Auth

- Autenticação por email/senha gerida pelo Supabase Auth
- As passwords são hasheadas e armazenadas no Supabase (nunca na nossa base de dados)
- Sessões geridas automaticamente pelo SDK Flutter
- Tokens JWT expiram e são renovados automaticamente

### Práticas

- Nunca armazenar passwords em texto plano
- Nunca transmitir credenciais em texto plano (HTTPS obrigatório)
- Utilizar sempre `SUPABASE_ANON_KEY` (nunca a `service_role` key no cliente)
- Implementar rate limiting no Supabase para prevenir abusos

---

## Variáveis de Ambiente

### Regras

- **Nunca** fazer commit de ficheiros `.env` ao repositório
- O ficheiro `.env` deve estar no `.gitignore`
- Usar apenas o `.env.example` como referência (sem valores reais)
- Chaves de produção devem ser geridas apenas em ambiente seguro

### Chaves Supabase

| Chave | Uso | Onde usar |
|---|---|---|
| `anon` | Acesso público (com RLS) | Aplicação Flutter |
| `service_role` | Acesso admin (ignora RLS) | Apenas no servidor/Admin |

**IMPORTANTE**: A chave `service_role` deve ser usada apenas no Supabase Dashboard ou em scripts de backend. Nunca na aplicação Flutter.

---

## Row Level Security (RLS)

RLS é a primeira linha de defesa na base de dados. Deve ser ativado em todas as tabelas.

### Princípios

1. **Privilégio mínimo**: Cada utilizador deve ter acesso apenas aos seus dados
2. **RLS ativado por defeito**: Todas as novas tabelas devem ter RLS ativo
3. **Políticas explícitas**: Cada operação deve ter uma política correspondente

### Políticas Implementadas

> Conforme `supabase/migrations/002_rls_role_based_policies.sql`, refinadas ao longo das migrações até à `026` (destacam-se a 018 — base de segurança/confiança — e a 021 — correções app↔BD). O `id` da tabela `users` coincide com `auth.uid()`. O role é obtido pela função helper `public.get_user_role()`.

#### Tabela `users`

```sql
-- Leitura: o próprio utilizador ou admin (evita expor PII publicamente)
CREATE POLICY "Users: read own or admin" ON users
  FOR SELECT USING (auth.uid() = id OR public.get_user_role() = 'admin');

-- Inserção: ao registar, o utilizador cria o seu próprio perfil
CREATE POLICY "Users: insert own" ON users
  FOR INSERT WITH CHECK (auth.uid() = id);

-- Atualização: o próprio perfil (role só alterável por admin — trigger prevent_role_change)
CREATE POLICY "Users: update own profile" ON users
  FOR UPDATE USING (auth.uid() = id);

-- Admin gere tudo
CREATE POLICY "Users: admin full access" ON users
  FOR ALL USING (public.get_user_role() = 'admin');
```

#### Tabela `properties`

```sql
-- Leitura pública
CREATE POLICY "Properties: public read" ON properties
  FOR SELECT USING (true);

-- Agentes e admins criam
CREATE POLICY "Properties: agents and admins insert" ON properties
  FOR INSERT WITH CHECK (public.get_user_role() IN ('agent', 'admin'));

-- Agente dono ou admin atualizam; WITH CHECK impede a reatribuição de agent_id
CREATE POLICY "Properties: update own or admin" ON properties
  FOR UPDATE USING (auth.uid() = agent_id OR public.get_user_role() = 'admin')
  WITH CHECK (public.get_user_role() = 'admin' OR auth.uid() = agent_id);

-- Eliminação apenas por admin
CREATE POLICY "Properties: admin delete" ON properties
  FOR DELETE USING (public.get_user_role() = 'admin');
```

#### Tabela `lands`

```sql
CREATE POLICY "Lands: public read" ON lands FOR SELECT USING (true);
CREATE POLICY "Lands: agents and admins insert" ON lands
  FOR INSERT WITH CHECK (public.get_user_role() IN ('agent', 'admin'));
CREATE POLICY "Lands: update own or admin" ON lands
  FOR UPDATE USING (auth.uid() = agent_id OR public.get_user_role() = 'admin')
  WITH CHECK (public.get_user_role() = 'admin' OR auth.uid() = agent_id);
CREATE POLICY "Lands: admin delete" ON lands FOR DELETE USING (public.get_user_role() = 'admin');
```

#### Tabela `favorites`

```sql
CREATE POLICY "Favorites: read own" ON favorites FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "Favorites: insert own" ON favorites FOR INSERT WITH CHECK (auth.uid() = user_id);
CREATE POLICY "Favorites: delete own" ON favorites FOR DELETE USING (auth.uid() = user_id);
```

#### Tabela `messages`

```sql
-- Utilizadores veem mensagens que enviaram ou receberam
CREATE POLICY "Messages: read own" ON messages
  FOR SELECT USING (auth.uid() = sender_id OR auth.uid() = receiver_id);

-- Envio com sender_id = auth.uid()
CREATE POLICY "Messages: authenticated insert" ON messages
  FOR INSERT WITH CHECK (auth.uid() = sender_id);

-- Marcar como lidas
CREATE POLICY "Messages: update own" ON messages
  FOR UPDATE USING (auth.uid() = sender_id OR auth.uid() = receiver_id);
```

#### Tabela `bookings`

```sql
-- Leitura: próprio utilizador, agentes e admins
CREATE POLICY "Bookings: read own or agent" ON bookings
  FOR SELECT USING (auth.uid() = user_id OR public.get_user_role() IN ('agent', 'admin'));

-- Criação com user_id = auth.uid()
CREATE POLICY "Bookings: authenticated insert" ON bookings
  FOR INSERT WITH CHECK (auth.uid() = user_id);

-- Utilizador pode apenas cancelar agendamentos pending; agentes/admins confirmam/cancelam
CREATE POLICY "Bookings: update own" ON bookings
  FOR UPDATE USING (auth.uid() = user_id OR public.get_user_role() IN ('agent', 'admin'));
```

#### Tabela `notifications`

```sql
CREATE POLICY "Notifications: read own" ON notifications FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "Notifications: admin insert" ON notifications FOR INSERT WITH CHECK (public.get_user_role() = 'admin');
CREATE POLICY "Notifications: update own" ON notifications FOR UPDATE USING (auth.uid() = user_id);
```

#### Tabelas `reviews`, `saved_searches`, `device_tokens`, `reports`, `moderation_log`

A migrations 018–022 introduziram moderação, avaliações, pesquisas guardadas e tokens de dispositivo. Resumo:

| Tabela | Leitura | Escrita | Notas |
|---|---|---|---|
| `reviews` | Público | Próprio autor | 1 por (imóvel, utilizador) |
| `saved_searches` | Próprio | Próprio | Só os filtros do próprio |
| `device_tokens` | Próprio + Admin | Próprio | Token único por dispositivo |
| `reports` | Próprio + Admin | Próprio (INSERT) | Admin atualiza/apaga |
| `moderation_log` | Admin | Admin | Registo de ações de moderação |

### Reforços de segurança (migration 018)

- **Bookings**: removida a leitura anónima de marcações de convidados (PII); convidados criam marcações via RPC `create_guest_booking`.
- **Partners**: removida a leitura pública de `nif`/`license`; expostos apenas via view `partners_public`.
- **Storage**: upload/update restritos a `agent`/`admin`; delete só pelo `owner_id`.
- **send_notification**: rate limit por destinatário (20/10 min), validação de autorização e limites de tamanho.
- **register_guest_client**: valida posse da marcação (telefone coincide) antes de criar o perfil de visitante.
- **users**: campos de verificação (`verified`, `verified_at`, …) só editáveis por admins (trigger `prevent_self_verification`, reforçado na 021).
- **delete_user** (migration 024): apagar utilizador passa por RPC `SECURITY DEFINER` que exige role admin.

---

## Armazenamento de Ficheiros (Supabase Storage)

### Políticas de Buckets

| Bucket | Leitura | Escrita |
|---|---|---|
| `property-images` | Público | Autenticado (agente/admin) |
| `avatars` | Público | Autenticado (próprio utilizador) |
| `property-videos` | Público | Autenticado (agente/admin) |

### Limites

- Ficheiros de imagem: até 10 MB (avatar: 5 MB); vídeos: até 50 MB
- Formatos permitidos: JPEG, PNG, WebP, GIF (imagens); MP4, MOV, WebM, MKV, 3GPP, AVI (vídeos)
- Máximo de imagens por propriedade: 10

---

## Transporte de Dados

- **HTTPS obrigatório**: Todas as comunicações com Supabase usam HTTPS
- **Certificados SSL**: Geridos pelo Supabase
- **APIs externas**: Firebase usa HTTPS

---

## Proteção de Dados Pessoais

### Dados Recolhidos

| Dado | Finalidade | Retenção |
|---|---|---|
| Nome | Identificação do utilizador | Enquanto conta existir |
| Email | Autenticação e contacto | Enquanto conta existir |
| Telefone | Contacto com agentes | Enquanto conta existir |
| Avatar | Personalização do perfil | Enquanto conta existir |

### Direitos do Utilizador

- Aceder aos seus dados pessoais
- Solicitar correção de dados incorretos
- Solicitar eliminação da conta e dados
- Exportar os seus dados

---

## Boas Práticas de Desenvolvimento

### Código

- Nunca hardcoded de chaves de API ou passwords
- Usar `EnvConfig` para todas as variáveis sensíveis
- Validar todos os dados de entrada do utilizador
- Usar `const` onde possível para prevenir modificações acidentais
- Não logar dados sensíveis em produção

### Dependências

- Manter dependências atualizadas
- Revisar dependências com vulnerabilidades conhecidas
- Usar `flutter pub outdated` regularmente

### Testes

- Testar autenticação e autorização
- Testar políticas RLS
- Testar validação de dados de entrada

---

## Incidentes de Segurança

Em caso de suspeita de violação de segurança:

1. **Notificar imediatamente** a equipa de desenvolvimento
2. **Avaliar o impacto**: Que dados foram afetados?
3. **Tomar ação**: Revogar chaves, desativar contas comprometidas
4. **Comunicar**: Informar utilizadores afetados se necessário
5. **Documentar**: Registar o incidente e lições aprendidas

---

## Contacto

Para reportar vulnerabilidades de segurança:

- Email: geral@luarcompany.ao
- Assunto: `[SEGURANÇA] Descrição do problema`

Não publique vulnerabilidades publicamente até serem corrigidas.
