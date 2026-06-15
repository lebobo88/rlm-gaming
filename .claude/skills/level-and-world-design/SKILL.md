---
name: level-and-world-design
description: Level-design-director skill for producing level and world specs at studio altitude — pacing diagrams annotated with the verb, critical-vs-optional paths with jump/traversal margins, encounter maps, PCG + LLM generation pipelines with constraint solving, navigation graphs, and streaming/occlusion/perf-aware layout in ENGINE UNITS. Read this before designing any level, world, or generation pipeline. Invoked by The Cartographer and The Duelist. Complements the engineering-side game-design level-greybox template in pair-programmer by adding per-genre pacing, PCG constraint specs, and streaming-budget awareness.
---

# Level- and world-design skill

You are producing a **level/world** artifact — a greybox, a pacing diagram, a
spawn table, a navigation annotation, or a PCG pipeline spec. The
engineering-side `game-design` greybox template in pair-programmer covers the
flat layout; this skill adds the pacing-verb annotation, the traversal margins,
the constraint-solved generation pipeline, and the streaming/perf budget that
keeps the world in frame. The deliverable is a spec engineering blocks out and
The Warden paces — never a built level, never a mesh.

## The cardinal rule

> Every peak and valley in a pacing diagram is annotated with the **VERB** that
> produces it. "Areas with combat arenas" is not level design; "60s of
> traverse-and-scan (valley) → 90s of parry-three-elites (peak) → 30s of
> environmental-puzzle breather (valley)" is. If a beat has no verb, it has no
> pacing.

## Anti-patterns to refuse

- **"Areas with combat arenas"** — geometry with no intent. Annotate the verb
  and the tension it produces.
- **Levels with no pacing verb** — a layout with no tension graph. Peaks and
  valleys must each name the player verb that creates them.
- **PCG with no constraints** — "procedurally generated levels" with no solver
  constraints produces slop. State the constraints (reachability, difficulty
  budget, landmark cadence) the generator/LLM must satisfy, and the validator.
- **Ignoring streaming/perf budget** — a sprawling level with no streaming-cell
  plan, no occlusion strategy, and no per-cell triangle/draw-call budget will
  hitch on the target tier.
- **Critical path with no margins** — a required jump with no stated margin
  (min/ideal/max gap) is a soft-lock waiting to happen.
- **Optional paths that reward nothing** — side routes must reward (resource,
  lore, shortcut) or they're filler.
- **Unitless dimensions** — "a large room" is not a spec. Use engine units:
  Unity = meters, Unreal = centimeters, Godot = meters. State which.

## Templates

### level_greybox template (ASCII / Mermaid top-down)

```
# Level greybox — <Name>   | Engine units: Unreal (cm)  | Perf tier: tier-1

## Top-down (legend: S=start E=exit ◆=encounter ★=reward ▓=wall ~=streaming seam)
```
  S···············~···············
  ·▓▓▓▓◆▓▓▓·······~····★··········
  ·····│·········~·······▓▓▓▓·····
  ·····└──────◆──~────────────E···
```
## Streaming cells
| Cell | Bounds (cm) | Tri budget | Draw calls | Loads when | Unloads when |
| A    | 0–25600 x  | 1.2M       | 1800       | spawn      | enter C      |

## Occlusion strategy
<Portals / HLOD / Nanite cluster culling / occlusion volumes. State per tier.>
```

### Pacing diagram template (verb-annotated)

```
# Pacing diagram — <Level>

Tension
  ^         ╱╲              ╱╲(CLIMAX)
  |   ╱╲   ╱  ╲   ╱╲      ╱   ╲
  |__╱  ╲_╱    ╲_╱  ╲____╱     ╲___
  +----------------------------------> time
   v1   v2  p1   v3  p2  v4  PEAK

| Marker | t (s) | VERB | Tension | Notes |
| v1 | 0–60   | traverse-and-scan | low  | teach traversal safely |
| p1 | 60–150 | parry 3 elites    | high | first real test |
| v3 | 150–180| environmental puzzle | low | breather, no combat |
| PEAK | 360–460 | boss, 3 phases  | max  | climax; see encounter map |
<Rule of thumb: no two adjacent peaks without a valley between; 1 climax.>
```

