# Roadmap do Projeto

Visão temporal do desenvolvimento da plataforma Luar Company Imobiliária.

> Plano detalhado de evolução para plataforma premium (9 fases): ver [Documento.md](Documento.md).

---

## Fase 1 — Funcionalidades Principais ✅ Concluída

**Versão:** 1.0.0  
**Data de conclusão:** Julho 2026

### Funcionalidades Implementadas

| Módulo | Estado |
|---|---|
| Autenticação (login/registo) | ✅ |
| Ecrã principal (Home) | ✅ |
| Propriedades (lista + detalhe) | ✅ |
| Terrenos (lista + detalhe) | ✅ |
| Pesquisa avançada | ✅ |
| Favoritos | ✅ |
| Mensagens | ✅ |
| Agendamentos | ✅ |
| Perfil do utilizador | ✅ |
| Painel administrativo | ✅ |
| Landing page web | ✅ |
| Notificações push | ✅ |
| Integração WhatsApp | ✅ |
| Design system navy/gold | ✅ |

### Infraestrutura

- Arquitetura em camadas (UI → Provider → Repository → Supabase)
- Variáveis de ambiente via `--dart-define` (a partir de `.env` local, não empacotado)
- Modelos de dados com serialização JSON
- Repositórios para acesso a dados
- Rotas nomeadas com transições personalizadas
- Componentes reutilizáveis
- Testes unitários e de widget

---

## Fase 2 — Qualidade e Performance 🔄 Em Progresso

**Versão prevista:** 1.1.0  
**Estado:** Em desenvolvimento

### Tarefas

| Tarefa | Estado | Prioridade |
|---|---|---|
| Configuração CI/CD com GitHub Actions | ✅ | Alta |
| Aumentar cobertura de testes | 🔄 | Alta |
| Assinatura de APK para Play Store | 🔄 | Alta |
| Otimização de performance (lazy loading, cache) | ✅ | Média |
| Testes de integração com Supabase | 🔄 | Média |
| Otimização de queries na base de dados | ✅ | Média |
| Testes de acessibilidade | ⏳ | Média |
| Testes em múltiplos dispositivos | ⏳ | Média |
| Análise de crash reports | ⏳ | Baixa |

### Métricas de Sucesso

- Cobertura de testes > 60%
- Tempo de carregamento inicial < 3 segundos
- Zero erros críticos em produção
- Build automatizado via CI/CD

---

## Fase 3 — Funcionalidades Avançadas 📋 Planeada

**Versão prevista:** 1.2.0  
**Estado:** Planeada

### Funcionalidades

| Funcionalidade | Descrição | Prioridade | Estado |
|---|---|---|---|
| Mapas avançados | Pesquisa por mapa com clusters e filtros geográficos | Alta | 🔄 (mapa interativo; falta clusters/terrenos) |
| Tours em vídeo | Gravação e visualização de vídeos de propriedades | Média | ✅ (vídeos de anúncios) |
| Notificações refinadas | Categorias, preferências e agendamento de notificações | Média | ✅ |
| Multi-idioma | Suporte PT/EN com sistema de internacionalização | Média | ✅ |
| Dashboard de analytics | Métricas de uso, propriedades mais vistas, conversões | Média | ✅ |
| Integração de pagamentos | Pagamento de serviços via Multicaixa Express, etc. | Alta | ⏳ |
| Sistema de avaliações | Avaliações e comentários de utilizadores sobre propriedades e agentes | Baixa | ✅ (imóveis) |
| Exportação de dados | Exportar lista de propriedades em PDF/Excel | Baixa | ⏳ |
| Modo offline | Acesso limitado a dados sem ligação à internet | Baixa | 🔄 (só aviso de conectividade) |

---

## Fase 4 — Expansão 🚀 Futuro

**Versão prevista:** 2.0.0  
**Estado:** Futuro

### Funcionalidades

| Funcionalidade | Descrição |
|---|---|
| App iOS na App Store | Publicação oficial na Apple App Store |
| App para agentes | Aplicação dedicada para gestores de propriedades |
| Tours virtuais | Visualização 360° de propriedades com Google Street View |
| Recomendações IA | Sugestões inteligentes de propriedades com base no perfil do utilizador |
| Chatbot assistente | Assistente virtual para orientação na pesquisa |
| Integração com ERPs | Conexão com sistemas de gestão imobiliária |
| Marketplace de serviços | Rede de parceiros (advogados, engenhas, financiadores) |
| Programa de fidelidade | Sistema de pontos e recompensas para utilizadores ativos |
| Expansão regional | Suporte para outros países lusófonos (Moçambique, Cabo Verde, etc.) |

---

## Marcos Importantes

| Data | Marco |
|---|---|
| Julho 2026 | Lançamento v1.0.0 — Funcionalidades principais |
| Outubro 2026 | v1.0.1 — Evolução premium (Discover, comparação, Trust, pesquisas guardadas, avaliações, analytics, i18n) |
| 2026 | CI/CD operacional e testes automatizados |
| Pendente | Publicação na Google Play Store (materiais prontos; falta submissão) |
| 2027 | Expansão iOS, mapas e pagamentos (Fase 4) |
