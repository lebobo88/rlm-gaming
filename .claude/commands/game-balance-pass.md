---
description: "The Warden + The Playtester run a synthetic playtest, balance Monte-Carlo, and telemetry tuning, then route tuning recommendations to the design heads with an accessibility-floor check."
argument-hint: "<system/encounter to balance> [--telemetry] [--iterations <n>]"
model: sonnet
---

# /game-balance-pass

**The Warden** (QA/balance) and **The Playtester** (synthetic players) run a balance sweep: persona-driven synthetic playtests, a balance Monte-Carlo simulation, and telemetry-informed tuning, producing concrete tuning recommendations that route back to the owning design heads — and a check that no change drops the game below its accessibility floor. Uses the `game-qa-and-balance` skill. This command tunes existing design; it does not create new features.

## Steps

1. **Frame** — The Warden defines the balance question, the fun-proxy metrics, and the win/clear-rate targets for the named system/encounter.
2. **Synthetic playtest** — The Playtester runs persona simulations (casual/core/speedrunner/exploiter), emitting friction reports and fun-proxy deltas.
3. **Monte-Carlo** — The Warden runs the balance Monte-Carlo over `--iterations` to find dominant strategies, dead options, and difficulty cliffs.
4. **Telemetry tuning** — if `--telemetry`, fold in live clear-rate/drop-off/build-popularity data to ground the sim against reality.
5. **Recommendations** — synthesize tuning recommendations and route each to its owner: combat/systems numbers → The Systemsmith; encounter/boss/AI tuning → The Duelist; economy/drop/progression curves → The Economist.
6. **Accessibility floor** — fire `game-accessibility-guidelines` (owner: The Warden) to confirm no tuning change raises the skill floor past the accessibility baseline (e.g. assist-mode targets still clearable).
7. **Close** — The Warden writes the balance `DECISION_RECORD` with the recommendation table and verdicts; `eights.memory.add(domain="gaming")`.

## Example

```
/game-balance-pass "ranged-vs-melee weapon parity" --telemetry --iterations 5000
```
The Playtester finds melee unviable above tier 3, the Monte-Carlo confirms a ranged-dominant meta, telemetry agrees, and The Warden routes per-weapon tuning to The Systemsmith plus a difficulty-floor note to The Duelist — all while passing the accessibility-floor check.

## Delegation

This is largely an in-crown evaluation; tuning recommendations are design artifacts handed to design heads. If a recommendation requires a code/tuning-table change, the owning head emits a `DEV_TASK` to `engineering` (`game-bug-fix-team` or `game-feature-team`). No assets are commissioned.
