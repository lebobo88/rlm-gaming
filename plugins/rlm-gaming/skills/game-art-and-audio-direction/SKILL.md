---
name: game-art-and-audio-direction
description: Art and audio DIRECTION for the Arcade crown (The Artisan + The Conductor). Produces the style bible, reference boards, LOD/poly/texture/material budgets, and the audio mix-tier sheet, sonic palette, and Wwise/FMOD event map — then COMMISSIONS the actual binaries from garland via CREATIVE_BRIEF/ASSET_JOB/SHOT_LIST with provenance_required:true. The crown never generates images, audio, or 3D inline. Ties to the ai-content-provenance rubric (garland C2PA-signs every gen-AI asset).
---

# Game art & audio direction skill

You are producing an **art/audio direction** artifact — the style bible, budgets,
and event maps that *commission and constrain* asset production. You do **not**
generate a single pixel, sample, mesh, or VO line. The cardinal handoff: the crown
writes direction, then emits a `CREATIVE_BRIEF` (direction) / `ASSET_JOB` (concrete
asset) / `SHOT_LIST` (cinematics) to the `garland` squad, whose Helios visual crew
and audio sub-crew render the binary and whose `governance-c2pa` signs it.

Lead heads: **The Artisan** (`art-director`, advisory) and **The Conductor**
(`audio-director`, advisory). Hard gate: any gen-AI asset shipped passes the
`ai-content-provenance` rubric (HITL), owned by The Artisan + The Sentinel. Budgets
cross-ref `game-perf-budget`. See sibling skill `game-qa-and-balance` for
style-similarity acceptance enforcement at QA.

## The cardinal handoff

> The crown COMMISSIONS; garland PRODUCES; garland SIGNS.
> Direction (markdown + reference *links*) → `CREATIVE_BRIEF`. A specific asset →
> `ASSET_JOB` with `provenance_required: true`. A cinematic/trailer → `SHOT_LIST`.
> If you are about to run ComfyUI, a diffusion model, a TTS voice, or export a
> `.png`/`.wav`/`.fbx`, you have crossed the boundary — emit the envelope instead.

## Anti-patterns to refuse

- **Generating images/audio inline.** Driving diffusion/TTS/music models or
  exporting binaries from the Arcade crown. REFUSE — emit an `ASSET_JOB` to garland.
- **Asset drift from the bible.** Accepting returned assets that violate the style
  bible's palette/silhouette/material/lighting rules. Every asset is checked against
  the `style-similarity gate` before it enters the project.
- **Unsigned gen-AI assets.** Any AI-generated binary without C2PA provenance.
  `provenance_required: true` is non-negotiable on every `ASSET_JOB`; unsigned
  assets fail `ai-content-provenance` and are quarantined.
- **Sounds with no place in the mix.** A new SFX/music cue not assigned to a bus,
  a mix tier, and a ducking/priority rule. If it has no home in the mix sheet, it
  will mud the mix — refuse it until placed.
- **No LOD/poly budget per platform tier.** A single "looks good" target with no
  poly/texture/draw budget split by platform tier (mobile / Switch / current-gen /
  PC-high). Refuse art direction that doesn't budget per tier — it can't pass cert
  perf and can't be optimized to a target.

## Per-engine asset budget context

- **Unreal Engine 5** — Nanite (virtualized geometry — relaxes poly budget but
  needs overdraw/material-complexity discipline), Lumen (GI/reflections cost),
  Virtual Textures; material instances over unique materials; budget by draw calls,
  VRAM, and shader complexity per tier.
- **Unity** — URP (mobile/mid) vs HDRP (high-fidelity); LOD groups, texture
  streaming, SRP Batcher / GPU instancing; budget by tris, set-pass calls, texture
  memory per tier.
- **Godot** — manual LODs / mesh LOD, texture compression per platform, fewer
  unique materials; budget conservatively for the Compatibility renderer on web/mobile.
- **Web (Babylon/Three/PlayCanvas)** — aggressive poly/texture limits, draco/
  ktx2 compression, atlasing; budget for the lowest target device.
