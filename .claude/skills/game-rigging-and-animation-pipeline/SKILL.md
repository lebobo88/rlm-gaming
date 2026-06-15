---
name: game-rigging-and-animation-pipeline
description: Production rigging, skinning, and animation pipeline standards for the Arcade crown (The Choreographer). Captures Blender/DCC industry standards — armature architecture (single root, .L/.R, roll), FK/IK + pole + FK/IK switching, LBS vs DQS skinning, automatic/heat/voxel weights with normalization (<=4 influences, sum=1), corrective shape keys, mocap retargeting, NLA action libraries, gimbal-lock QC, and cross-engine export (Unreal / Unity Humanoid / USD). The crown specs the rig/anim contract; it never rigs, skins, or produces binaries — rig/anim implementation -> engineering (pp tech-animator) via DEV_TASK, bespoke motion/mocap + Blender rig execution -> garland (blender-rig) via ASSET_JOB. Ties to the rig-quality gate; deformation-ready topology comes from The Sculptor (game-3d-modeling-and-dcc).
---

# Game rigging & animation pipeline skill

You are producing a **rig / animation contract** — the armature architecture,
skinning rules, animation-system spec, and QC metrics that *commission and
constrain* rigging and animation. You do **not** build an armature, paint a weight,
key a frame, or export a `.fbx`. Two handoffs: rig/anim *engine implementation*
(AnimGraph / AnimatorController / AnimationTree, IK solvers, retarget setup) →
`engineering` (pp **tech-animator**) via `DEV_TASK`; **Blender rig execution** and
bespoke motion/mocap → `garland` (**blender-rig**) via `ASSET_JOB`. The
deformation-ready mesh comes in from **The Sculptor**
(`game-3d-modeling-and-dcc`).

Lead head: **The Choreographer** (`animation-director`, advisory). Hard bar:
returned rigs/animations pass the `rig-quality` rubric. Budgets cross-ref
`game-perf-budget`. This skill is the *design* contract; the deterministic `bpy`
execution lives in garland's blender-rig on the existing **blender-mcp** backend.

## Meta-principle (deterministic, measurable rigging)

> Reason in **armature edit-space, pose-space, and world-space matrices**; vertex
> groups as **weight vectors**; and engine export constraints (FBX / glTF / USD).
> Never accept "looks right" — specify explicit metrics: weight-sum error per
> vertex, max influences per vertex, max Euler deviation between frames, joint
> volume preservation, bone-hierarchy invariants. Prefer the Data API (`bpy.data`,
> `edit_bones`, `pose.bones[*].matrix`) over GUI-macro operators for determinism.

## Armature architecture standards

- **Single root** at world origin (`root` / `armature_root`), all deform bones a
  tree beneath it. **No multiple roots, no cycles, no duplicate bone names**
  (engine avatars reject these).
- **Symmetric naming** `upper_arm.L` / `upper_arm.R`, `.L`/`.R` suffixes so
  Blender symmetry + auto-riggers (Rigify / Auto-Rig Pro) mirror config & weights.
- **Consistent roll** (X across the limb, Y along the bone, Z up) — misaligned roll
  scatters a bend across channels and breaks IK pole behavior. Recalculate roll to
  a global/limb-plane reference.
- **Deform vs control separation** — deform bones (skinning) on their own layer;
  control bones (IK handles, poles, UI) separate. Authored T-pose or A-pose,
  facing a consistent axis; **transforms applied** (identity scale/rot) before bind.
- **Twist bones** on long segments (upper arm, forearm, thigh) to fight
  candy-wrapper twist under large rotation.

## FK / IK, constraints, drivers

- IK limbs with **pole targets** (knee/elbow) at a fixed offset along the limb-plane
  normal scaled by character height; `chain_count` = limb depth; `use_stretch=false`
  for non-stretch limbs; **Limit Rotation** constraints at biomechanical ranges.
