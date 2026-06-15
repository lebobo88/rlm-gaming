---
name: game-engine-targets
description: THE deep cross-engine reference for the Arcade crown. Read this before any engine-selection decision or per-engine tech-design checklist. Covers conventions, asset/data patterns, runtime AI, netcode, perf tooling, and build/cert path for Unity, Unreal Engine 5, Godot, Web (Babylon.js/Three.js/Phaser/PlayCanvas), Spring/Recoil RTS, and custom engines — plus when to pick which. Owned by The Forgemaster; maps to the pair-programmer game-dev-unity/unreal/godot/web/custom profiles. Produces selection matrices and tech-design checklists only — implementation is a DEV_TASK to engineering. Always pins perf claims to the game-perf-budget rubric tiers.
---

# Game engine-targets skill

You are producing an **engine-selection or per-engine tech-design artifact**: an
engine-selection matrix, a per-engine technical-design checklist, a perf-tooling
capture plan, or a build-and-cert path. You are **The Forgemaster**
(`tech-director`). You set engine standards and tech direction; you delegate
implementation as a `PRD`/`DEV_TASK` to `engineering`, which picks the matching
pair-programmer profile (`game-dev-unity` / `-unreal` / `-godot` / `-web` /
`-custom`). Your outputs are matrices, checklists, and a `DECISION_RECORD`.

## When to pick which (decision heuristics)

| If… | Lean | pp profile |
|---|---|---|
| C#-fluent team, 2D/3D, broad platform reach, mobile + console | **Unity** | game-dev-unity |
| AAA fidelity, large worlds, photoreal, strong cinematics | **Unreal Engine 5** | game-dev-unreal |
| Small team, 2D-first or light 3D, OSS / no-royalty, fast iteration | **Godot** | game-dev-godot |
| Instant-play, web distribution, no install, ads/portal F2P | **Web** (Babylon/Three/Phaser/PlayCanvas) | game-dev-web |
| Massive-unit RTS, deterministic lockstep, mod-driven | **Spring/Recoil** | game-dev-custom |
| Bespoke runtime, extreme control, novel tech | **Custom** | game-dev-custom |

Never choose by hype. Justify against: team skill, target platforms + perf tier
(cite `game-perf-budget`), genre, content scale, monetization, and licensing.

## Per-engine reference

### Unity (pp `game-dev-unity`)
- **Conventions:** C#; component/MonoBehaviour; `asmdef` assembly definitions for
  build-time + dependency hygiene; URP (broad/mobile), HDRP (high-end), built-in
  (legacy); DOTS/ECS for massive entity counts.
- **Data patterns:** `ScriptableObject` for data-driven config (no hardcoded
  tuning); **Addressables** for asset/memory management + content delivery; avoid
  Resources/ folder.
- **AI:** Unity AI Navigation (NavMesh + agents); behavior via your own BT/Utility
  layer (no first-party BT).
- **Netcode:** Netcode for GameObjects (NGO) or Mirror/Photon; server-authoritative.
- **Perf tooling:** Unity Profiler, Memory Profiler, Frame Debugger, IL2CPP for
  shipping builds. → capture `.uprofile` for `game-perf-budget` evidence.
- **Build/cert:** IL2CPP + per-platform export; console SDKs via verified partners.
- **Gotchas:** GC spikes from per-frame allocations; Resources-folder bloat;
  managed-vs-IL2CPP behavior diffs; addressables-catalog versioning.

### Unreal Engine 5 (pp `game-dev-unreal`)
- **Conventions:** C++ core + Blueprints for designers; favor C++ for hot paths,
  BP for orchestration. Modules + `.uproject`/`.uplugin`.
- **Data patterns:** `UDataAsset` / `UPrimaryDataAsset` + Data Tables for
  data-driven config; Asset Manager for streaming.
- **AI:** Behavior Trees + Blackboard + EQS (Environment Query System); AI
  Perception; NavMesh / Navigation system.
