---
name: game-systems-design
description: Systems-designer skill for producing mechanics and systems specs at studio altitude — verbs, inputs/outputs, feedback, failure-states, counter-play, teaching scenarios, difficulty scaling, systemic interactions, combat math, status-effect stacking, the economy of attention, emergence, and exploit-resistance. Read this before designing any mechanic or system. Invoked by The Systemsmith and The Duelist. Complements the engineering-side game-design mechanic-spec template in pair-programmer by adding the systems-interaction and combat-math layers studios use to find emergence and exploits before they ship.
---

# Game systems-design skill

You are producing a **systems-design** artifact — a mechanic spec, a
systems-interaction matrix, or a combat-math sheet. The engineering-side
`game-design` skill in pair-programmer owns the single-mechanic template; this
skill operates one altitude up, where mechanics **interact**, where the
**economy of attention** is budgeted, where **emergence** is designed for, and
where **exploits** are hunted before a player finds them. The deliverable is a
spec the engineering squad implements and The Warden balances — never code.

## The cardinal rule

> Every mechanic has a **failure state** and a **counter-play**. If you cannot
> name how the mechanic fails the player and what the player does to beat the
> mechanic, the mechanic is not designed — it is a wish. "Just dodge" is not
> counter-play; it is the absence of one.

## Anti-patterns to refuse

- **Mechanics with no failure state** — every verb can be mistimed, overused, or
  punished. Name the failure or it isn't designed.
- **"Just dodge" non-counter-play** — counter-play must be a distinct decision
  with its own cost. If the only answer to every attack is the same input, you
  have a single mechanic wearing many hats.
- **Number-soup with no curve** — a wall of damage/cooldown values with no stated
  scaling function. Every number lives on a curve (linear, geometric, logistic,
  step) with a stated reason.
- **Status effects that don't define stacking** — does it refresh, stack
  additively, stack multiplicatively, or cap? Undefined stacking is the #1 source
  of shipped exploits.
- **Mechanics with no teaching scenario** — if you can't name the first encounter
  that teaches it safely, players will learn it by dying confused.
- **Systems with no interaction matrix** — a mechanic listed in isolation hides
  the combo that breaks the game. The interactions ARE the design.
- **Emergence claimed but not budgeted** — "emergent gameplay" with no stated
  combinatorial space is marketing, not design.
- **No attention budget** — stacking 6 simultaneous feedback channels means the
  player perceives none. Budget the economy of attention explicitly.

## Templates

### mechanic_spec template (systems-altitude)

```
# Mechanic — <Name>

## Verb (player input)
<The exact input + window. "Tap A within a 120ms parry window of an enemy
windup." Engine-agnostic; tuning values are assets, not constants.>

## Inputs
<All inputs, including held/charged/contextual variants.>

## Outputs (game-state deltas)
<Damage, position, resource cost, animation lock (frames @ target fps),
status applied, score, world-state flag.>

## Feedback (attention budget)
| Channel | Cue | When | Priority (1=must-perceive) |
| visual  | <hit spark + chromatic pop> | on success | 1 |
| audio   | <metallic ring> | on success | 1 |
| haptic  | <sharp 80ms pulse> | on success | 2 |
<Cap the priority-1 channels at 3 simultaneous; beyond that, perception fails.>

## Failure states (mandatory)
| Failure | Trigger | Punishment | Recoverable? |
| Whiff   | input outside window | 200ms recovery, counterable | yes |
| Overuse | spam beyond resource | resource lockout 2s | yes |

## Counter-play (mandatory, distinct from dodge)
<What the OPPONENT/system does to beat this verb, and what it costs them.
Must be a different decision than "just dodge".>

## Teaching scenario
<The first, safe encounter that teaches this verb. What it CAN'T punish yet,
and the encounter where punishment is first introduced.>

## Difficulty scaling
| Knob | Curve | Easy → Hard multiplier | Tuned by |
| parry window | linear | 160ms → 90ms | Warden balance pass |

## Exploit-resistance note
<The degenerate use you're guarding against and the guard. e.g.
"Parry cannot chain into itself within 100ms to prevent stun-lock loops.">

## Cross-references
<Mechanics this interacts with → systems-interaction matrix rows.>

## Server-authority note (if online)
<What the server validates. e.g. "Server owns hit registration and parry
timing; client parry is predicted + reconciled." Cross-ref
server-authority-fairplay.>

## Accessibility note
<Per-axis. e.g. "Parry window has an assist tier of +60ms; remappable;
non-color-dependent tell." Cross-ref game-accessibility-guidelines.>
```

### Systems-interaction matrix template

The matrix is the emergence map. Read across rows to find the combos; read the
empty cells to find missing design.

```
# Systems-interaction matrix — <Title>

|            | Fire        | Frost        | Oil          | Water       |
| Fire       | —           | melts (clear) | IGNITES (DoT)| extinguish  |
| Frost      | melts       | stacks→shatter| brittle (×2) | freezes     |
| Oil        | IGNITES     | brittle       | —            | spreads     |
| Water      | extinguish  | freezes       | spreads      | —           |

## Designed emergent combos (the wedge)
- Oil + Fire = spreading burn → intentional, teaches in Level 2.
## Exploit watchlist (degenerate combos)
- Frost-shatter on a frozen boss = 8× burst → CAP shatter to 3× on bosses.
## Combinatorial budget
<N mechanics × M targets = X interaction cells; Y designed, Z exploit-guarded.>
```

### Combat-math sheet template

```
# Combat-math sheet — <Title>

## Damage formula
<Stated formula. e.g. dmg = (base × skill_mult) × (1 - armor/(armor+K)) × crit>
<State K, the diminishing-returns constant, and WHY (target TTK curve).>

## Time-to-kill targets (the curve, not soup)
| Matchup | Target TTK | Formula result | On-curve? |
| skilled vs basic | <2.0s | 1.8s | yes |
| basic vs basic   | 4-6s  | 5.1s | yes |

## Status-effect stacking rules (mandatory)
| Status | Stacks? | Rule | Cap | Duration refresh |
| Burn   | yes     | additive DoT | 5 stacks | refresh-on-reapply |
| Stun   | no      | refresh only | 1 | replace |

## Resource economy (economy of attention/inputs)
<Per-second resource generation vs spend; the rotation the design assumes.>

## Exploit-resistance math
<The number that prevents the infinite combo / stun-lock / one-shot.>
```

## Constraints

- Every mechanic MUST name a failure state and a distinct counter-play
  ("just dodge" is rejected).
- Every number MUST sit on a stated curve with a stated reason — no number-soup.
- Every status effect MUST define stacking, cap, and refresh behavior.
- Every system MUST appear in the systems-interaction matrix; isolated mechanics
  hide exploits.
- Every artifact carries an accessibility note (cross-ref
  `game-accessibility-guidelines`); online mechanics carry a server-authority
  note (cross-ref `server-authority-fairplay`); monetized mechanics (e.g.
  pay-affecting stats) carry a per-region note (cross-ref `loot-box-jurisdiction`)
  and must preserve a skill ceiling.
- Cite reference titles for feel and combat-math precedent (e.g. armor curves
  in DOTA 2 / League; parry windows in Sekiro / Lies of P).
- Produces only design/spec markdown. Combat tuning *values* ship as assets to
  engineering; balance simulation belongs to The Warden. Never produce code or
  binaries — see `game-studio-pipeline`.
