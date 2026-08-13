---
name: game-3d-modeling-and-dcc
description: 3D modeling and DCC (Blender) pipeline standards for the Arcade crown (The Sculptor). Produces geometry execution standards — topology / edge-flow rules, retopo targets, UV / lightmap layout, PBR channel sets, LOD chains, pivot/scale/axis conventions — and the Blender/DCC commission contract that garland's blender-model / blender-rig sub-agents execute via the existing blender-mcp backend. The crown never models, retopologizes, or drives Blender inline; it writes the DCC contract and emits an ASSET_JOB (model_type:mesh|rig, provenance_required:true) to garland. Ties to the mesh-topology-budget gate and (for gen-AI assets) ai-content-provenance.
---

# Game 3D modeling & DCC pipeline skill

You are producing a **3D geometry direction** artifact — the topology rules,
budgets, UV/PBR specs, LOD chains, axis conventions, and the **DCC commission
contract** that *commission and constrain* 3D asset production. You do **not**
model, retopologize, UV-unwrap, bake, or export a single mesh. The cardinal
handoff: the crown writes the DCC contract, then emits an `ASSET_JOB`
(`model_type: mesh | rig`) to the `garland` squad, whose Helios 3D crew
(`blender-model`, `blender-rig`) executes it through the existing **blender-mcp**
backend and whose `governance-c2pa` signs the result.

Lead head: **The Sculptor** (`3d-modeling-director`, advisory). Hard bar:
returned 3D assets pass the `mesh-topology-budget` rubric; skinned assets also
pass `rig-quality` (The Choreographer, see `game-rigging-and-animation-pipeline`);
any gen-AI 3D binary passes `ai-content-provenance` (HITL). Budgets cross-ref
`game-perf-budget` (The Forgemaster) and the art bible's poly ceiling (The
Artisan, `game-art-and-audio-direction`).

## The cardinal handoff

> The crown COMMISSIONS; garland MODELS; garland SIGNS.
> A DCC contract (markdown spec + budgets + reference *links*) → `ASSET_JOB` with
> `model_type: mesh` (props/environment) or `model_type: rig` (skinned characters)
> and `provenance_required: true`. If you are about to open Blender, call a
> blender-mcp tool, edit a `bpy` data-block, or export a `.blend`/`.fbx`/`.glb`/
> `.usd`, you have crossed the boundary — emit the envelope instead.

## Boundary with The Artisan (no overlap)

- **The Artisan** owns *visual style* + perf-facing budgets: palette, silhouette,
  material/lighting language, draw-calls, texture memory, the headline poly ceiling.
- **The Sculptor** owns *geometry execution*: topology / edge-flow, retopo targets,
  UV / lightmap layout, PBR channel set, LOD-chain construction, pivot/scale/axis.
- One asset, two bars: The Artisan's **style-similarity** (does it match the bible?)
  and The Sculptor's **mesh-topology-budget** (is it built right?).

## Modeling approach decision (pick per asset class)

| Asset class | Approach | Why | DCC technique |
|---|---|---|---|
| Hard-surface props / weapons / modular kit | **BMesh / parametric** | exact control, reuse, clean bevels | `bmesh` scripted primitives, modifiers, kitbash |
| Environment / scatter / cities / foliage | **Geometry Nodes (procedural)** | parameter-driven, instanced, LOD-friendly | node group + exposed inputs → "Visual Geometry to Objects" bake |
| Organic characters / creatures | **AI base mesh + retopo** | speed; humans are slow on organics | text/image-to-3D (Rodin/Meshy) → decimate/remesh → retopo to quad cage |
| Hero / deforming characters | **sculpt + manual retopo** | deformation needs deliberate edge flow | high-poly sculpt → retopo → bake normals to game mesh |

Always: AI/sculpt output is a **base mesh**, never the shipped mesh. Game meshes
are retopologized to the topology budget below before they pass the gate.

## Topology standards (the mesh-topology-budget bar)

- **Quad-dominant.** Triangles only where unavoidable; **n-gons forbidden** on
  deforming or subdivided meshes. Poles (5+ edges) kept off deformation lines.
- **Deformation loops.** Even quad bands across every deforming joint (knee, elbow,
  shoulder, wrist, ankle, neck, finger base) — this is the contract The
  Choreographer's rig depends on (`game-rigging-and-animation-pipeline`).
