---
name: game-ai-behavior
description: Runtime NPC AI DESIGN for the Arcade crown (The Puppeteer). This is the design side of in-game enemy/NPC behavior — pattern selection (FSM/BT/GOAP/Utility/HTN/EQS/ML-Agents), blackboard key design, perception modules, and NavMesh strategy — NOT generative AI and NOT runtime code. Read before authoring any AI tuning targets in an encounter_design_doc or before emitting a DEV_TASK for AI work. The crown specs; pp game-ai-programmer implements.
---

# Game runtime-AI behavior skill

You are producing a **runtime NPC AI design** artifact — the spec an engineer reads
to build enemy/companion/ambient AI. You design the *shape* of the behavior (which
pattern, which blackboard keys, which perception, which navigation). You do **not**
write engine code: a behavior-tree node, a GOAP planner, an EQS generator, or a
perception component is engineering work and ships via a `DEV_TASK` to the
`engineering` squad (team `game-feature-team`, agent `game-ai-programmer`,
taxonomy 4.6/4.8). "AI" here means the AI that drives a goblin, not a diffusion
model — generative-asset AI goes to `garland`.

Lead head: **The Puppeteer** (`game-ai-director`, advisory). Cross-references the
`game-perf-budget` rubric (AI tick cost) and `server-authority-fairplay` (any AI
input touching damage/loot/state must be server-authoritative — see sibling skill
`game-netcode-and-multiplayer`).

## Anti-patterns to refuse

- **Hardcoded enemy values inside an engine class.** Health, damage, aggro radius,
  attack cooldown, perception ranges baked into C++/C#/GDScript are non-tunable by
  designers and break the designer-vs-programmer split. REFUSE and point to the
  data container: UE5 `UDataAsset`/`UDataTable` row, Unity `ScriptableObject`,
  Godot `Resource`/`.tres`. Every numeric in this spec must name its asset home.
- **NPCs with no perception.** An enemy that knows the player's position by
  omniscience (raw transform read) feels artificial and is unfair. Every agent
  with combat or stealth relevance gets a `perception_module` — even a cheap one
  (single 90° sight cone + 1 hearing radius). Refuse a "shoots on spawn" mob.
- **ML-first proposals without a training-rig justification.** Do not reach for
  Unity ML-Agents / learned policies unless the spec documents the training
  environment, the reward function, the deployment/inference budget, and *why*
  hand-authored authoring fails. ~95% of shipped game AI is hand-authored. Default
  to BT/Utility; treat ML as prototype-only until proven.
- **One mega-pattern for everything.** A 200-node behavior tree doing economy,
  combat, and idle chatter. Split by concern; pick the cheapest pattern per agent
  class. Document the rationale.
- **Pathfinding without a NavMesh strategy.** "It'll just use NavMesh" is not a
  spec. Name bake settings, agent radius/height/slope, dynamic-obstacle handling,
  and off-mesh links (jumps/ladders/doors).

## Pattern selection — when to use which

| Pattern | Use when | Avoid when | Engine fit |
|---|---|---|---|
| **FSM** | Stateful but simple (turret, door guard, ≤6 states) | States explode combinatorially | All engines; Godot native state-machine |
| **Behavior Tree** | Tactical AI designers tune visually; the default | Long-horizon planning needed | UE5 BT (1st-class); Unity Behavior graph |
| **GOAP** | Adaptive enemies that re-plan (F.E.A.R.-style) | Designers can't predict emergent chains; CPU tight | Custom planner all engines |
| **Utility** | "Score all actions, pick best" (Sims, life-sim, ambient) | Hard ordering guarantees needed | Curves as data assets |
| **HTN** | Complex coordinated squads (F.E.A.R. 3, Horizon) | Small team, no planner budget | Custom; pairs with BT leaves |
| **EQS** | Spatial reasoning *on top of* a BT (find cover/flank) | Non-spatial decisions | UE5 only (native) |
| **ML-Agents** | Trained policy, justified rig | Production ship without rig doc | Unity (prototype) |

## Per-engine mapping

- **Unreal Engine 5** — `Behavior Tree` + `Blackboard` + `EQS`; perception via
  `AIPerceptionComponent` (sight/hearing/damage senses); `AI Controller` owns the
  BT; tunables in `UDataAsset`. Spatial queries = EQS generators + tests scored
  by the BT. NavMesh = `RecastNavMesh` + `NavLinkProxy` off-mesh links.
- **Unity** — `Unity Behavior` (graph) or `ScriptableObject`-driven FSM; `Unity AI
  Navigation` package (`NavMeshSurface`, `NavMeshObstacle` carve, `NavMeshLink`).
  Tunables = `ScriptableObject`. ML only via ML-Agents with rig doc.
