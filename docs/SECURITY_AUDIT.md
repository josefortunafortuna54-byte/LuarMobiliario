# Checklist de Auditoria de Segurança - Luar Mobiliário

> Data: 2026-10-20  
> Objetivo: Validar RLS, Storage Policies e hardening antes de expansão.

## 1) Row Level Security (RLS) - Tabelas

| Tabela | RLS Ativo | SELECT | INSERT | UPDATE | DELETE | Verificações |
|---|---|---|---|---|---|---|
| `users` | ☐ | ☐ | ☐ | ☐ | ☐ | Apenas próprio utilizador ou admin/agente conforme role. Sem expor dados sensíveis via views públicas. |
| `properties` | ☐ | ☐ | ☐ | ☐ | ☐ | Leitura pública apenas para `is_available = true`. Escrita apenas pelo agente dono ou admin. |
| `lands` | ☐ | ☐ | ☐ | ☐ | ☐ | Mesmas regras que properties. |
| `favorites` | ☐ | ☐ | ☐ | ☐ | ☐ | Apenas `auth.uid() = user_id`. |
| `bookings` | ☐ | ☐ | ☐ | ☐ | ☐ | Cliente vê as suas marcações. Agente vê marcações dos seus anúncios. Admin vê tudo. |
| `messages` | ☐ | ☐ | ☐ | ☐ | ☐ | Apenas participantes da conversa. |
| `reviews` | ☐ | ☐ | ☐ | ☐ | ☐ | Leitura pública. Escrita por utilizador autenticado com regras (1 review por utilizador/anúncio). |
| `reports` | ☐ | ☐ | ☐ | ☐ | ☐ | Apenas autor ou admin. |
| `saved_searches` | ☐ | ☐ | ☐ | ☐ | ☐ | Apenas `auth.uid() = user_id`. |
| `device_tokens` | ☐ | ☐ | ☐ | ☐ | ☐ | Apenas dono do token. Remoção no logout. |
| `partners` | ☐ | ☐ | ☐ | ☐ | ☐ | Gestão restrita a admin. |
| `comparisons` | ☐ | ☐ | ☐ | ☐ | ☐ | Verificar se existe e aplicar isolamento por utilizador. |

**Notas:** 
- Garantir que views públicas não expõem PII (email/telefone) desnecessariamente.
- Usar `auth.uid()` em todas as policies sensíveis.
- Validar com contas de diferentes roles (client/agent/admin).

## 2) Storage Policies (Buckets)

| Bucket | Público | Upload | Download | Delete | Verificações |
|---|---|---|---|---|---|
| `property-images` | ☐ | ☐ | ☐ | ☐ | Apenas agente dono ou admin pode fazer upload/delete. Validar tipo MIME (image/*) e tamanho. Path organizado por `property_id/`. |
| `property-videos` | ☐ | ☐ | ☐ | ☐ | Idêntico a imagens. Verificar limites de tamanho. Considerar compressão. |
| `avatars` | ☐ | ☐ | ☐ | ☐ | Apenas utilizador autenticado pode upload do seu próprio avatar. Path `avatars/{user_id}/`. Impedir overwrite/delete cruzado. |

**Recomendações:**
- Evitar `*` em policies. Usar condições com `auth.uid()`.
- Preferir signed URLs para conteúdos sensíveis (se aplicável).
- Validar extensão/tipo no cliente e reforçar no storage policy.
- Implementar limpeza de ficheiros órfãos.

## 3) Hardening Aplicação

| Item | Estado | Ações |
|---|---|---|
| `--dart-define` para secrets | OK | Manter. Não commitar `.env`. |
| Rotas de notificação com allowlist | OK | Já implementado em `AppRoutes.parse()`. Adicionar testes unitários (feito). |
| Remoção de token FCM no logout | OK | Já implementado. |
| Proteção rotas admin por role | OK | Validar em todas as telas admin. |
| Logs sensíveis | Em progresso | Envolver `debugPrint` com `kDebugMode` (feito em main/services). |
| Fluxo guest com email sintético | Atenção | Adicionar rate-limit, validação telefone, prevenir spam. Monitorizar criação massiva. |
| Permissões nativas | Revisar | Auditar `AndroidManifest.xml` e `Info.plist`. Pedir apenas quando necessário. |

## 4) Plano de Verificação

1. **Supabase SQL Editor**: Testar cada policy com `auth.uid()` simulado ou contas reais.
2. **Storage**: Tentar upload/delete com utilizador errado (deve falhar).
3. **App**: Testar fluxos com diferentes roles.
4. **Logs**: Verificar que não há PII em `debugPrint` (build release).
5. **Rotas**: Testar payloads maliciosos via `AppRoutes.parse()`.

## 5) Conclusão

- [ ] **RLS auditado e validado**
- [ ] **Storage policies auditados e validados**
- [ ] **Hardening da app verificado**
- [ ] **Testes de segurança executados**
- [ ] **Documentação atualizada**

**Responsável:** Equipa Dev  
**Prioridade:** CRÍTICA  
**Prazo:** Antes de produção com tráfego real
