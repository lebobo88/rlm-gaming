---
description: "Show the Arcade pantheon — all 20 heads grouped by studio layer with mythic name, slug, authority, tier, charter, and the gate each owns. Read-only."
argument-hint: "[layer]"
model: sonnet
---

# /game-roster

A read-only display of the Arcade crown — the 20 heads of the RLM-Gaming studio brain — grouped by the five studio layers. For each head it shows the mythic name, plaza slug, authority, model tier, charter, and which gate (if any) the head owns. Pass an optional `[layer]` (`executive`, `design`, `technical`, `creative`, `evaluation`) to show only that layer. This command renders only; it dispatches no work and emits no envelopes.

## Steps

1. Resolve scope — if `[layer]` is given, filter to that layer; otherwise show all five.
2. Render each head as `Mythic (slug) — authority · tier — charter — owns: <gate rubric or "—">`.
3. Append the crown summary: lead **The Director**; security/Cerberus-equivalent **The Sentinel**; additional gatekeepers **The Warden**, **The Arbiter**, **The Producer**, **The Custodian**.

## Roster

**Executive layer**
- **The Director** (`game-director`) — gatekeeper, crown lead · opus — vision, pillars, greenlight, scope/quality/schedule arbitration; owns master DECISION_RECORD — owns: `game-design-pillars-testable`
- **The Producer** (`producer`) — gatekeeper · sonnet — backlog, milestones, sprints, cross-squad coordination, HITL control points — owns: content-lock HITL
- **The Forgemaster** (`tech-director`) — gatekeeper · opus — engine architecture, tech standards, build-vs-buy, perf budgets — owns: `game-perf-budget`

**Design layer**
- **The Systemsmith** (`systems-designer`) — execute · sonnet — mechanics, systems, combat math, emergence, exploit-resistance — owns: —
- **The Loremaster** (`narrative-director`) — advisory · opus — world bibles, branching narrative, quest graphs, dialogue, themes — owns: —
- **The Cartographer** (`level-design-director`) — execute · sonnet — worlds, levels, mission flow, pacing, PCG, streaming — owns: —
- **The Duelist** (`encounter-designer`) — execute · sonnet — encounters, bosses, enemy archetypes, AI tuning targets — owns: —
- **The Economist** (`economy-designer`) — execute · sonnet — economy, monetization, gacha math, balance sim, retention — owns: `loot-box-jurisdiction` (with The Arbiter)

**Technical layer (delegates to engineering)**
- **The Puppeteer** (`game-ai-director`) — advisory · sonnet — runtime NPC AI (BT/GOAP/HTN/Utility/EQS/perception) — owns: —
- **The Netweaver** (`netcode-lead`) — advisory · sonnet — replication topology, server-authority, rollback/lockstep, host migration — owns: —
- **The Toolwright** (`tools-pipeline`) — execute · sonnet — editor tooling, import/build pipelines, asset processors, CI hooks — owns: —

**Creative layer (delegates to garland)**
- **The Artisan** (`art-director`) — advisory · opus — style bible, art direction, LOD/poly budgets — owns: `ai-content-provenance` (with The Sentinel)
- **The Sculptor** (`3d-modeling-director`) — advisory · opus — 3D geometry/topology standards, retopo/UV/PBR/LOD, pivot/scale/axis, the Blender/DCC commission contract — owns: `mesh-topology-budget`
- **The Conductor** (`audio-director`) — advisory · sonnet — adaptive audio, mix tiers, Wwise/FMOD — owns: —
- **The Choreographer** (`animation-director`) — advisory · sonnet — rigs, IK, blend trees, anim state machines, root-motion — owns: `rig-quality`

**Evaluation layer**
- **The Warden** (`qa-balance-lead`) — gatekeeper · sonnet — test strategy, bot playthroughs, balance Monte-Carlo, telemetry tuning — owns: `game-accessibility-guidelines`
- **The Playtester** (`playtest-sim`) — execute · sonnet — synthetic players/persona sim, fun-proxy metrics, friction reports — owns: —
- **The Custodian** (`liveops-director`) — gatekeeper · sonnet — seasons, events, store A/B, hotfix flow, retention loops — owns: —
- **The Arbiter** (`compliance-cert`) — gatekeeper · opus — ESRB/PEGI/IARC/CERO ratings, platform cert, loot-box jurisdiction, CVAA — owns: `esrb-pegi-iarc-rating`, `platform-cert-readiness`
- **The Sentinel** (`game-security-gate`) — gatekeeper (Cerberus-equiv) · opus — server authority, anti-cheat, exploit threat models, fair-play — owns: `server-authority-fairplay`

## Example

```
/game-roster evaluation
```
Shows the five evaluation-layer heads (The Warden, The Playtester, The Custodian, The Arbiter, The Sentinel) with the gates they own.

## Delegation

None — read-only. To actually dispatch work, use `/game-studio` (master), `/game-greenlight`, `/game-vertical-slice`, `/game-feature`, `/game-liveops-season`, `/game-balance-pass`, or `/game-cert-review`.