- **Rendering:** Nanite (virtualized geometry), Lumen (GI), World Partition +
  HLODs for large worlds, MetaHuman.
- **Netcode:** Actor replication; **Replication Graph** for relevancy at scale;
  server-authoritative; Iris (newer) replication.
- **Perf tooling:** **Unreal Insights** (`.utrace`), `stat` commands, GPU
  Visualizer, RenderDoc/PIX. → capture `.utrace` for `game-perf-budget` evidence.
- **Build/cert:** UAT (Unreal Automation Tool) cooking + packaging per platform.
- **Gotchas:** Nanite vs. masked/foliage cost; Lumen cost on lower tiers; cook
  times; BP-to-C++ perf cliffs; World Partition streaming hitches.

### Godot (pp `game-dev-godot`)
- **Conventions:** GDScript (fast iteration) or C# (.NET build); scene/node tree;
  signals for decoupling. MIT — no royalties.
- **Data patterns:** custom `Resource` types (.tres/.res) for data-driven config;
  export templates per platform.
- **AI:** `NavigationServer3D`/`NavigationServer2D`; behavior via own BT/state code.
- **Netcode:** high-level multiplayer API (RPCs, MultiplayerSynchronizer);
  server-authoritative patterns hand-rolled.
- **Perf tooling:** built-in profiler + monitors; modest tooling vs. Unity/Unreal.
- **Build/cert:** export templates; console support via third-party (W4 Games etc.).
- **Gotchas:** thinner console story; GDScript perf ceiling (move hot code to C#/
  GDExtension); smaller middleware ecosystem.

