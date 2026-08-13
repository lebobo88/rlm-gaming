---
description: "A single feature end-to-end — The Producer scopes, the right design head specs, engineering implements via the matching pp game-* team, then QA/perf/accessibility gates and a DECISION_RECORD."
argument-hint: "<feature> [--type feature|netcode|bug-fix|refactor] [--engine unity|unreal|godot|web|spring|custom] [--online]"
model: sonnet
---

# /game-feature

**The Producer** takes one feature from request to closed `DECISION_RECORD`. The Producer scopes it, routes it to the single most relevant design head for a spec, then emits a `PRD`/`DEV_TASK` to `engineering` — picking the correct pair-programmer `game-*` team by feature type — and finally runs the QA, perf, and accessibility gates. This is the Phase-1/2 workhorse command. The Arcade crown supplies the design artifact; the pp lifecycle writes the code.

## Steps

1. **Scope** — The Producer defines the feature boundary, acceptance criteria (each testable), and milestone fit.
2. **Spec** — route to the owning design head: mechanics → The Systemsmith; encounters/bosses → The Duelist; level/flow → The Cartographer; economy/monetization → The Economist (arms `loot-box-jurisdiction`); narrative → The Loremaster; runtime NPC AI → The Puppeteer; netcode model → The Netweaver (arms `server-authority-fairplay` if `--online`); 3D assets/topology → The Sculptor (arms `mesh-topology-budget`, commissions garland blender-model/blender-rig); rigs/animation → The Choreographer (arms `rig-quality`).
3. **Pick the team** — map `--type` to the pp team: `feature` → `game-feature-team`; `netcode` → `game-netcode-team`; `bug-fix` → `game-bug-fix-team`; `refactor` → `game-refactor-team`; `art-pipeline`/3D-asset → `game-art-pipeline-team`.
4. **Delegate code → engineering** — emit a `PRD` (feature framing) with the design artifact as payload, `engine_profile: game-dev-<engine>`, `suggested_team: <picked team>`, plus scoped `DEV_TASK`s and acceptance. Engineering runs triage → profile → taxonomy → stage loop and returns a `DECISION_RECORD`.
5. **Gates** — The Warden fires `game-accessibility-guidelines` (every feature) and `game-perf-budget`; The Sentinel fires `server-authority-fairplay` if online; The Economist/The Arbiter fire `loot-box-jurisdiction` if monetized.
6. **Close** — The Producer writes the feature `DECISION_RECORD` (links the engineering return + gate verdicts); `eights.memory.add(domain="gaming")`.

## Example

```
/game-feature "wall-running traversal" --type feature --engine unity
```
The Producer scopes it, The Systemsmith writes the mechanic spec, a `PRD` + `DEV_TASK` go to `game-feature-team` on profile `game-dev-unity`, accessibility + perf gates pass, and a DECISION_RECORD closes the loop.

## Delegation

Code → `engineering` via `PRD`/`DEV_TASK` with the team chosen from `--type`. If the feature ships gen-AI assets, route those to `garland` as `ASSET_JOB` (fires `ai-content-provenance`). The design head's spec is the only artifact RLM-Gaming authors here.
