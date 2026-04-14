# Phase 1: Release Trigger Control & Quality Gates - Discussion Log

> **Audit trail only.** Do not use as input to planning, research, or execution agents.
> Decisions are captured in CONTEXT.md — this log preserves the alternatives considered.

**Date:** 2026-04-14  
**Phase:** 1 - Release Trigger Control & Quality Gates  
**Areas discussed:** Regra de tags semanticas, Politica de concorrencia, Escopo do quality gate, Permissoes e seguranca

---

## Regra de tags semanticas

| Option | Description | Selected |
|--------|-------------|----------|
| Somente versao estavel: vMAJOR.MINOR.PATCH | Trigger estrito para release oficial | ✓ |
| Estavel + pre-release: vMAJOR.MINOR.PATCH(-rc.N, -beta.N, -alpha.N) | Inclui canais prerelease | |
| Qualquer tag iniciando com v | Regra mais permissiva | |

| Option | Description | Selected |
|--------|-------------|----------|
| Falhar imediatamente com mensagem clara e sem iniciar build | Fail-fast e feedback claro | ✓ |
| Ignorar execucao sem erro | Evita falha visivel | |
| Continuar ate quality gate e falhar depois | Falha tardia | |

---

## Politica de concorrencia

| Option | Description | Selected |
|--------|-------------|----------|
| Cancelar a execucao antiga e manter a mais nova | Mantem so uma execucao ativa por versao | ✓ |
| Nao cancelar a antiga e bloquear nova ate terminar | Preserva primeira execucao | |
| Permitir as duas em paralelo | Sem protecao de corrida | |

| Option | Description | Selected |
|--------|-------------|----------|
| Sim (workflow + tag) | Evita colisao com outros workflows | ✓ |
| Nao, apenas por tag | Chave mais curta | |

---

## Escopo do quality gate

| Option | Description | Selected |
|--------|-------------|----------|
| flutter analyze + flutter test (suite completa) | Gate completo e objetivo | ✓ |
| flutter analyze + flutter test + cobertura | Inclui metrica de cobertura | |
| Apenas flutter analyze | Gate mais leve | |

| Option | Description | Selected |
|--------|-------------|----------|
| Job de validacao dedicado antes de qualquer build | Ordem clara e sem duplicacao de checks | ✓ |
| Executar os gates dentro de cada job de build | Repeticao de verificacoes | |
| Executar gates somente depois dos builds | Falha tardia com custo maior | |

| Option | Description | Selected |
|--------|-------------|----------|
| Falhar release imediatamente; rerun manual apos correcoes | Politica deterministica de falha | ✓ |
| Tentar 1 retry automatico | Mitiga flakes leves | |
| Tentar ate 3 retries automaticos | Mais tolerancia a instabilidade | |

---

## Permissoes e seguranca

| Option | Description | Selected |
|--------|-------------|----------|
| Permissoes minimas por job (contents: write so no publish; read no restante) | Menor superficie de risco | ✓ |
| Permissoes padrao amplas do GITHUB_TOKEN | Menos configuracao inicial | |
| Permissoes amplas + preparacao para assinar artefatos agora | Antecipar fase posterior | |

| Option | Description | Selected |
|--------|-------------|----------|
| Sim, exigir commit alcancavel pela main | Governa release por branch principal | ✓ |
| Nao, aceitar qualquer tag no repositorio | Mais flexivel | |

| Option | Description | Selected |
|--------|-------------|----------|
| Sim | Registrar protecao de tags `v*` | ✓ |
| Nao | Sem politica adicional nesta fase | |
