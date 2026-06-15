---
description: "The Director-led greenlight — vision to testable pillars to one-pager to GDD, gated on game-design-pillars-testable plus a HITL greenlight."
argument-hint: "<game concept> [--genre <genre>] [--engine unity|unreal|godot|web|spring|custom]"
model: sonnet
---

# /game-greenlight

**The Director** drives a concept from a one-line vision through testable design pillars, a one-pager, and a first-draft Game Design Document (GDD), then puts it through the greenlight gate. This is the executive-layer entry into the studio: nothing else in the pipeline should run until a concept is greenlit. The Director uses the `game-vision-and-pillars` skill to force every pillar to be falsifiable, recalls prior post-mortems so the studio does not repeat dead concepts, and ends by requesting human greenlight authority.

## Steps

1. **Recall** — `eights.memory.search(domain="gaming")` for prior post-mortems and killed concepts in the same genre; carry forward kill-criteria and known traps.
2. **Vision** — The Director writes the one-line vision and the player-fantasy statement using the `game-vision-and-pillars` skill.
3. **Pillars** — derive 3–5 design pillars, each written as a *testable* claim (a measurable player-experience proxy). This is what the `game-design-pillars-testable` gate checks.
4. **One-pager** — pillars + target audience + platforms + reference titles + scope class, in a single page.
5. **GDD draft** — expand into a first-draft GDD skeleton: core loop, systems outline, content scope, narrative premise, monetization stance (flag for `loot-box-jurisdiction` if randomized).
6. **Gate** — fire `game-design-pillars-testable` (owner: The Director, no HITL). If any pillar is not falsifiable, block and return to step 3.
7. **HITL greenlight** — emit `HITL_REQUEST` for the human greenlight decision (retained human authority per the studio model). On approval, write the `DECISION_RECORD` and `eights.memory.add(domain="gaming")`.

## Example

```
/game-greenlight "a cozy farming sim where weather is the antagonist" --genre sim --engine godot
```
The Director recalls two prior cozy-sim post-mortems, drafts four testable pillars (e.g. "a new player survives their first storm within 10 minutes 80% of the time"), passes `game-design-pillars-testable`, and pauses on a greenlight HITL.

## Delegation

No code or assets are delegated at greenlight — the output is a one-pager + GDD draft (markdown design artifacts) and a `DECISION_RECORD`. Downstream, `/game-vertical-slice` and `/game-feature` will emit the `PRD`/`DEV_TASK` (engineering) and `CREATIVE_BRIEF`/`ASSET_JOB` (garland) envelopes. A `C_SUITE_DECISION_PACKET` from the executive squad may seed this command's intake.
