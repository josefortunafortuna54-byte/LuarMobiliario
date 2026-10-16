# Guia de Contribuição

Obrigado por contribuir para o projeto Luar Company Imobiliária! Este documento descreve as orientações e processos para contribuir de forma eficiente e organizada.

---

## Índice

- [Primeiros Passos](#primeiros-passos)
- [Fluxo de Trabalho](#fluxo-de-trabalho)
- [Convenções de Código](#convenções-de-código)
- [Estrutura de Commits](#estrutura-de-commits)
- [Pull Requests](#pull-requests)
- [Issues](#issues)
- [Revisão de Código](#revisão-de-código)

---

## Primeiros Passos

1. Faça fork do repositório
2. Clone o seu fork:
   ```bash
   git clone https://github.com/seu-usuario/LuarMobiliario.git
   cd LuarMobiliario
   ```
3. Adicione o repositório original como remote:
   ```bash
   git remote add upstream https://github.com/josefortunafortuna54-byte/LuarMobiliario.git
   ```
4. Crie uma branch para a sua funcionalidade:
   ```bash
   git checkout -b feature/nome-da-funcionalidade
   ```
5. Configure o projeto conforme o [README](README.md)

---

## Fluxo de Trabalho

1. Sincronize com o repositório principal antes de começar:
   ```bash
   git fetch upstream
   git checkout main
   git merge upstream/main
   ```
2. Crie uma branch a partir de `main`
3. Implemente as suas alterações
4. Execute os testes e o analisador de código
5. Faça commit com mensagem descritiva
6. Push para o seu fork e abra um Pull Request

---

## Convenções de Código

### Dart/Flutter

- Siga o [Dart Style Guide](https://dart.dev/effective-dart/style)
- Execute `dart format` antes de commitar
- Execute `flutter analyze` e resolva todos os warnings
- Use nomes descritivos em inglês para variáveis, funções e classes
- Prefira `const` quando o valor for imutável
- Documente funções públicas com comentários `///`
- Nunca faça commit de chaves de API ou credenciais

### Estrutura de Ficheiros

- **Screens**: `lib/screens/{modulo}/{nome}_screen.dart`
- **Widgets**: `lib/widgets/{nome}_widget.dart`
- **Providers**: `lib/core/providers/{nome}_provider.dart`
- **Repositories**: `lib/core/repositories/{nome}_repository.dart`
- **Models**: `lib/core/models/{nome}_model.dart`
- **Services**: `lib/core/services/{nome}_service.dart`
- **Constants**: `lib/core/constants/app_{nome}.dart`

### Nomes

- Ficheiros: `snake_case.dart`
- Classes: `PascalCase`
- Variáveis e funções: `camelCase`
- Constantes: `camelCase` (dentro de classes abstract final)
- Tabelas Supabase: `snake_case` no banco de dados

---

## Estrutura de Commits

Utilize o formato [Conventional Commits](https://www.conventionalcommits.org/pt-BR/):

```
<tipo>(escopo): descrição curta

[corpo opcional]

[rodapé opcional]
```

### Tipos

| Tipo | Descrição |
|---|---|
| `feat` | Nova funcionalidade |
| `fix` | Correção de bug |
| `docs` | Alterações na documentação |
| `style` | Formatação (sem alteração de lógica) |
| `refactor` | Refatoração sem alteração de funcionalidade |
| `test` | Adição ou correção de testes |
| `chore` | Tarefas de manutenção, dependências, configuração |
| `perf` | Melhorias de desempenho |

### Exemplos

```
feat(properties): adicionar filtro por preço na pesquisa
fix(auth): corrigir login com email já confirmado
docs: atualizar guia de instalação
refactor(repositories): extrair lógica de query para método auxiliar
chore: atualizar dependências Flutter
```

---

## Pull Requests

### Antes de Abrir um PR

- [ ] O código compila sem erros
- [ ] `flutter analyze` não retorna erros
- [ ] `flutter test` passa todos os testes
- [ ] `dart format` foi executado
- [ ] A documentação foi atualizada (se aplicável)
- [ ] Não existem chaves ou segredos no código

### Formato do PR

- **Título**: Conciso e descritivo (ex: "feat(lands): adicionar filtros de terreno")
- **Descrição**: Explique o que foi alterado e porquê
- **Referência**: Vincule a issue correspondente (ex: `Closes #42`)
- **Screenshots**: Inclua screenshots ou vídeos para alterações visuais

### Processo

1. Abra o PR contra a branch `main`
2. Preencha o template do PR
3. Aguarde a revisão de pelo menos um maintainer
4. Resolva os feedbacks
5. O PR será mergeado após aprovação

---

## Issues

- Use templates existentes quando disponíveis
- Seja descritivo: inclua passos para reproduzir, comportamento esperado e obtido
- Adicione screenshots quando relevante
- Indique o dispositivo/SO e versão do Flutter utilizada

---

## Revisão de Código

- Todo o código deve ser revisto antes de ser mergeado
- Os reviewers verificam: correção, estilo, performance, segurança e testes
- Feedback deve ser construtivo e específico
- O autor das alterações deve responder a todos os comentários
