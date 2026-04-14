# Roadmap: Gatuno

## Overview

Este roadmap entrega automacao de release orientada por tag semantica, evoluindo de controle de trigger e qualidade para builds multiplataforma, publicacao automatica no GitHub Release e garantias de integridade/idempotencia.

## Phases

**Phase Numbering:**
- Integer phases (1, 2, 3): Planned milestone work
- Decimal phases (2.1, 2.2): Urgent insertions (marked with INSERTED)

Decimal phases appear between their surrounding integers in numeric order.

- [ ] **Phase 1: Release Trigger Control & Quality Gates** - Fluxo de release so inicia com tag semantica valida e passa por gates obrigatorios.
- [ ] **Phase 2: Unsigned Multi-Platform Artifact Builds** - Pipeline gera artefatos Android e iOS unsigned com nomenclatura deterministica.
- [ ] **Phase 3: Automated GitHub Release Publishing** - Release e criada/atualizada automaticamente com artefatos anexados e notas geradas.
- [ ] **Phase 4: Release Integrity & Idempotent Re-Publish** - Publicacao fica auditavel por checksum e segura para reexecucao sem duplicacao.

## Phase Details

### Phase 1: Release Trigger Control & Quality Gates
**Goal**: Time consegue iniciar releases apenas por tags semanticas validas, com bloqueio imediato de tags invalidas e validacao de qualidade antes de qualquer build.
**Depends on**: Nothing (first phase)
**Requirements**: TRIG-01, TRIG-02, TRIG-03, TRIG-04
**Success Criteria** (what must be TRUE):
  1. Ao publicar uma tag `vX.Y.Z`, o workflow de release e disparado automaticamente; pushes sem esse padrao nao disparam release.
  2. Ao publicar tag invalida, a execucao falha antes de iniciar jobs de build.
  3. Para a mesma tag de versao, apenas uma execucao ativa de release permanece em andamento.
  4. Se `flutter analyze` ou `flutter test` falhar, nenhum artefato de release e gerado.
**Plans**: 1 plan
Plans:
- [ ] 01-01-PLAN.md — Implementar workflow de release com trigger semver, concurrency guard, validação de ancestralidade em main e quality gate obrigatório.

### Phase 2: Unsigned Multi-Platform Artifact Builds
**Goal**: Time consegue gerar artefatos de release unsigned para Android e iOS em toda tag valida, com nomes estaveis e versionados.
**Depends on**: Phase 1
**Requirements**: BLD-01, BLD-02, BLD-03, BLD-04
**Success Criteria** (what must be TRUE):
  1. Para uma tag valida, o pipeline produz APK e AAB Android baixaveis.
  2. Para a mesma tag valida, o pipeline produz artefato iOS unsigned baixavel.
  3. Todos os artefatos gerados seguem padrao deterministico de nome contendo versao, plataforma e tipo de build.
**Plans**: TBD

### Phase 3: Automated GitHub Release Publishing
**Goal**: Time consegue obter uma GitHub Release pronta por versao, com criacao automatica quando necessario, artefatos anexados e release notes geradas.
**Depends on**: Phase 2
**Requirements**: REL-01, REL-02, REL-03
**Success Criteria** (what must be TRUE):
  1. Se a tag ainda nao tiver GitHub Release, a release e criada automaticamente durante o pipeline.
  2. Artefatos Android e iOS da versao ficam anexados na release correspondente.
  3. Cada release publicada inclui release notes geradas automaticamente a partir do repositorio.
**Plans**: TBD

### Phase 4: Release Integrity & Idempotent Re-Publish
**Goal**: Time consegue auditar artefatos publicados e reexecutar publicacao da mesma versao sem duplicar ou corromper assets.
**Depends on**: Phase 3
**Requirements**: INT-01, INT-02
**Success Criteria** (what must be TRUE):
  1. Cada artefato publicado possui checksum SHA256 disponivel na release.
  2. Ao reexecutar a publicacao para a mesma tag, os assets finais permanecem consistentes, sem duplicatas e sem corrupcao.
**Plans**: TBD

## Progress

**Execution Order:**
Phases execute in numeric order: 2 → 2.1 → 2.2 → 3 → 3.1 → 4

| Phase | Plans Complete | Status | Completed |
|-------|----------------|--------|-----------|
| 1. Release Trigger Control & Quality Gates | 0/TBD | Not started | - |
| 2. Unsigned Multi-Platform Artifact Builds | 0/TBD | Not started | - |
| 3. Automated GitHub Release Publishing | 0/TBD | Not started | - |
| 4. Release Integrity & Idempotent Re-Publish | 0/TBD | Not started | - |