- **Godot** — code/`Resource` state-machine; perception via `Area3D`/raycast cones;
  navigation via `NavigationServer3D` + `NavigationRegion3D` + `NavigationLink3D`.
  Tunables = `Resource` (`.tres`).
- **Spring/Recoil (RTS)** — *group* AI, not per-unit BTs: production queues, build
  orders, threat maps, formation/flocking. MUST be deterministic for lockstep
  (no per-frame `rand()` seeded per client; no float-divergent perception). See
  `game-netcode-and-multiplayer` for the determinism contract.
- **Web (Babylon/Three/Phaser/PlayCanvas)** — lightweight FSM/Utility in JS/TS;
  navigation via recast-navigation-js or grid A*; keep tick budget tiny.

## Designer-vs-programmer split (state it in every spec)

| Designer authors (data) | Programmer authors (code → DEV_TASK) |
|---|---|
| BT graph topology, blackboard keys | BT node/decorator/service implementations |
| Utility curves, GOAP action list & costs | GOAP planner, Utility evaluator |
| Perception ranges, threat-decay rates | Perception component, sense fusion |
| NavMesh agent profile, off-mesh placements | NavMesh build pipeline, link traversal |
| Tuning numbers (in DataAsset/SO/Resource) | The DataAsset/SO/Resource schema |

## Templates

### Template: `ai_pattern_choice`
```yaml
agent_class: "Hollow Knight (elite melee)"
engine: ue5
chosen_pattern: behavior_tree + eqs
rationale: >
  Tactical reposition/flank needs spatial scoring (EQS) but decisions are
  designer-tunable in a graph; no re-planning horizon ⇒ GOAP overkill.
rejected: { goap: "no adaptive re-plan needed", ml: "no training rig justified" }
tick_budget_ms: 0.4          # cross-ref game-perf-budget
authority: server            # online ⇒ cross-ref server-authority-fairplay
```

### Template: behavior-tree design
```
Root (Selector)
 ├─ [Decorator: Blackboard.IsDead==false]
 ├─ Combat (Sequence)
 │   ├─ Service: UpdateThreat (every 0.25s)        ← programmer
 │   ├─ EQS: FindFlankPoint (FlankPosition)        ← designer picks generator
 │   └─ Task: MoveTo(FlankPosition) → Attack(Target)
 └─ Patrol (Sequence) … 
Blackboard keys:
  Target:Object  LastKnownPos:Vector  ThreatLevel:Float(0..1)
  FlankPosition:Vector  IsDead:Bool  AlertState:Enum{Idle,Suspicious,Alert}
Tunables → BossTuning.DataAsset { aggroRadius, flankDist, attackCooldown }
```

### Template: GOAP action set (precondition / effect / cost)
| Action | Precondition | Effect | Cost |
|---|---|---|---|
| MoveToCover | HasCover & !InCover | InCover | dist×0.1 |
| Reload | InCover & Ammo<Max | Ammo=Max | 2.0 |
| Suppress | Ammo>0 & SeeTarget | TargetSuppressed | 1.0 |
| Flank | TargetSuppressed | HasFlankAdv | 3.0 |
Goal: `KillTarget` (planner = engineering). Costs live in a DataAsset/SO/Resource.

### Template: perception module
```yaml
senses:
  sight:   { fov_deg: 110, range_m: 25, los_check: true, period_s: 0.2 }
  hearing: { radius_m: 15, gunshot_mult: 3.0 }
  damage:  { instant_alert: true }
threat_model:
  on_sight: +1.0/s   on_lost_los: decay 0.3/s
  alert_threshold: 0.6   suspicious_threshold: 0.2
  last_known_pos: search 8s then return to patrol
```

### Template: navmesh strategy
```yaml
engine: ue5
agent_profile: { radius_cm: 42, height_cm: 192, max_slope_deg: 44, step_cm: 40 }
bake: static_with_runtime_generation   # bakes with level
dynamic_obstacles: true                # destructibles/moving cover carve
off_mesh_links: [ "jump_gap_2m", "ladder_up", "door_breach" ]
fallback: "if no path → idle + bark, never teleport"
```

## Constraints

- The crown produces design only. Implementation, NavMesh build pipeline, and any
  node/planner/perception *code* → `DEV_TASK` to `engineering` (`game-ai-programmer`).
- Every numeric tunable names its data home (DataAsset / ScriptableObject / Resource).
- Every combat/stealth-relevant agent has a `perception_module`.
- Every spec carries a per-agent AI tick budget (cross-ref `game-perf-budget`).
- Any AI input affecting damage/loot/currency/state is server-authoritative
  (cross-ref `server-authority-fairplay` and `game-netcode-and-multiplayer`).
- RTS/lockstep group AI must be deterministic — no client-seeded RNG, no
  float-divergent state.
- ML/learned policy requires a documented training rig + reward + inference budget,
  or it is refused as ML-first.
