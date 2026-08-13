---
description: "The Sculptor-led 3D asset flow — DCC contract → commission garland blender-model/blender-rig (existing blender-mcp) → mesh-topology-budget + rig-quality gates → C2PA provenance → DECISION_RECORD."
argument-hint: "<asset> [--type mesh|rig] [--engine unity|unreal|godot|web|usd] [--tier mobile|lastgen|currentgen]"
model: sonnet
---

# /game-asset-3d

**The Sculptor** takes one 3D asset from brief to accepted, signed binary. It
writes the DCC contract (topology / UV / PBR / LOD / axis-scale / export), commissions
the **garland** squad's Helios 3D crew — `blender-model` for props/environment,
`blender-rig` for skinned characters — which execute on the **existing blender-mcp**
backend, then holds the `mesh-topology-budget` bar (and `rig-quality` with The
Choreographer) on what returns. The crown writes the contract; garland models, rigs,
and C2PA-signs. The crown never opens Blender.

## Steps

1. **Contract** — The Sculptor authors the DCC contract via `game-3d-modeling-and-dcc`:
   modeling approach (BMesh / Geometry Nodes / AI-base+retopo / sculpt+retopo),
   topology rules (quad-dominant, deformation loops, no n-gons on deformers), UV /
   texel density, PBR channel set, LOD ladder, pivot/scale/axis, and the export target
   (`--engine` → glTF 2.0 / FBX / USD). Budgets per `--tier` cross-ref `game-perf-budget`
   and The Artisan's poly ceiling.
2. **Style check** — The Artisan supplies/approves style refs (`style-similarity`);
   geometry execution stays with The Sculptor.
3. **Rig contract (if `--type rig`)** — The Choreographer adds the armature / skinning /
   animation contract via `game-rigging-and-animation-pipeline` (single root, `.L/.R`,
   ≤4 influences, FK/IK, retarget, NLA). The mesh must be deformation-ready + watertight.
4. **Commission garland** — emit an `ASSET_JOB` (`model_type: mesh|rig`,
   `dcc_contract: {...}`, `provenance_required: true`) to `garland`. `blender-model` /
   `blender-rig` execute via blender-mcp; `governance-c2pa` signs (C2PA sidecar for binary
   meshes).
5. **Acceptance** — read back via `rlm_output_read`; The Sculptor fires
   `mesh-topology-budget`; The Choreographer fires `rig-quality` (rigs); The Artisan +
   The Sentinel confirm `ai-content-provenance`. Reject + re-brief, or accept.
6. **Close** — write the asset `DECISION_RECORD` (links the garland return + gate
   verdicts); `eights.memory.add(domain="gaming")` with reusable topology/budget decisions.

## Example

```
/game-asset-3d "Hollow King boss" --type rig --engine unreal --tier currentgen
```
The Sculptor writes the DCC contract + commissions a text-to-3D base mesh → retopo →
deformation-ready cage; The Choreographer adds the rig contract; an `ASSET_JOB`
(`model_type: rig`) goes to garland's `blender-rig`; the returned, C2PA-signed FBX
passes `mesh-topology-budget` + `rig-quality`; a DECISION_RECORD closes it.

## Delegation

3D binaries → `garland` via `ASSET_JOB` (`blender-model` / `blender-rig` on the
existing blender-mcp). Engine import/validation/LOD tooling → `engineering` via
`DEV_TASK` (pp `technical-artist` / `tech-animator`, `game-art-pipeline-team`). The
Sculptor's DCC contract + The Choreographer's rig contract are the only artifacts
RLM-Gaming authors here. No new venom/gate — gen-AI 3D assets are covered by
`ai-content-provenance` + the `game.unsigned_genai_asset` venom.