- **FK/IK switch** via a custom float property (`fk_ik_leg.L` ∈ [0,1]) driving
  Copy-Rotation constraint influence on deform bones (FK influence = 1−v, IK = v).
- Prefer **quaternion** rotation mode on bones at gimbal-lock risk; detect risk by
  monitoring Euler-channel finite differences (jump > ~120°/frame) and re-key.

## Skinning: LBS vs DQS + weight QC

| Aspect | Linear Blend (LBS) | Dual Quaternion (DQS) |
|---|---|---|
| Deformation | volume loss + candy-wrapper at joints | preserves volume, no twist artifacts |
| Cost | cheap matrix blend | slight dual-quat normalization overhead |
| Compatibility | ubiquitous (legacy engines) | modern engines/middleware |
| Fix | twist bones + corrective shape keys | fewer correctives needed |

- **Automatic weights** = Blender bone-heat: great on closed/manifold meshes,
  **fails on thin/non-manifold** ("failed to find solution for one or more bones").
  Require watertight geometry (from The Sculptor) + reasonable scale.
- **Voxel Heat Diffuse** for overlapping geometry (clothing/accessories) — never
  throws the bone-heat error but fuses regions; post-smooth / separate. Common
  pattern: automatic weights for simple areas + voxel for complex overlaps.
- **Weight QC metrics (the rig-quality bar):** per-vertex `Σw = 1` (|1−Σw| < 1e-5);
  **max influences ≤ 4** (mobile/engine limit); most vertices 1–3 influences; prune
  weights < `min_weight` then renormalize; no bone with negligible total weight.
- **Corrective shape keys / PSD** driven by joint angle (e.g. elbow bend → 0..1
  influence) where local volume drops below ~70% of rest or self-intersection
  appears.

## Animation architecture

- **F-Curves** per channel (Bezier/Linear/Constant). Simplify dense mocap/baked
  curves with a Douglas-Peucker-style pass: keep deviation < ε (pos < 0.5 cm,
  angular < 1°). Euler-filter to remove discontinuities.
- **NLA as a layer stack** with explicit semantics: base locomotion layer, additive
  pose layers (aim / damage), higher-priority overrides; blend modes Replace / Add /
  Combine; strips repeated for loops. Maps cleanly to a game animation library
  (idles / walks / attacks / emotes).
- **Retargeting:** normalize source+target to a reference T/A-pose, align root
  orientation + uniform scale, build a bone-name mapping, copy F-curve samples with
  per-bone rest-pose offset correction, keep a manual-correction NLA track on top.
- **Root motion vs in-place** decided per system (The Choreographer's existing
  contract) — note net/AI prediction implications; extract pelvis/root trajectory
  for engine root-motion tracks.

## Cross-engine export rules (the rig-quality export checks)

- **Unreal Engine 5 (FBX):** single root at origin; **no animated/non-uniform bone
  scale**; consistent units; Z-up/X-forward (Blender -Y-forward → axis convert);
  match UE Mannequin names or set up an engine retarget map.
- **Unity Humanoid (FBX/glTF):** humanoid hierarchy (hips/spine/chest/neck/head/
  arms/legs/hands/feet/toes); T/A-pose arms-out; single root; **unique** bone names;
  animate position/rotation only (no scale).
- **USD / Omniverse:** `UsdSkel`; single skeleton root; normalized weights; respect
  engine influence limits.
- Export config: apply transforms, disable leaf bones, bake animation at a
  consistent sample rate, prefer baked animation over drivers in glTF.

## Failure modes → detection → remediation

| Failure | Detection | Fix |
|---|---|---|
| Gimbal lock | Euler finite-diff jump > ~120°/frame | convert bone to quaternion, re-key via matrix decomposition, re-simplify |
| Volume loss at joints | local volume ratio < threshold vs rest | twist bones + corrective shape keys (or DQS) |
| Non-uniform scaling | bone/object \|scale−1\| > 1e-3 | unparent, apply transforms, rebind, rebake anims |
| Improper weights | Σw ≠ 1, influences > 4, distant-bone weights | re-weight region / data-transfer from proxy, prune + normalize |
| Hierarchy issues | multiple roots / cycles / dup names | enforce single root + unique names, rebuild engine avatar |

