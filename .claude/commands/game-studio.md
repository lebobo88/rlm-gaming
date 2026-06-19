---
description: "Master entry for the Arcade crown — intake a game goal, recall prior wisdom, route to the right heads/sub-command, and synthesize a DECISION_RECORD."
argument-hint: "<game goal> [--engine unity|unreal|godot|web|spring|custom] [--live-service]"
model: sonnet
---

# /game-studio

The default command for the RLM-Gaming squad. **The Director** runs a full studio workflow end-to-end: it takes a raw game goal, recalls prior post-mortems and gate history from the eights memory fabric, routes the work to the correct specialist sub-command and Arcade heads, and synthesizes the parallel returns into a single master `DECISION_RECORD`. This command orchestrates — it never writes engine code (that goes to `engineering` as a `PRD`/`DEV_TASK`) and never produces media binaries (that goes to `garland` as a `CREATIVE_BRIEF`/`ASSET_JOB`). It reads the `game-studio-pipeline` skill as its routing backbone.

## Steps

1. **Intake** — The Director parses `<game goal>`, the `--engine` flag (→ pp profile `game-dev-<engine>`), and `--live-service` (sets `live_service: true`, arms the `loot-box-jurisdiction` gate). Classify which phase(s) of the five-layer flow the goal touches.
2. **Recall** — query `eights.memory.search(domain="gaming")` for prior post-mortems, failed gates, and platform gotchas relevant to the goal. Surface anything that should constrain scope.
3. **Route** — map intent → sub-command per the pipeline skill's orchestration table:
   - new game from scratch → `/game-greenlight` (The Director)
   - one level, all disciplines → `/game-vertical-slice` (The Director + The Producer)
   - single feature → `/game-feature` (The Producer)
   - season of a live game → `/game-liveops-season` (The Custodian)
   - balance / playtest sweep → `/game-balance-pass` (The Warden + The Playtester)
   - ratings / platform cert → `/game-cert-review` (The Arbiter)
4. **Dispatch & fan-out** — The Producer coordinates; design heads spec, code goes to `engineering`, assets go to `garland`. Each leg returns its own `DECISION_RECORD`.
5. **Gate sweep** — confirm every fired gate has a verdict: `game-design-pillars-testable` (greenlight), `server-authority-fairplay` (if online, The Sentinel), `loot-box-jurisdiction` (if `--live-service`, The Economist/The Arbiter), `game-perf-budget` (The Forgemaster), `game-accessibility-guidelines` (The Warden).
6. **Synthesize** — The Director joins the legs into one master `DECISION_RECORD` with rationale, artifact links, gate verdicts, and preserved dissent. Emit `HITL_REQUEST` for any human-authority point (greenlight, art-style lock, content lock, ship, monetization change).
7. **Encode** — `eights.memory.add(actor="the-director", domain="gaming")` with the decision summary for future recall.

## Example

```
/game-studio "co-op roguelike deckbuilder, 4-player online" --engine unity --live-service
```
The Director recalls a prior netcode post-mortem, routes greenlight → `/game-greenlight`, arms `server-authority-fairplay` (online) and `loot-box-jurisdiction` (live-service), and returns a master DECISION_RECORD with a pending greenlight HITL.

## Delegation

Code → `engineering` (`PRD`/`DEV_TASK`, pp profile from `--engine`). Assets → `garland` (`CREATIVE_BRIEF`/`ASSET_JOB`, C2PA-signed). Strategy escalation in/out via `C_SUITE_DECISION_PACKET` (executive) and `HANDOFF` (legal-compliance/Senate). RLM-Gaming emits only design artifacts, plans, gates, and `DECISION_RECORD`s.

### Delegation contract (machine-readable — Hydra forwards these)

When dispatched through Hydra, return delegated work as typed envelopes under an
`emitted_envelopes` key on your result (a JSON list), **in addition to** the
master `DECISION_RECORD`. Hydra's dispatcher extracts each, stamps
`origin_squad="rlm-gaming"`, and forwards it to its target squad in the same
pass — so the design actually reaches pair-programmer / Helios instead of
stranding as prose.

- **Engine/gameplay code** → one `DEV_TASK` per scoped unit, `target_squad="engineering"`.
  - Required: `owner` (frontend|backend|fullstack|devops|data), `repo` (the game
    repo, e.g. `"candc"`), `branch`, `instructions`.
  - **Set `pp_team`** to the right pair-programmer team: `game-feature-team`
    (default), `game-netcode-team` (online), `game-cert-team` (submission/
    ratings), `game-live-ops-team` (seasons/events), `game-bug-fix-team`,
    `game-refactor-team`, `game-accessibility-team`, or `game-art-pipeline-team`.
    Optionally `pp_profile` (e.g. `game-dev-<engine>`).
  - **Pack the game context INTO `instructions`**: design pillars, perf budget,
    engine/runtime target, and any determinism / server-authority constraints —
    engineering never sees your design docs otherwise. (If `pp_team` is omitted,
    Hydra auto-defaults to `game-feature-team` because the envelope originates
    from rlm-gaming.)
- **Art/audio/3D binaries** → `CREATIVE_BRIEF` / `SHOT_LIST` / `ASSET_JOB`,
  `target_squad="garland"`.

An envelope without `target_squad` still routes by type (DEV_TASK→engineering;
CREATIVE_BRIEF/SHOT_LIST/ASSET_JOB→garland). Honor any `priming` directive Hydra
passes in the skill args — it restates this contract at dispatch time.