### Web (pp `game-dev-web` — Babylon.js / Three.js / Phaser / PlayCanvas)
- **Babylon.js:** batteries-included 3D engine; WebGL2/**WebGPU**; good tooling.
- **Three.js:** lower-level 3D rendering lib; you build the engine layer.
- **Phaser:** 2D-first arcade/HTML5 games.
- **PlayCanvas:** 3D engine + cloud editor; strong for ads/instant.
- **Budgets (hard):** initial **bundle ≤ ~5–15 MB** gz to first-playable; stream
  the rest; watch **GC pauses** (pool objects, avoid per-frame allocation); target
  WebGPU where available, WebGL2 fallback. Mobile-web maps to `game-perf-budget`
  Mobile B/C tiers.
- **Asset streaming:** progressive load, texture compression (KTX2/Basis), LOD.
- **Build/cert:** Apple/Google review only if wrapped; otherwise web/portal review.
- **Gotchas:** ignoring bundle/GC budget = stutter + bounce; main-thread blocking;
  no shared GPU memory guarantees; cross-browser WebGPU gaps.

### Spring/Recoil RTS (pp `game-dev-custom`)
- **Conventions:** Lua gadgets/widgets (game logic / UI); engine in C++.
- **Data patterns:** `unitdefs` / weapondefs (data-driven unit config).
- **Determinism:** **lockstep determinism is mandatory** — every client simulates
  the same step from the same inputs; floating-point + RNG must be deterministic
  and seeded identically. A desync is a hard bug.
- **AI / pathing:** flow-field / hierarchical pathing for thousands of units.
- **Netcode:** lockstep (send inputs, not state); host-authoritative seed.
- **Perf tooling:** sim-step profiling; unit-count stress tests.
- **Gotchas:** any non-deterministic op (unsynced RNG, float order, wall-clock)
  desyncs the match; cross-ref `game-security-and-anticheat` (client-seeded
  lockstep RNG is forbidden).

### Custom (pp `game-dev-custom`)
- **Conventions:** data-driven config (no hardcoded tuning); hot-reload of data +
  scripts for iteration; explicit memory + frame budgets from day one.
- **Justify** building custom against buy/license — engine-build is a multi-year
  cost; require an explicit `DECISION_RECORD` rationale.
- **Gotchas:** reinventing tooling; cert maturity; no ecosystem; perf tooling you
  must build yourself (still owe `game-perf-budget` capture evidence).

## Anti-patterns to refuse

- **Engine choice by hype.** No "use Unreal because it's AAA" without a matrix
  scoring team skill, platforms, perf tier, genre, scale, monetization, licensing.
- **Ignoring the platform perf tier.** Any engine/feature decision that doesn't
  reconcile against the target `game-perf-budget` tier (Switch ARM-bound 0.5–2M
  tris, Mobile C <0.5M tris, Quest 3 90fps/11.11 ms). Nanite/Lumen on a Switch
  target, or a 4M-tri scene on Mobile B, is a refuse.
- **Hardcoded values vs. data assets.** Tuning constants baked in code instead of
  ScriptableObjects / DataAssets / Resources / unitdefs / custom data. Refuse.
- **Web game ignoring bundle/GC budget.** No first-playable bundle ceiling, no
  object pooling / GC plan, no streaming strategy → refuse for web targets.
- **RTS ignoring lockstep determinism.** Any Spring/Recoil (or lockstep) design
  without a determinism + seeded-RNG guarantee. Cross-ref
  `game-security-and-anticheat`.

## Templates

### engine-selection matrix
```
Criterion (weight)        Unity  UE5  Godot  Web  Spring  Custom
team skill (0.25)
target platforms (0.20)
perf tier fit (0.15)      ← cite game-perf-budget target tier
genre/content scale (0.15)
monetization fit (0.10)
licensing/royalty (0.10)
ecosystem/tooling (0.05)
WEIGHTED TOTAL → recommendation + pp profile + DECISION_RECORD rationale
```

### per-engine tech-design checklist
```
[ ] Engine + render pipeline chosen (URP/HDRP | Nanite/Lumen | WebGPU | …)
[ ] Data-driven config pattern named (SO | DataAsset | Resource | unitdef | custom)
[ ] Runtime AI approach (NavMesh+BT | BT/Blackboard/EQS | NavigationServer3D | flow-field)
[ ] Netcode topology (server-auth | lockstep) → cross-ref game-security-and-anticheat
[ ] Perf budget tier declared + tooling chosen (Profiler/.utrace/RenderDoc/PIX)
[ ] Build/cert path (IL2CPP | UAT cook | export templates | web wrap)
[ ] Engine-specific gotchas acknowledged
```

### perf-tooling capture plan
```yaml
target_tier: "PS5/XSX 60fps (16.67ms)"   # from game-perf-budget
scenes: [combat, hub, menu, loading]
captures:
  cpu_gpu_frame: { tool: "Unreal Insights .utrace | Unity .uprofile", per_scene: true }
  memory: { tool: "RenderDoc/PIX/Memory Profiler", vram_ceiling: "16 GB shared" }
  draw_calls: { tool: profiler, ceiling: "5–15k" }
  input_latency: "measured motion-to-photon (not estimated)"
evidence -> game-perf-budget rubric (pass needs capture per metric per tier)
```

### build-and-cert path
```
SOURCE → engine cook/build (IL2CPP | UAT | export templates | web bundle)
       → per-platform package
       → game-cert-and-compliance (TRC/XR/Lotcheck/Steamworks/store)
       → DEV_TASK to engineering for any cert defect
```

## Constraints

- Never write engine code inline — emit a `PRD`/`DEV_TASK` to `engineering` with
  the chosen pp profile (`game-dev-unity|unreal|godot|web|custom`).
- Every engine/feature decision reconciles against the target `game-perf-budget`
  tier and carries a capture plan; perf claims need captured evidence, never
  estimates.
- Data-driven config is mandatory — no hardcoded tuning constants in any engine.
- Web targets declare a bundle + GC + streaming budget; RTS/lockstep targets
  declare a determinism + seeded-RNG guarantee (→ `game-security-and-anticheat`).
- Engine selection is matrix-justified and recorded in a `DECISION_RECORD`; build
  hands off to `game-cert-and-compliance` for the cert path.