### Spawn table template

```
# Spawn table — <Level / encounter ◆id>

| Spawn id | Trigger (volume/flag) | Enemies | Count | Difficulty budget | Mechanic tested |
| sp_01    | enter volume A        | grunt   | 4     | 12 pts            | crowd control |
| sp_boss  | flag boss_room        | elite×2+boss | —  | 80 pts           | parry + dodge |

Difficulty budget = Σ(enemy cost); MUST sit on the level's budget curve.
Server-authority (if online): spawns are server-owned; clients receive replicated
spawn events. Cross-ref server-authority-fairplay.
```

### Navigation annotation template

```
# Nav annotation — <Level>

## Traversal margins (critical path)
| Gap id | Min (cm) | Ideal | Max (player can clear) | Margin | Assist? |
| jump_1 | 300      | 450   | 620                    | safe   | +80cm assist tier |

## Navigation graph
<Nav volume bounds, jump links, off-mesh links, ladder/teleport nodes.
For AI: which links are agent-traversable; cross-ref game-ai-director EQS/NavMesh.>

## Critical vs optional
| Path | Type | Required verb | Reward | Soft-lock guard |
| main | critical | double-jump | progress | checkpoint before jump_1 |
| vault| optional | wall-run    | currency cache | — |
```

### PCG + LLM pipeline template

```
# PCG pipeline — <System>

## Generator
<WFC / graph-grammar / room-template stitching / LLM-prompted layout.>

## Constraints (the solver MUST satisfy — this is the design)
- Reachability: exit reachable from start with the available verb set.
- Difficulty: Σ encounter budget within ±10% of target curve per depth.
- Landmark cadence: a memorable landmark every <90–120s> of traversal.
- Anti-repetition: no identical room within 3 rooms.
- Perf: each cell ≤ tri/draw budget for the tier.

## Validator (rejects bad output — required)
<Automated check that runs every generated level; failures regenerate.
LLM-generated content is constrained + validated, never shipped raw.>

## Per-region / accessibility / server note
<If layout affects monetized pacing → per-region note. Accessibility: assist
margins above. If online: server owns the seed + validates layout.>
```

## Per-genre notes

- **FPS** — sightline + cover spacing in engine units; flow through chokepoints;
  spawn-safety radius. Pace via firefight intensity, not room count (ref: DOOM
  2016 push-forward arenas).
- **RPG** — hub-and-spoke with traversal shortcuts unlocking back to hub; pace
  via quest-density valleys (ref: Elden Ring legacy dungeons).
- **RTS (Spring/Recoil)** — map balance: symmetric resource access, expansion
  margins, choke economy; pace via macro/micro tension, not scripted beats.
- **Platformer** — traversal margins are THE spec; teach-verb-then-test-verb room
  cadence (ref: Celeste B-side escalation).
- **Open-world** — streaming cells + LOD/HLOD rings are first-class; landmark
  cadence drives pacing across an unscripted route.

## Constraints

- Every pacing beat MUST be annotated with the producing verb; "combat arena"
  alone is rejected.
- Every critical-path traversal MUST state min/ideal/max margins and a soft-lock
  guard.
- Every PCG/LLM pipeline MUST state solver constraints AND a validator; raw
  generated content is never shipped.
- Every spatial dimension MUST be in named engine units (Unity m / Unreal cm /
  Godot m) with a per-cell streaming + perf budget against the target tier
  (reuse the pp `game-perf-budget` rubric; do not redefine it).
- Every artifact carries an accessibility note (assist margins, navigation aids;
  cross-ref `game-accessibility-guidelines`); online layouts carry a
  server-authority note (cross-ref `server-authority-fairplay`); layouts that
  gate monetized pacing carry a per-region note (cross-ref
  `loot-box-jurisdiction`).
- Cite reference titles per genre for pacing and traversal feel.
- Produces only design/spec markdown. Blockout meshes and built geometry are a
  `DEV_TASK` to engineering (`level-designer`) or an `ASSET_JOB` to garland;
  never author geometry here. See `game-studio-pipeline`.