## Templates

### Template: `DEV_TASK` — rig/anim engine implementation (to engineering)
```yaml
type: DEV_TASK
target_squad: engineering
team_hint: tech-animator        # or game-art-pipeline-team
brief: "Player character rig + locomotion AnimGraph for UE5"
payload:
  rig_contract: { skeleton: humanoid, root: single_origin, naming: ".L/.R + UE-mannequin map", twist_bones: true }
  ik: { foot_ik: true, hand_ik: weapon_poses, lookat: aim_offset, fk_ik_switch: true }
  skinning: { method: LBS+twist, max_influences: 4, normalized: true }
  anim_system: { engine: unreal, graph: "state machine + 2D blendspace + additive aim", root_motion: traversal_only }
  export: { format: fbx, up: Z, forward: X, unit: cm, single_root: true, no_scale_anim: true }
acceptance: rig-quality
```

### Template: `ASSET_JOB` — Blender rig execution / mocap (to garland)
```yaml
type: ASSET_JOB
target_squad: garland
model_type: rig                 # blender-rig: armature + skin + export
brief: "Auto-rig + skin the Hollow King deformable mesh; retarget mocap walk/idle set"
input_mesh: "from The Sculptor (deformation-ready, watertight)"
rig_spec: { rigger: "auto (Rigify/ARP smart) + custom IK", skinning: "auto-weights + voxel on cloth", qc: rig-quality }
mocap: { source: "library_walk_idle_set", retarget: "name-map + rest-pose align", nla: "loopable strips" }
export: { format: fbx, engine: unreal }
provenance_required: true       # gen-AI motion/asset -> C2PA sidecar
acceptance: rig-quality
```

### Template: `rig-quality` gate (acceptance)
```yaml
asset: "hollow_king_rig"
checks:
  hierarchy:    "single root; no cycles; unique bone names; deform/control separated"
  naming_roll:  ".L/.R symmetric; consistent roll (X-across/Y-along/Z-up)"
  weights:      "per-vertex Σw=1 (±1e-5); max influences <= 4; no distant-bone weights"
  ik:           "pole targets valid; FK/IK switch drives influence 0..1; limits within biomech range"
  no_gimbal:    "no Euler jump > 120 deg/frame across keyed channels"
  transform:    "scale=1 applied; no animated/non-uniform bone scale"
  export:       "single root at origin; engine axis/unit correct; imports clean (UE/Unity/USD)"
  provenance:   "(gen-AI) C2PA signature/sidecar present"  # cross-ref ai-content-provenance
verdict: pass | revise | reject
```

## Constraints

- The crown specs the rig/anim *contract*; it never builds armatures, paints
  weights, keys frames, or exports binaries. Engine implementation → `engineering`
  (pp tech-animator) `DEV_TASK`; Blender rig execution + bespoke motion/mocap →
  `garland` (blender-rig) `ASSET_JOB`.
- The deformation-ready, watertight mesh is an input from **The Sculptor**
  (`game-3d-modeling-and-dcc`); reject rig jobs whose mesh lacks joint edge loops
  or is non-manifold.
- Every rig/animation passes `rig-quality` (single root, normalized weights ≤4
  influences, no gimbal, clean export). Cross-ref `game-perf-budget` for anim
  costs (eval + IK + blend eat CPU frame budget; LOD animation, disable on dedicated
  server when not needed for hit-detection).
- Specify explicit metrics, not impressions. Prefer Data-API determinism over
  GUI-macro operators.
- Gen-AI motion/mocap carries `provenance_required: true`; signed by garland's
  `governance-c2pa` (sidecar), covered by `ai-content-provenance` + the existing
  `game.unsigned_genai_asset` venom — **no new gate**.