- **Watertight where skinned.** No zero-thickness / non-manifold geometry on
  characters (it breaks Blender's automatic-weight bone-heat solver — see rigging skill).
- **Texel density consistent** across an asset set (e.g. 10.24 px/cm at current-gen);
  UV islands packed, no overlap unless intentional (mirrored), seams hidden.
- **Pivot / scale / axis.** Pivot at the gameplay-meaningful origin (feet for
  characters, base for props); **transforms applied to identity** (scale = 1,
  rotation = 0); **1 unit = 1 m**; authored **+Z up, -Y forward** then exported with
  the engine axis preset (see export table).

## Per-tier poly / LOD budget (cross-ref game-perf-budget)

| Platform tier | Hero char tris | Standard prop tris | LOD tiers | Texture set |
|---|---|---|---|---|
| Current-gen (PS5/XSX/PC-high) | 60k–120k | 1k–15k | 4 | 2–4× 2K (albedo/ORM/normal) |
| Last-gen / Switch-class | 25k–50k | 0.5k–6k | 3–4 | 1–2× 1K–2K |
| Mobile / web | 8k–20k | 0.2k–2k | 3 | 1× 512–1K, KTX2/Draco |

LOD chain: roughly halve tris per tier (LOD0→LOD1→LOD2→LOD3), set screen-coverage
transition distances, generate via Decimate / engine-side (Nanite relaxes this on
UE5 but still wants overdraw + material-complexity discipline — see The Artisan's
per-engine notes).

## Export convention by engine (axis / scale / format)

| Target | Format | Up / Forward | Scale | Notes |
|---|---|---|---|---|
| Unity | FBX (or glTF) | apply transform; engine reads Y-up | 1 u = 1 m | "Apply Transform", smoothing groups, no animated scale |
| Unreal Engine 5 | FBX | Z-up, X-forward | 1 u = 1 cm (project) | single root, transforms applied, leaf-bone off for skinned |
| Godot | glTF 2.0 (preferred) | Y-up | 1 u = 1 m | glTF carries PBR cleanly; FBX import is lossy |
| Web (Babylon/Three/PlayCanvas) | glTF 2.0 + Draco/KTX2 | Y-up | 1 u = 1 m | aggressive compression, atlasing |
| USD / Omniverse | USD | Y-up (USD default) | meters | `UsdSkel` for skinned; normalized weights |

Pre-export validation (the blender-mcp `validate_for_engine` style pass): unapplied
transforms, tri/bone limits, unsupported (Cycles-only) material nodes, n-gons on
export, non-manifold on skinned meshes.

## Templates

### Template: `ASSET_JOB` — 3D mesh commission (to garland)
```yaml
type: ASSET_JOB
target_squad: garland
model_type: mesh                 # mesh (prop/env) | rig (skinned character)
brief: "Modular ruin wall kit — 'The Hollow King', see art_bible.md + this DCC contract"
style_ref: art_bible.md          # The Artisan owns style; links only
dcc_contract:
  approach: geometry_nodes       # bmesh | geometry_nodes | ai_base_then_retopo | sculpt_retopo
  topology: { quad_dominant: true, ngons: forbidden, deformation_loops: n/a }
  budget: { tris_lod0: 6000, lods: 4, tris_ladder: [6000,3000,1500,750] }
  uv: { sets: 1, texel_density: "10.24 px/cm", lightmap_uv: true, overlap: none }
  pbr: { albedo: true, orm: true, normal: true, emissive: true }
  transform: { up: "+Z", forward: "-Y", unit: "1m", apply_transforms: true, pivot: base }
  export: { format: gltf2, engine: godot, validate_for_engine: true }
platform_tier: current_gen
provenance_required: true        # garland governance-c2pa signs; non-negotiable for gen-AI
acceptance: mesh-topology-budget
```

### Template: `mesh-topology-budget` gate (acceptance)
```yaml
asset: "ruin_wall_kit_A"
checks:
  poly_budget:      "tris_lod0 <= contract; LOD ladder present & monotonic"
  topology:         "quad-dominant; no n-gons; poles off deform lines"
  deformation_loops:"(rig only) even quad bands at every deforming joint"
  uv:               "packed, no unintended overlap, texel density within +/-10%"
  pbr_set:          "matches contract channels (albedo/ORM/normal/emissive)"
  transform:        "scale=1, rot=0 applied; 1u=1m; pivot at contract origin"
  export:           "correct axis preset; imports clean in target engine; no Cycles-only nodes"
  provenance:       "C2PA signature/sidecar present + valid"   # cross-ref ai-content-provenance
verdict: pass | revise(send back to garland with notes) | reject
```

### Template: text-to-3D base-mesh job (organic)
```yaml
type: ASSET_JOB
target_squad: garland
model_type: rig                  # character → blender-rig handles model+rig
brief: "Hollow King boss — base mesh from concept, then retopo to deformable cage"
pipeline: [ "image_to_3d (Rodin/Meshy) -> base mesh", "decimate/remesh", "retopo to quad cage", "bake normals", "UV + PBR", "deformation loops at joints" ]
budget: { tris_lod0: 90000, lods: 4 }
handoff: "deformation-ready mesh -> The Choreographer rig spec (game-rigging-and-animation-pipeline)"
provenance_required: true
acceptance: [ mesh-topology-budget, rig-quality ]
```

## Constraints

- The crown directs geometry; it never models or drives Blender. Every 3D asset →
  `ASSET_JOB` (`model_type: mesh|rig`) to `garland`; execution is blender-model /
  blender-rig on the existing **blender-mcp** backend.
- Every 3D `ASSET_JOB` carries `provenance_required: true`; garland C2PA-signs
  (sidecar for binary meshes) and the asset passes `ai-content-provenance` (HITL)
  before ship. **No new venom/gate** — `game.unsigned_genai_asset` already covers it.
- Every returned mesh is checked against `mesh-topology-budget` (no n-gons on
  deformers, LOD ladder present, UVs packed, transforms identity, export validates).
- Skinned characters additionally carry deformation-ready topology and pass
  `rig-quality` (hand to The Choreographer — `game-rigging-and-animation-pipeline`).
- Budgets split per platform tier (cross-ref `game-perf-budget`); the headline poly
  ceiling and style remain The Artisan's (`game-art-and-audio-direction`).
- AI/sculpt output is always a *base mesh*, retopologized to budget before it ships.
- Reference boards are *links*, never embedded generated images or meshes.
