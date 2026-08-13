---
description: "The Custodian-led season plan — telemetry + VoC review, season/event cadence, economy changes (loot-box-jurisdiction gate), asset commissions to garland, store A/B, and a hotfix runbook."
argument-hint: "<season theme/number> [--duration <weeks>] [--monetized]"
model: sonnet
---

# /game-liveops-season

**The Custodian** plans a live-service season end-to-end: reviews telemetry and player Voice-of-Customer, sets the season and event cadence, drives economy changes with The Economist (under the loot-box gate), commissions seasonal assets from `garland`, plans a store-page A/B test, and writes the hotfix runbook. This is Phase 4 ("content factory / live-ops") — semi-autonomous within templates and approval gates, fed by data. Uses the `game-liveops-and-telemetry` skill.

## Steps

1. **Telemetry review** — The Custodian pulls retention/engagement/funnel telemetry; reads the latest **Xenia** VoC report to surface top player pain and demand signals.
2. **Recall** — `eights.memory.search(domain="gaming")` for prior season post-mortems (what cadence/economy moves worked or backfired).
3. **Cadence** — lay out the season + in-season event schedule (duration from `--duration`), with KPI targets per beat, using the `game-liveops-and-telemetry` skill.
4. **Economy changes** — The Economist models source/sink, pricing, and any randomized monetization. If `--monetized` (or any randomized reward), fire `loot-box-jurisdiction` (owner: The Economist/The Arbiter, **HITL**) with per-region notes.
5. **Asset commissions → garland** — emit `CREATIVE_BRIEF` + `ASSET_JOB`s for season skins/banners/music/trailer (`SHOT_LIST` for the trailer); `provenance_required: true`. Fires `ai-content-provenance` on gen-AI assets.
6. **Store A/B** — The Custodian specs the store-page A/B variants and success metric; code/instrumentation work delegated to `engineering` (`game-live-ops-team`) via `DEV_TASK`.
7. **Hotfix runbook** — write the in-season hotfix flow (trigger thresholds, rollback, comms).
8. **HITL + close** — emit `HITL_REQUEST` for the live economy change; on approval write the season `DECISION_RECORD` and `eights.memory.add(domain="gaming")`.

## Example

```
/game-liveops-season "Tideturn — Season 4" --duration 8 --monetized
```
The Custodian reads Xenia VoC (churn spike after the last battle pass), The Economist reworks the sink and battle-pass curve, `loot-box-jurisdiction` pauses on a HITL with NL/BE/JP notes, garland gets the seasonal `ASSET_JOB`s, and a store A/B + hotfix runbook ship in the season DECISION_RECORD.

## Delegation

Assets → `garland` (`CREATIVE_BRIEF`/`SHOT_LIST`/`ASSET_JOB`). Live-ops/store instrumentation code → `engineering` (`DEV_TASK`, `game-live-ops-team`). VoC in from `Xenia`; legal escalation on monetization law → `HANDOFF` to `legal-compliance`. The Custodian authors the season plan, economy sheet, and runbook — not the binaries or the code.