- **Audio middleware** — Wwise or FMOD events, RTPCs, states/switches, bus
  hierarchy, voice limiting; budget by simultaneous voices and memory per platform.

## Templates

### Template: `art_bible`
```yaml
title: "The Hollow King — Art Bible"
pillars: ["decayed grandeur", "bioluminescent threat-reads", "readable silhouettes"]
palette: { primary: "#1a2b3c", accent: "#7fffd4 (threat glow)", value_range: "low-key" }
silhouette_rules: "enemies readable at 5% screen height; player always brightest"
material_language: "wet stone, tarnished gold, fungal emissive"
lighting: "low-key with single motivated key + emissive fills"
reference_boards: ["./refs/board_environments.md", "./refs/board_characters.md"]  # LINKS only
do_not: ["saturated primaries", "flat ambient", "noisy normals on hero assets"]
```

### Template: style-similarity gate (acceptance)
```yaml
asset: "boss_hollow_king_concept"
checks:
  palette_conformance: ">= 0.85 cosine to bible palette"
  silhouette_readability: "passes 5% screen-height squint test"
  material_language: "matches bible material list"
  provenance: "C2PA signature present + valid"   # cross-ref ai-content-provenance
verdict: pass | revise(send back to garland with notes) | reject
```

### Template: `ASSET_JOB` brief (to garland)
```yaml
type: ASSET_JOB
target_squad: garland
model_type: diffusion            # diffusion | nerf | video_llm | tts | music
brief: "Boss concept — 'The Hollow King', 3/4 view, see art_bible.md style refs"
style_ref: art_bible.md
platform_tier: current_gen
budget: { tris: 80000, texture: "2x2K (albedo/ORM)", lods: 4 }
provenance_required: true        # garland governance-c2pa signs; non-negotiable
acceptance: style-similarity gate
```

### Template: audio mix-tier sheet
| Bus | Tier (priority) | Targets | Ducking |
|---|---|---|---|
| Master | — | -14 LUFS integrated | — |
| Music | 3 | -18 LUFS | duck -6dB under VO |
| VO | 1 (highest) | -12 LUFS, always intelligible | ducks Music+SFX |
| SFX_Combat | 2 | transient-rich, -10 peak | voice-limit 24 |
| SFX_Ambient | 4 | bed, -24 LUFS | duck under combat |
| UI | 2 | crisp, non-fatiguing | — |

### Template: Wwise/FMOD event map
```yaml
middleware: wwise
events:
  Play_Boss_Music: { bus: Music, states: [Phase1,Phase2,Enrage], rtpc: HealthPct }
  Play_Sword_Hit:  { bus: SFX_Combat, switch: SurfaceType, voice_limit: 8 }
  Play_VO_Taunt:   { bus: VO, ducks: [Music, SFX_Ambient], priority: 1 }
sonic_palette: "metallic-organic; low fungal drones, glassy magic transients"
voice_budget: { max_voices: 64, per_emitter_limit: 4 }
```

### Template: `SHOT_LIST` (cinematics)
```yaml
type: SHOT_LIST
target_squad: garland
sequence: "Reveal trailer — The Hollow King"
shots:
  - { id: 1, desc: "slow push through ruined throne hall", len_s: 4, style_ref: art_bible.md }
  - { id: 2, desc: "king turns, eyes ignite", len_s: 2, audio: Play_Boss_Music }
provenance_required: true
```

## Constraints

- The crown directs; it never produces binaries. Every asset → `CREATIVE_BRIEF` /
  `ASSET_JOB` / `SHOT_LIST` to `garland`.
- Every `ASSET_JOB` carries `provenance_required: true`; garland C2PA-signs and the
  asset passes `ai-content-provenance` (HITL) before ship.
- Every returned asset is checked against the `style-similarity gate` (no drift).
- Every art spec carries LOD/poly/texture/material budgets split per platform tier
  (cross-ref `game-perf-budget`).
- Every sound has a bus, a mix tier, and a ducking/priority rule before it enters
  the mix; respect the voice budget.
- Reference boards are *links*, never embedded generated images.
- Core art-style lock and content lock are human-authority HITL gates — surface
  them, don't self-approve.
