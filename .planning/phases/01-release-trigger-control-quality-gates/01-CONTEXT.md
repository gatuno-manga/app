# Phase 1: Release Trigger Control & Quality Gates - Context

**Gathered:** 2026-04-14
**Status:** Ready for planning

<domain>
## Phase Boundary

Implementar a fundacao do fluxo de release para que somente tags semanticas validas iniciem o pipeline e para que gates de qualidade bloqueiem qualquer build quando houver falha.

</domain>

<decisions>
## Implementation Decisions

### Regra de tags semanticas
- **D-01:** O workflow de release aceita apenas tags estaveis no formato `vMAJOR.MINOR.PATCH`.
- **D-02:** Tags invalidas devem falhar imediatamente com mensagem clara, antes de qualquer job de build.

### Politica de concorrencia
- **D-03:** Para a mesma versao, a execucao mais antiga deve ser cancelada e a mais nova deve continuar.
- **D-04:** A chave de concorrencia deve ser `workflow + tag` para evitar colisao com outros workflows.

### Quality gate
- **D-05:** O gate obrigatorio da Fase 1 e `flutter analyze` + `flutter test` (suite completa).
- **D-06:** Os gates rodam em job dedicado de validacao antes de qualquer build.
- **D-07:** Falha no gate encerra o release imediatamente; rerun somente manual apos correcao.

### Permissoes e seguranca
- **D-08:** O workflow deve usar permissoes minimas por job, com `contents: write` apenas onde houver necessidade real de publicacao.
- **D-09:** O release so deve aceitar tags que apontem para commits alcancaveis pela `main`.
- **D-10:** O projeto deve registrar a exigencia de proteger o padrao de tags `v*` no repositorio.

### the agent's Discretion
- Implementacao exata do regex de validacao da tag.
- Formato detalhado das mensagens de erro do gate de validacao.
- Nome dos jobs e organizacao final do YAML dentro das decisoes acima.

</decisions>

<canonical_refs>
## Canonical References

**Downstream agents MUST read these before planning or implementing.**

### Escopo e requisitos da fase
- `.planning/ROADMAP.md` — Goal e Success Criteria da Phase 1
- `.planning/REQUIREMENTS.md` — TRIG-01, TRIG-02, TRIG-03, TRIG-04
- `.planning/PROJECT.md` — Core Value, Constraints e Key Decisions do milestone

### Baseline tecnica existente
- `.github/workflows/test.yml` — Padrao atual de setup Flutter + analyze + test
- `lefthook.yml` — Convencao local de analise/formatacao em pre-commit
- `pubspec.yaml` — Fonte de versao do app e contexto de stack Flutter/Dart

</canonical_refs>

<code_context>
## Existing Code Insights

### Reusable Assets
- `.github/workflows/test.yml`: ja possui setup com `subosito/flutter-action@v2`, `flutter pub get`, `flutter analyze`, `flutter test`.
- `lefthook.yml`: reforca o mesmo padrao de gate (`flutter analyze`) para consistencia local/CI.

### Established Patterns
- CI existente usa GitHub Actions com steps explicitos e simples.
- Ferramentas de qualidade ja adotadas no repositorio: `flutter analyze` e `flutter test`.
- Preferencia por configuracao declarativa em YAML e comandos diretos de Flutter.

### Integration Points
- Novo workflow de release deve viver em `.github/workflows/` (novo arquivo para fase de release).
- Job de validacao desta fase deve anteceder os jobs de build previstos para a Phase 2.
- Regras de trigger/concurrency desta fase devem ser base para publicacao automatica da Phase 3.

</code_context>

<specifics>
## Specific Ideas

- O usuario quer comportamento deterministico: tag valida dispara, tag invalida falha cedo.
- O usuario explicitou preferencia por governanca simples e segura (minimal permissions + protecao de tags).

</specifics>

<deferred>
## Deferred Ideas

None — discussion stayed within phase scope.

</deferred>

---

*Phase: 01-release-trigger-control-quality-gates*
*Context gathered: 2026-04-14*
