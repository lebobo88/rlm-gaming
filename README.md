# RLM-Gaming 🕹️

**The Arcade Crown** — a senior multi-agent game studio that runs as a
[Hydra](https://github.com/lebobo88/Hydra) squad pack. It owns the studio-brain
layers (vision, design, production, live-ops, QA/balance, compliance) and
delegates the rest: **code → pair-programmer**, **art/audio → RLM-Creative
(Garland)**.

See [`RLM-GAMING.md`](./RLM-GAMING.md) for the full architecture.

## Quick start

```bash
# from a Hydra session
/hydra:squads                      # confirm rlm-gaming is discovered
/hydra:run "Greenlight a 2D roguelite deckbuilder for Switch + Steam"
/hydra:run "Design a boss encounter for our Unreal soulslike, then build it"
/hydra:campaign "Ship Season 3 of our live-service shooter"
```

Or invoke the crown's skills directly in a Claude Code session:

```
/game-greenlight     vision → pillars → one-pager → GDD (The Director gate)
/game-vertical-slice  one level, all five layers, delegating code + assets
/game-feature        a single feature end-to-end
/game-liveops-season  a season plan (The Custodian)
/game-balance-pass   balance + synthetic playtest (The Warden + The Playtester)
/game-cert-review    ratings + platform cert gate (The Arbiter)
/game-roster         show the Arcade pantheon
```

## The roster

19 heads across 5 layers. Crown lead: **The Director**. Security gate: **The
Sentinel**. See [`RLM-GAMING.md` §2](./RLM-GAMING.md#2-the-arcade-pantheon-roster).

## What it delegates

| Need | Envelope emitted | Goes to |
|---|---|---|
| Engine code, tests, perf, netcode, cert build | `PRD` / `DEV_TASK` | `engineering` (pair-programmer) |
| Concept art, 3D, VO, music, SFX, trailers | `CREATIVE_BRIEF` / `SHOT_LIST` / `ASSET_JOB` | `garland` (RLM-Creative) |

RLM-Gaming produces **design, plans, specs, and gates** — never engine source,
never media binaries.

## Engine coverage

Unity · Unreal Engine 5 · Godot · Web (Babylon.js / Three.js / Phaser /
PlayCanvas) · Spring/Recoil RTS · custom engines. Live-service / F2P economy and
jurisdiction handling included.

## License / provenance

All generated game-design artifacts carry provenance metadata. Gen-AI binary
assets are produced and **C2PA-signed by Garland**, never by this pack.
