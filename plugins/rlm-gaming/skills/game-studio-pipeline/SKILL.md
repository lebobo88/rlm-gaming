---
name: game-studio-pipeline
description: The end-to-end RLM-Gaming production pipeline and delegation contract. Read this before orchestrating any multi-discipline game workflow. Defines the five-layer studio flow, which work the Arcade crown owns vs delegates, the exact cross-squad envelopes (PRD/DEV_TASK → engineering, CREATIVE_BRIEF/SHOT_LIST/ASSET_JOB → garland), the HITL control points, and the phase/gate map. Invoked by The Director and The Producer.
---

# Game-studio pipeline skill

You are orchestrating a game-development workflow across the Arcade crown and its
delegation targets. The Arcade crown is an **orchestrator**: it produces design,
plans, specs, and gates — never engine code, never media binaries. This skill is
the routing contract.

## The cardinal rule

> If you are about to write engine source → emit a `PRD`/`DEV_TASK` to the
> `engineering` squad. If you are about to produce an image/audio/video/3D binary
> → emit a `CREATIVE_BRIEF`/`ASSET_JOB`/`SHOT_LIST` to the `garland` squad.
> The crown's own outputs are markdown design artifacts and `DECISION_RECORD`s.

## Five-layer flow

```
1. EXECUTIVE   vision → pillars → greenlight (HITL)         The Director · Producer · Forgemaster
2. DESIGN      systems · narrative · level · encounter · economy   The Systemsmith · Loremaster · Cartographer · Duelist · Economist
3. TECHNICAL   tech design · runtime AI · netcode · tools    The Forgemaster · Puppeteer · Netweaver · Toolwright   ─delegate→ engineering
4. CREATIVE    art bible · 3D/DCC · audio · animation         The Artisan · Sculptor · Conductor · Choreographer     ─delegate→ garland
5. EVALUATION  QA · balance · playtest · live-ops · cert · security   The Warden · Playtester · Custodian · Arbiter · Sentinel
```

## Phase → gate map

| Phase | Producing heads | Gate(s) | HITL |
|---|---|---|---|
| `vision` | Director | game-design-pillars-testable | greenlight |
| `design` | Systemsmith, Loremaster, Cartographer, Duelist, Economist | game-perf-budget (forecast), loot-box-jurisdiction (if monetized) | monetization model |
| `tech_design` | Forgemaster, Puppeteer, Netweaver | server-authority-fairplay (if online) | — |
| `production` | (delegated) engineering + garland | — | content-lock |
| `content` | Artisan, Sculptor, Conductor, Choreographer | ai-content-provenance, mesh-topology-budget (3D), rig-quality (rigs) | core-art-style lock |
| `qa_balance` | Warden, Playtester | game-accessibility-guidelines, game-perf-budget | — |
| `cert` | Arbiter | esrb-pegi-iarc-rating, platform-cert-readiness | cert submission |
| `liveops` | Custodian, Economist | loot-box-jurisdiction (per-change) | live economy change |

## Delegation envelopes — exact shapes

### → engineering (code)
Emit a `PRD` for a feature framing, then scoped `DEV_TASK`s. The design artifacts
(GDD, mechanic_spec, encounter_design_doc, level_greybox, economy_spreadsheet,
netcode_model) are **persisted first** (via the `rlmgaming.output.write` shim)
and **referenced by `context_refs: list[MemoryRef]`** — the `PRD`/`DevTask`
schemas have NO `payload`/`title` field, so do not invent one. Use the real
fields: `source_goal_id`, `summary`, `acceptance_criteria`, `user_stories`,
`dependencies`, `non_functional_requirements`. Engine choice + suggested pp team
go in `summary` / `non_functional_requirements`.

```yaml
type: PRD
origin_squad: rlm-gaming
target_squad: engineering
source_goal_id: <uuid of the root goal>
summary: "Parry mechanic — Unreal soulslike (engine: game-dev-unreal; suggested pp team: game-feature-team)"
acceptance_criteria:
  - "parry window 100ms, value lives in a tunable DataAsset (not hardcoded)"
  - "hit registration is server-authoritative (see server-authority-fairplay)"
non_functional_requirements:
  - "perf: PS5/XSX 60fps tier per game-perf-budget"
context_refs:                     # MemoryRef handles to the persisted design docs
  - { tier: episodic, key: "rlmgaming:output:design/parry-mechanic_spec.md", summary: "mechanic spec" }
  - { tier: episodic, key: "rlmgaming:output:design/parry-encounter_doc.md", summary: "encounter doc" }
```
Engineering runs the pair-programmer lifecycle (triage → profile → taxonomy →
stage loop) and returns a `DECISION_RECORD` (which `rlm-gaming` accepts back).

### → garland (assets)
Emit a `CREATIVE_BRIEF` for direction, `ASSET_JOB` for a concrete asset,
`SHOT_LIST` for cinematics/trailers. Garland's Helios crew renders; never drive
ComfyUI/diffusion from the Arcade crown.

```yaml
type: ASSET_JOB
target_squad: garland
model_type: diffusion            # diffusion | nerf | video_llm | tts | music | mesh | rig
brief: "Boss concept — 'The Hollow King', see art_bible.md style refs"
style_ref: art_bible.md
provenance_required: true        # garland governance-c2pa signs it
```
For 3D, The Sculptor emits `model_type: mesh` (props/env) or `model_type: rig`
(skinned characters) with a `dcc_contract` payload (topology / UV / LOD / axis /
export) — garland's `blender-model` / `blender-rig` execute it on the existing
blender-mcp backend (see `game-3d-modeling-and-dcc`). Returned 3D passes
`mesh-topology-budget`; rigs also pass `rig-quality` (`game-rigging-and-animation-pipeline`).

### → legal-compliance (IP / law)
Emit a `HANDOFF` to `legal-compliance` (Senate/curia) for licensed-engine terms,
age-rating law, UGC liability, or IP clearance The Arbiter can't resolve alone.

## Memory & provenance

- Recall before designing: `eights.memory.search(domain="gaming")` for prior
  post-mortems, failed gates, and platform gotchas.
- Encode after closing: `eights.memory.add(actor, domain="gaming")` with the
  `DECISION_RECORD` summary.
- Every artifact records its taxonomy section and gate verdicts for replay.

## Orchestration patterns (which command for what)

| Intent | Command | Lead |
|---|---|---|
| New game from scratch | `/game-greenlight` then `/game-studio` | Director |
| One level, all disciplines | `/game-vertical-slice` | Director + Producer |
| Single feature | `/game-feature` | Producer |
| Season of a live game | `/game-liveops-season` | Custodian |
| Balance + playtest sweep | `/game-balance-pass` | Warden + Playtester |
| Ratings / platform cert | `/game-cert-review` | Arbiter |

## Constraints

- Never produce code or binaries inline — always delegate.
- Every design artifact carries a testable acceptance criterion and an
  accessibility note (cross-ref `game-accessibility-guidelines`).
- Every monetized/`live_service` artifact carries a per-region monetization note
  (cross-ref `loot-box-jurisdiction`).
- Every online artifact carries a server-authority note (cross-ref
  `server-authority-fairplay`).
- Reuse the pp rubric library for perf + accessibility; don't redefine them.
