---
description: "The Director + The Producer orchestrate all five layers for ONE level — full gameplay, art, and audio — then content-lock it through QA, perf, and accessibility gates."
argument-hint: "<level/slice name> [--engine unity|unreal|godot|web|spring|custom] [--online]"
model: sonnet
---

# /game-vertical-slice

**The Director** and **The Producer** orchestrate every studio layer for a single representative level so the team can prove the game is fun and shippable before scaling content. Design heads fan out to spec the slice, code is delegated to `engineering` (via `game-feature-team`), art/audio are delegated to `garland`, and the slice is hardened through QA/balance, perf, and accessibility gates before a content-lock HITL. This is Phase 3 ("vertical slice") of the roadmap and uses the `game-studio-pipeline` skill as its backbone.

## Steps

1. **Scope** — The Producer sets the slice boundary, milestone, and acceptance bar; The Director confirms it exercises the greenlit pillars.
2. **Design fan-out (DESIGN layer)** — in parallel: The Cartographer (level greybox + pacing), The Systemsmith (mechanic specs), The Duelist (encounter/boss doc + AI tuning targets), The Loremaster (scene narrative/dialogue), The Economist (any in-slice economy; arm `loot-box-jurisdiction` if monetized).
3. **Tech design (TECHNICAL layer)** — The Forgemaster sets the perf budget; The Netweaver supplies the server-authority model if `--online` (arms `server-authority-fairplay`); The Puppeteer specs runtime NPC AI.
4. **Delegate code → engineering** — emit a `PRD` (slice framing) + scoped `DEV_TASK`s to `engineering`, with design artifacts as payload, `engine_profile: game-dev-<engine>`, `suggested_team: game-feature-team` (or `game-netcode-team` for the online layer).
5. **Delegate assets → garland (CREATIVE layer)** — The Artisan emits `CREATIVE_BRIEF` + `ASSET_JOB`s (concept/3D), The Conductor emits audio `ASSET_JOB`s, The Choreographer specs animation; all `provenance_required: true` so `governance-c2pa` signs them. Fires `ai-content-provenance` on any gen-AI asset.
6. **Evaluate (EVALUATION layer)** — The Warden + The Playtester run bot playthroughs and balance, firing `game-accessibility-guidelines` and `game-perf-budget` (pp rubrics). The Forgemaster owns the perf verdict.
7. **HITL: core-art-style lock + content lock** — emit `HITL_REQUEST` for art-style lock (The Artisan) and content lock (The Producer).
8. **Synthesize** — The Director writes the slice `DECISION_RECORD` with all gate verdicts and links; `eights.memory.add(domain="gaming")`.

## Example

```
/game-vertical-slice "Sunken Cathedral boss arena" --engine unreal --online
```
Five design heads spec the arena in parallel, a `PRD` + `DEV_TASK`s go to `game-feature-team` and `game-netcode-team`, boss concept + VO + music go to garland as C2PA-signed `ASSET_JOB`s, perf/accessibility gates pass, and the slice pauses on art-style + content-lock HITLs.

## Delegation

Code → `engineering` (`PRD`/`DEV_TASK`, `game-feature-team` / `game-netcode-team`). Assets → `garland` (`CREATIVE_BRIEF`/`SHOT_LIST`/`ASSET_JOB`, C2PA-signed). The Arcade heads produce only the level greybox, mechanic/encounter/economy specs, narrative pages, perf budget, and `DECISION_RECORD` — never the engine code or the rendered assets themselves.
