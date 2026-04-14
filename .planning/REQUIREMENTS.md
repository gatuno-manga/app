# Requirements: Gatuno

**Defined:** 2026-04-14  
**Core Value:** Toda nova versao marcada no repositorio deve gerar automaticamente artefatos de app anexados em uma GitHub Release, de forma previsivel e repetivel.

## v1 Requirements

Requirements for initial release automation delivery.

### Trigger & Validation

- [ ] **TRIG-01**: Team can trigger release workflow only from semantic tags in `vX.Y.Z` format
- [ ] **TRIG-02**: Team can block release pipeline when tag is invalid before any build starts
- [ ] **TRIG-03**: Team can ensure only one release run executes per version tag (concurrency guard)
- [ ] **TRIG-04**: Team can run `flutter analyze` and `flutter test` as mandatory quality gate before release artifact generation

### Build Artifacts

- [ ] **BLD-01**: Team can generate Android APK artifact for each valid release tag
- [ ] **BLD-02**: Team can generate Android AAB artifact for each valid release tag
- [ ] **BLD-03**: Team can generate iOS unsigned artifact for each valid release tag
- [ ] **BLD-04**: Team can publish artifact names with deterministic versioned pattern including platform and build type

### Release Publishing

- [ ] **REL-01**: Team can automatically create GitHub Release if it does not exist for the tag
- [ ] **REL-02**: Team can attach Android and iOS artifacts to the corresponding GitHub Release
- [ ] **REL-03**: Team can regenerate release notes automatically from repository history/metadata for each release

### Integrity & Auditability

- [ ] **INT-01**: Team can generate SHA256 checksums for each published artifact and attach them to the release
- [ ] **INT-02**: Team can re-run release publishing for the same tag without duplicating or corrupting release assets

## v2 Requirements

Deferred to future release hardening.

### Signing & Distribution

- **DIST-01**: Team can sign Android release artifacts using managed secrets and keystore
- **DIST-02**: Team can sign iOS release artifacts using certificates/provisioning profiles
- **DIST-03**: Team can publish approved builds directly to Play Store and App Store

### Governance

- **GOV-01**: Team can require protected environment approvals before production release publish
- **GOV-02**: Team can generate provenance/attestation metadata for release assets

## Out of Scope

Explicitly excluded from this milestone.

| Feature | Reason |
|---------|--------|
| Automatic Play Store publishing | User confirmed this v1 is only build + GitHub Release artifact delivery |
| Automatic App Store publishing | User confirmed this v1 is only build + GitHub Release artifact delivery |
| Mandatory signed artifacts in v1 | Secrets/certificates are not available yet |

## Traceability

Which phases cover which requirements. Updated during roadmap creation.

| Requirement | Phase | Status |
|-------------|-------|--------|
| TRIG-01 | TBD | Pending |
| TRIG-02 | TBD | Pending |
| TRIG-03 | TBD | Pending |
| TRIG-04 | TBD | Pending |
| BLD-01 | TBD | Pending |
| BLD-02 | TBD | Pending |
| BLD-03 | TBD | Pending |
| BLD-04 | TBD | Pending |
| REL-01 | TBD | Pending |
| REL-02 | TBD | Pending |
| REL-03 | TBD | Pending |
| INT-01 | TBD | Pending |
| INT-02 | TBD | Pending |

**Coverage:**
- v1 requirements: 13 total
- Mapped to phases: 0
- Unmapped: 13 ⚠️

---
*Requirements defined: 2026-04-14*  
*Last updated: 2026-04-14 after initial definition*
