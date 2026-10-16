# LUAR MOBILIÁRIO — EVOLUÇÃO PARA UMA PLATAFORMA IMOBILIÁRIA PREMIUM

## CONTEXTO

O Luar Mobiliário é uma aplicação imobiliária existente, desenvolvida em Flutter, com Supabase e integração com serviços móveis. Os agentes OpenCode já implementaram partes significativas do projeto.

A missão é evoluir o produto existente para uma plataforma imobiliária premium, com descoberta vertical de imóveis por vídeo, pesquisa avançada, confiança, comparação e contacto direto.

NÃO criar um novo projeto.
NÃO substituir a arquitetura sem justificação técnica.
NÃO apagar funcionalidades existentes.
NÃO introduzir dados fictícios para simular funcionalidades.
NÃO afirmar que uma funcionalidade está concluída sem a implementar e testar.

## FASE 1 — AUDITORIA E ARQUITETURA

1. Inspecionar o projeto completo, incluindo instruções AGENTS.md, agentes existentes, dependências, rotas, ecrãs, serviços, modelos, testes e migrações Supabase.
2. Identificar funcionalidades já implementadas e reutilizá-las.
3. Identificar a estrutura real dos imóveis, vídeos, fotografias, perfis, favoritos e contactos.
4. Mapear as políticas RLS, autenticação, permissões e armazenamento.
5. Criar um plano de execução com ficheiros responsáveis, dependências e critérios de aceitação.
6. Executar alterações em etapas pequenas e verificáveis.

## FASE 2 — LUAR DISCOVER

Implementar o feed vertical como experiência principal de descoberta.

* Uma página por imóvel, com gesto vertical.
* Vídeo automático apenas na página ativa.
* Suporte a imagens quando não houver vídeo.
* Informações sobrepostas: preço, localização, tipo e resumo.
* Ações de favorito, partilha, detalhes e contacto.
* Pausa quando a aplicação fica em segundo plano.
* Gestão rigorosa do ciclo de vida dos controladores.
* Carregamento progressivo e tratamento de erros.
* Paginação real a partir do backend.
* Filtros e preferências sem perder o estado de navegação.
* Respeito pelas áreas seguras e pela barra de navegação.
* Acessibilidade e otimização para dispositivos modestos.

O feed não deve ser um carrossel horizontal.

## FASE 3 — PESQUISA E MAPA

Melhorar a pesquisa com:

* Compra, arrendamento e outras finalidades suportadas pelo modelo existente.
* Província, município e localização.
* Intervalo de preços e tipo de imóvel.
* Quartos, área e características, apenas quando disponíveis.
* Ordenação e filtros combináveis.
* Pesquisas guardadas, se compatíveis com a arquitetura.
* Mapa interativo usando uma integração já disponível ou tecnicamente aprovada.
* Correspondência consistente entre marcadores do mapa e anúncios reais.

Não inventar dados geográficos nem prometer disponibilidade em todas as regiões.

## FASE 4 — COMPARAÇÃO E FAVORITOS

Criar ou melhorar:

* Favoritos persistentes por utilizador.
* Comparação de até três imóveis.
* Comparação de preço, área, localização e características disponíveis.
* Cálculo do preço por metro quadrado apenas com dados válidos.
* Estados vazios, erros e carregamento.
* Sincronização segura com Supabase quando aplicável.

## FASE 5 — LUAR TRUST

Melhorar a confiança na plataforma:

* Perfis de anunciantes.
* Estado explícito da verificação.
* Contactos e dados relevantes do anúncio.
* Reportar anúncios suspeitos.
* Ferramentas administrativas de moderação, se ainda não existirem.
* Registo das ações de moderação e proteção dos dados pessoais.

Nunca apresentar um anunciante ou imóvel como verificado sem um processo real de verificação. Nunca expor documentos privados publicamente.

## FASE 6 — LUAR STUDIO E PUBLICAÇÃO

Auditar o fluxo de publicação existente e melhorá-lo:

* Carregamento de imagens e vídeos.
* Validação de formatos e limites de tamanho.
* Compressão adequada quando possível.
* Pré-visualização do anúncio.
* Edição, estado e gestão de publicações.
* Tratamento de falhas de rede e uploads interrompidos.
* Permissões de proprietário e agente.
* Validação de dados no cliente e no backend.

## FASE 7 — PERSONALIZAÇÃO E NOTIFICAÇÕES

Implementar recomendações progressivas baseadas em pesquisas, favoritos e preferências explícitas.

Começar por regras transparentes e mensuráveis antes de introduzir modelos de IA.

Se forem implementados alertas, garantir:

* Consentimento e preferências do utilizador.
* Tokens e permissões corretos.
* Notificações sem duplicações.
* Deep links para o imóvel correspondente.
* Ausência de exposição de dados sensíveis no ecrã bloqueado.

## FASE 8 — DESEMPENHO E POUPANÇA DE DADOS

* Miniaturas antes dos vídeos.
* Carregamento apenas do conteúdo necessário.
* Cache com limites de memória e armazenamento.
* Libertação de recursos.
* Tratamento de conectividade fraca.
* Opção para desativar reprodução automática.
* Redução da resolução ou consumo de dados quando apropriado.
* Métricas de desempenho sem recolha excessiva de dados.

## FASE 9 — SEGURANÇA E QUALIDADE

* Preservar autenticação, RLS e permissões do Supabase.
* Rever acesso a tabelas e Storage.
* Não incluir chaves secretas no cliente.
* Não contornar políticas de acesso para simplificar a implementação.
* Executar flutter analyze, testes unitários, testes de integração disponíveis e builds adequados.
* Corrigir regressões introduzidas.
* Verificar a navegação vertical, vídeo, pesquisa, favoritos, publicação e contacto.

## ORGANIZAÇÃO DOS AGENTES

O agente de arquitetura coordena as alterações.
O agente Flutter trata da interface e navegação.
O agente backend trata de Supabase, consultas e permissões.
O agente de segurança audita RLS e exposição de dados.
O agente de testes verifica regressões e critérios de aceitação.

Cada agente deve inspecionar o código antes de alterar ficheiros. Evitar alterações simultâneas incompatíveis e conflitos de integração.

## CRITÉRIOS DE CONCLUSÃO

Uma funcionalidade só pode ser marcada como concluída quando:

1. Está implementada no projeto real.
2. Utiliza dados e permissões corretos.
3. Os estados de erro e carregamento foram tratados.
4. Os testes relevantes foram executados.
5. Não introduz regressões conhecidas.

## RELATÓRIO FINAL

Entregar:

* Funcionalidades concluídas e pendentes.
* Ficheiros alterados.
* Migrações necessárias.
* Dependências adicionadas.
* Resultados reais dos testes.
* Riscos e decisões técnicas.
* Instruções para testar no Android e executar a aplicação.

Prioridade: entregar uma experiência premium e fluida sem comprometer a estabilidade do Luar Mobiliário existente
