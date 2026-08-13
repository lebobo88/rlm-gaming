---
name: game-qa-and-balance
description: QA strategy and balance DESIGN for the Arcade crown (The Warden + The Playtester). Produces test plans from specs, bot-playthrough script specs, balance Monte-Carlo setups with synthetic players, regression gates, telemetry taxonomies, and the accessibility floor (GAG/XAG/APX/CVAA). Designs the strategy + acceptance — the actual test code is delegated to engineering (pp test-strategist / game-* teams). Ties to game-accessibility-guidelines and game-perf-budget rubrics.
---

# Game QA & balance skill

You are producing a **QA strategy + balance** artifact — the test plan, bot-playthrough
spec, Monte-Carlo setup, telemetry taxonomy, and accessibility checklist that
*define what good looks like* and *how it is verified*. You design the strategy and
the acceptance criteria; you do **not** write the test harness. Automated test code,
bot drivers, and CI wiring ship as a `DEV_TASK` to the `engineering` squad (agent
`test-strategist`, teams `game-feature-team` / `game-accessibility-team`, taxonomy 4.10).

Lead heads: **The Warden** (`qa-balance-lead`, gatekeeper — the QA gate) and **The
Playtester** (`playtest-sim`, synthetic players). Reused pp rubrics:
`game-accessibility-guidelines` and `game-perf-budget` (both `@1`, don't redefine).
See sibling skills `game-netcode-and-multiplayer` (netcode soak) and
`game-art-and-audio-direction` (perf-budget tie-in).

## Anti-patterns to refuse

- **Manual-only QA for a live game.** A live-service or large title relying on
  hand testing alone cannot regression-test every hotfix. REFUSE — require automated
  bot playthroughs (pathing/triggers/win-fail/soak) gating every build. Manual is a
  complement, not the baseline.
- **Balance by vibes (no sim).** Tuning numbers shipped on a designer's gut with no
  Monte-Carlo run. REFUSE — every balance change runs synthetic players across the
  matchup/build space with win-rate, TTK, and economy distributions reported.
- **Accessibility as an afterthought.** A11y "added at the end" or only at cert.
  REFUSE — the accessibility floor (GAG/XAG/APX/CVAA) is a per-feature acceptance
  criterion from design onward (cross-ref `game-accessibility-guidelines`).
- **Perf claims without capture evidence.** "Runs at 60fps" with no profiler
  capture, frame-time graph, or platform-tier breakdown. REFUSE — perf acceptance
  requires captured evidence per platform tier (cross-ref `game-perf-budget`).
- **A test plan with no traceability to the spec.** Tests that don't map to the
  GDD/mechanic_spec acceptance criteria. Every test cites the spec line it verifies.

## Test strategy — the four bot pillars

| Bot pillar | Verifies | Failure = |
|---|---|---|
| **Pathing** | navmesh reachable, no stuck/fall-through | geometry/nav bug |
| **Triggers** | quest/event/scripted triggers fire | scripting regression |
| **Win/fail** | objectives completable AND losable | progression block / softlock |
| **Soak** | N-hour run, no leak/crash/desync | memory/stability/netcode bug |

## Templates

### Template: test strategy doc
```yaml
title: "Parry mechanic — test strategy"
traces_to: [mechanic_spec.md#parry-window, encounter_design_doc.md#boss1]
levels:
  unit:        "parry-window timing (engineering)"
  integration: "parry vs each enemy attack type"
  bot:         [pathing, triggers, win_fail, soak]
  regression:  "every build; gate on green"
acceptance:
  - "parry window 100ms ± tuning asset — verified by timing bot"
  - "no softlock across 1000 bot win/fail runs"
  - "60fps p95 on current-gen — capture required (game-perf-budget)"
  - "remappable + colorblind-safe threat reads (game-accessibility-guidelines)"
delegated_to: engineering(test-strategist)   # test CODE, not this plan
```

### Template: bot-playthrough script spec
```yaml
bot: "main_path_completion"
engine: ue5
drives: "AI-controlled player via input injection (engineering builds the driver)"
route: "tutorial → hub → boss1 → boss2 → ending"
assertions:
  - every objective trigger fires within expected region
  - no fall-through / stuck > 10s (pathing)
  - win reachable AND deliberate-loss reachable (win_fail)
  - 4h soak: heap delta < 5%, 0 crashes, 0 desyncs (netcode)
telemetry_emit: [objective_id, time_to_complete, deaths, fps_p95]
```

### Template: balance Monte-Carlo setup
```yaml
title: "Hero roster balance sweep"
synthetic_players:
  archetypes: [aggressive, defensive, optimal, random_baseline]
  skill_tiers: [novice, average, expert]
matrix: all_hero_vs_hero  (NxN)
runs_per_cell: 5000
report:
  win_rate: "target 50% ± 3% per matchup"
  ttk_distribution: "flag bimodal / degenerate"
  economy: "gold/min per build — flag runaway (cross-ref loot-box-jurisdiction if monetized)"
  difficulty_curve: "death-rate per encounter forms intended ramp"
verdict: balanced | retune(list outliers) | redesign
```

### Template: telemetry taxonomy
```yaml
events:
  session:   { id, platform_tier, build, duration_s }
  combat:    { encounter_id, ttk_ms, deaths, damage_taken }
  economy:   { currency, source, sink, balance }     # source/sink ledger
  progress:  { objective_id, completed, time_s, retries }
  perf:      { fps_p50, fps_p95, hitch_count, vram_mb } # cross-ref game-perf-budget
  a11y:      { settings_enabled: [colorblind, remap, subtitles, ...] }
naming: snake_case, versioned schema, server-validated (no client-trusted economy)
use: drives telemetry-tuning loop → The Custodian live-ops priorities
```

### Template: accessibility checklist (per axis)
| Axis | Floor (GAG/XAG/APX/CVAA) | Acceptance |
|---|---|---|
| Visual | colorblind modes, scalable UI/text, high-contrast, no color-only cues | menu + threat-read pass |
| Motor | full remap, hold→toggle, no required QTE mashing, sensitivity | remap bot pass |
| Auditory | subtitles + speaker ID, visual SFX cues, mono mix option | CVAA-compliant captions |
| Cognitive | difficulty options, objective markers, tutorialization, skip | difficulty-floor pass |
| Speech (CVAA) | text-chat alternative to voice in online | online-comms pass |

## Telemetry-driven tuning & difficulty-curve validation

- Close the loop: ship → telemetry taxonomy → analyze death-rate/retention/economy
  → retune via Monte-Carlo → regression-gate → re-ship. Feeds The Custodian.
- Difficulty curve = death-rate per encounter forms the *intended* ramp; flag
  spikes (frustration) and flats (boredom) against the design target curve.

## Constraints

- The crown designs strategy + acceptance only. Test code, bot drivers, CI wiring →
  `DEV_TASK` to `engineering` (`test-strategist` / `game-*-team`).
- Live games require automated bot playthroughs gating every build — manual-only is
  refused.
- Every balance change is validated by a Monte-Carlo sim with synthetic players
  before ship — no vibes-only tuning.
- Every feature carries an accessibility acceptance from design onward (cross-ref
  `game-accessibility-guidelines`; floors = GAG/XAG/APX/CVAA).
- Every perf claim carries captured profiler evidence per platform tier (cross-ref
  `game-perf-budget`).
- Every test traces to a spec acceptance line; economy telemetry is server-validated
  (cross-ref `server-authority-fairplay` in `game-netcode-and-multiplayer`).
- The Warden's QA gate can block a milestone; surface failures, don't paper over them.
