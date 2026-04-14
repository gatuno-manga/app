# Gatuno

## What This Is

Gatuno e um aplicativo mobile em Flutter para descoberta e consumo de conteudo de livros, com autenticacao, perfil de usuario e configuracoes da aplicacao. O projeto ja possui base funcional em producao de desenvolvimento (navegacao, auth, listagem e detalhes) e agora evolui para fortalecer o fluxo de entrega. O foco imediato e automatizar CI/CD para gerar artefatos de release quando uma nova versao for publicada.

## Core Value

Toda nova versao marcada no repositorio deve gerar automaticamente artefatos de app anexados em uma GitHub Release, de forma previsivel e repetivel.

## Requirements

### Validated

- ✓ Usuario consegue criar conta, autenticar e encerrar sessao — existente
- ✓ Usuario navega entre Home, Books e Settings com rotas estruturadas — existente
- ✓ Usuario visualiza listagem paginada de livros com filtros e ordenacao — existente
- ✓ Usuario acessa detalhes de livro e informacoes relacionadas — existente
- ✓ Aplicativo suporta internacionalizacao (en/pt) com textos localizados — existente
- ✓ Configuracao de API em runtime e persistencia de preferencias de usuario — existente

### Active

- [ ] Adicionar workflow de CI/CD no GitHub Actions acionado por push de tag semantica (`vX.Y.Z`)
- [ ] Compilar Android e iOS a cada nova versao e anexar os artefatos na GitHub Release
- [ ] Criar a GitHub Release automaticamente quando a tag nao possuir release correspondente
- [ ] Gerar builds sem assinatura enquanto certificados/segredos nao estiverem configurados

### Out of Scope

- Publicacao automatica na Play Store e App Store — fora do escopo desta fase inicial de release automation
- Assinatura oficial de distribuicao (Android/iOS) — depende de provisionamento de segredos/certificados ainda nao disponiveis

## Context

- Codigo existente mapeado em `.planning/codebase/` com arquitetura Clean Architecture + MVVM + Provider e DI com GetIt.
- Projeto Flutter com alvos Android e iOS, estrutura de testes consolidada e historico de evolucao funcional relevante.
- Objetivo atual nao e criar novas features de produto final; e elevar confiabilidade operacional de entrega de versoes.
- Necessidade principal do usuario: reduzir trabalho manual no release, garantindo que cada versao tenha binarios anexados automaticamente.

## Constraints

- **CI/CD**: Deve usar GitHub Actions — padrao escolhido para a automacao
- **Trigger**: Execucao somente em push de tag semantica (`vX.Y.Z`) — alinhado ao fluxo de versionamento
- **Plataformas**: Android e iOS devem ser contemplados — requisito explicito do usuario
- **Assinatura**: Sem segredos/certificados por enquanto, logo o pipeline precisa suportar artefatos sem assinatura — evita bloqueio imediato
- **Escopo de entrega**: Apenas gerar e anexar artefatos na release — publicacao em stores fica para fase futura

## Key Decisions

| Decision | Rationale | Outcome |
|----------|-----------|---------|
| Usar GitHub Actions para release automation | Ja e o CI/CD escolhido para o repositorio e integra bem com Releases | — Pending |
| Disparar pipeline por tag semantica (`vX.Y.Z`) | Tag representa marco de versao e reduz execucoes desnecessarias | — Pending |
| Criar GitHub Release automaticamente se nao existir | Remove etapa manual e garante consistencia do fluxo | — Pending |
| Gerar builds sem assinatura inicialmente | Projeto ainda nao possui segredos/certificados para signing | — Pending |
| Limitar escopo a artefatos em release (sem stores) | Entrega incremental com menor risco operacional | — Pending |

## Evolution

This document evolves at phase transitions and milestone boundaries.

**After each phase transition** (via `/gsd-transition`):
1. Requirements invalidated? → Move to Out of Scope with reason
2. Requirements validated? → Move to Validated with phase reference
3. New requirements emerged? → Add to Active
4. Decisions to log? → Add to Key Decisions
5. "What This Is" still accurate? → Update if drifted

**After each milestone** (via `/gsd-complete-milestone`):
1. Full review of all sections
2. Core Value check — still the right priority?
3. Audit Out of Scope — reasons still valid?
4. Update Context with current state

---
*Last updated: 2026-04-14 after initialization*
