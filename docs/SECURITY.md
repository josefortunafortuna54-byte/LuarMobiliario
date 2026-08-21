# Documentação de Segurança

Documento com as práticas de segurança, políticas e recomendações para a plataforma Luar Company Imobiliária.

---

## Visão Gonal

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

#### Tabela `users`

```sql
-- Utilizadores veem o seu próprio perfil
CREATE POLICY "Users read own profile" ON users
  FOR SELECT USING (auth.uid() = id_auth);

-- Utilizadores atualizam o seu próprio perfil
CREATE POLICY "Users update own profile" ON users
  FOR UPDATE USING (auth.uid() = id_auth);

-- Admin pode ver todos os utilizadores
CREATE POLICY "Admins read all users" ON users
  FOR SELECT USING (
    EXISTS (SELECT 1 FROM users WHERE id_auth = auth.uid() AND role = 'admin')
  );
```

#### Tabela `properties`

```sql
-- Propriedades são públicas para leitura
CREATE POLICY "Properties public read" ON properties
  FOR SELECT USING (true);

-- Agentes criam propriedades
CREATE POLICY "Agents create properties" ON properties
  FOR INSERT WITH CHECK (auth.uid() = agent_id);

-- Agentes editam as suas propriedades
CREATE POLICY "Agents update own properties" ON properties
  FOR UPDATE USING (auth.uid() = agent_id);

-- Agentes eliminam as suas propriedades
CREATE POLICY "Agents delete own properties" ON properties
  FOR DELETE USING (auth.uid() = agent_id);

-- Admin pode gerir todas as propriedades
CREATE POLICY "Admin manages all properties" ON properties
  FOR ALL USING (
    EXISTS (SELECT 1 FROM users WHERE id_auth = auth.uid() AND role = 'admin')
  );
```

#### Tabela `lands`

```sql
-- Mesmas políticas de properties, adaptadas para lands
CREATE POLICY "Lands public read" ON lands FOR SELECT USING (true);
CREATE POLICY "Agents create lands" ON lands FOR INSERT WITH CHECK (auth.uid() = agent_id);
CREATE POLICY "Agents update own lands" ON lands FOR UPDATE USING (auth.uid() = agent_id);
```

#### Tabela `favorites`

```sql
-- Utilizadores veem e gerem os seus favoritos
CREATE POLICY "Users manage own favorites" ON favorites
  FOR ALL USING (auth.uid() = user_id);
```

#### Tabela `messages`

```sql
-- Utilizadores veem mensagens que enviaram ou receberam
CREATE POLICY "Users read own messages" ON messages
  FOR SELECT USING (auth.uid() = sender_id OR auth.uid() = receiver_id);

-- Utilizadores enviam mensagens
CREATE POLICY "Users send messages" ON messages
  FOR INSERT WITH CHECK (auth.uid() = sender_id);
```

---

## Armazenamento de Ficheiros (Supabase Storage)

### Políticas de Buckets

| Bucket | Leitura | Escrita |
|---|---|---|
| `property-images` | Público | Autenticado (agente/admin) |
| `avatars` | Público | Autenticado (próprio utilizador) |
| `documents` | Privado | Autenticado (próprio utilizador) |
| `products` | Público | Autenticado (agente/admin) |

### Limites

- Tamanho máximo por ficheiro: 10 MB
- Formatos permitidos: JPEG, PNG, WebP, PDF
- Máximo de imagens por propriedade: 10

---

## Transporte de Dados

- **HTTPS obrigatório**: Todas as comunicações com Supabase usam HTTPS
- **Certificados SSL**: Geridos pelo Supabase
- **APIs externas**: Google Maps, Firebase usam HTTPS

---

## Proteção de Dados Pessoais

### Dados Recolhidos

| Dado | Finalidade | Retenção |
|---|---|---|
| Nome | Identificação do utilizador | Enquanto conta existir |
| Email | Autenticação e contacto | Enquanto conta existir |
| Telefone | Contacto com agentes | Enquanto conta existir |
| Avatar | Personalização do perfil | Enquanto conta existir |
| Localização | Funcionalidade de mapas | Não armazenada permanentemente |

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
