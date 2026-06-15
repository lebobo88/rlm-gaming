---
name: game-netcode-and-multiplayer
description: Netcode and multiplayer DESIGN for the Arcade crown (The Netweaver). Selects the network model (rollback / lockstep / client-prediction+server-reconciliation / snapshot-interpolation), draws server-authority boundaries, plans lag compensation, interest management, and host migration, and specifies determinism for RTS lockstep. Produces a netcode_model spec — never engine code (that ships as a DEV_TASK to engineering game-netcode-team). Ties to the server-authority-fairplay rubric and The Sentinel venom gate. Read before any online: true feature.
---

# Game netcode & multiplayer skill

You are producing a **netcode model** spec — the document an engineer reads to wire
replication, authority, and lag handling. You choose the model and draw the trust
boundaries; you do **not** write replication code. Replication graph wiring, RPC
implementations, rollback buffers, and reconciliation loops ship as a `DEV_TASK` to
the `engineering` squad (team `game-netcode-team`, agent `netcode-programmer`,
taxonomy 4.6/4.7).

Lead head: **The Netweaver** (`netcode-lead`, advisory). Hard gate: every spec is
reviewed against the `server-authority-fairplay` rubric (HITL when `online == true`)
and any client-trust violation is a **venom-class** event for **The Sentinel**
(`game-security-gate`, the Cerberus-equivalent). See sibling skills
`game-ai-behavior` (server-auth for AI inputs) and `game-qa-and-balance` (netcode
soak/regression).

## The cardinal rule

> **The server owns truth. The client renders a prediction.**
> Position, health, damage, currency, inventory, hit registration, RNG outcomes,
> and progression are *server-authoritative*. The client may *predict* them for
> responsiveness but the server *decides* and corrects. A client that asserts any
> of these is a cheat vector, not a feature.

## Anti-patterns to refuse

- **Client-authoritative value state.** Client sends "my health is 100 / I have
  5000 gold / I dealt 999 damage" and the server believes it. REFUSE — this is the
  canonical cheat. Server computes; client requests intent only. Flag to The Sentinel.
- **Trusting client damage/position/currency.** Accepting raw transforms or damage
  numbers without server validation, speed clamps, and sanity checks. The client
  sends *inputs/intents* ("I pressed fire toward X"); the server resolves.
- **Lockstep with client-seeded RNG / non-determinism.** In Spring/Recoil-style
  lockstep, every client must compute the identical simulation from identical
  inputs. Per-client `rand()` seeds, floating-point divergence, iteration-order
  nondeterminism, or wall-clock reads desync the match. REFUSE.
- **No interest management at scale.** Replicating every actor to every client.
  A 100-player or large-world game without relevancy/interest management saturates
  bandwidth and leaks position (wallhack via packets). Mandatory above ~16 actors.
- **Snapshot interpolation with no lag compensation for hitscan.** Shooters that
  interpolate remote players but don't rewind on the server for hit validation feel
  broken ("I shot them dead-on"). Specify the rewind window.

## Model selection — when to use which

| Model | Use when | Cost | Engine fit |
|---|---|---|---|
| **Rollback** | Fast 1v1/small fighting/action; input-latency intolerant | Re-sim CPU; needs determinism | GGPO-style custom; some Unity (Fish-Net/Photon Quantum) |
| **Lockstep** | RTS, 1000s of units, low bandwidth (send inputs only) | Hard determinism; latency = slowest peer | Spring/Recoil (native), custom |
| **Client-pred + server-recon** | MMO/shooter/action; responsive + authoritative | Reconciliation/jitter handling | UE5 (CharacterMovement default), Unity NGO |
| **Snapshot interpolation** | Many remote entities you only observe (other players) | Visual latency ~100ms buffer | Source-style; web authoritative |

Most online action games = **client-prediction + server-reconciliation for the
local player + snapshot interpolation for remote players + server lag compensation
for hit validation.** State the combination explicitly.

## Per-engine mapping

- **Unreal Engine 5** — Actor `Replication` + RPCs (`Server`/`Client`/`Multicast`),
  `Replication Graph` for relevancy at scale, **Push Model** (`MARK_PROPERTY_DIRTY`)
  to cut replication cost, `Network Prediction` plugin for movement. Server is
  authoritative by default — keep it that way.
- **Unity** — `Netcode for GameObjects` (NGO) `NetworkVariable`/RPCs with
  ownership/authority flags; or `Mirror` / `Fish-Net` (Fish-Net has built-in
  prediction & lag comp). Never grant clients write authority over value state.
- **Godot** — high-level multiplayer (`MultiplayerSpawner`, `MultiplayerSynchronizer`,
  `@rpc` with `authority`/`call_local`); set synchronizer visibility for interest
  management; validate on the authority peer.
- **Web** — `WebRTC` data channels (P2P, low latency) or `WebSocket` (relayed);
  authority MUST be a trusted server process, never a peer. Browser clients are
  fully untrusted — assume tampering.
- **Spring/Recoil (RTS)** — lockstep: broadcast inputs per simframe, every client
  simulates deterministically. Fixed-point or determinism-audited float math,
  shared RNG stream, ordered iteration.

## Templates

### Template: replication topology
```yaml
model: client_pred_server_recon + snapshot_interp + lag_comp
engine: ue5
topology: dedicated_server          # dedicated | listen | p2p-relay
scale: { max_players: 64, relevancy: replication_graph }
tick: { server_hz: 30, client_send_hz: 60, snapshot_buffer_ms: 100 }
push_model: true
```

### Template: authority matrix (who owns what state)
| State | Authority | Client may | Validation |
|---|---|---|---|
| Local movement | Server (predicted by client) | predict + reconcile | speed/teleport clamp |
| Health | Server | display only | never trust client value |
| Damage dealt | Server (resolves) | send fire intent | rewind + LOS + range check |
| Currency/inventory | Server | request transaction | server ledger is truth |
| RNG drops/crits | Server | display result | server seed only |
| Cosmetic anim | Client | own | none (no gameplay effect) |

### Template: rollback budget sheet
```yaml
input_delay_frames: 2
max_rollback_frames: 7              # ~116ms @60fps
state_snapshot_bytes: <= 4096      # must be cheap to save/restore
resimulate_cost_ms: <= 4.0         # per rolled-back frame, cross-ref game-perf-budget
determinism: fixed_point_or_audited_float
desync_detection: per-frame state checksum compare
```

### Template: host-migration plan
```yaml
trigger: host_disconnect | host_quit
detection_timeout_ms: 5000
new_host_selection: lowest_ping_then_oldest_session
state_handoff: last_authoritative_snapshot from migration candidate
grace_period_ms: 8000              # freeze sim, show "reconnecting"
fallback: if migration fails → graceful match-end + partial credit
```

## Lag compensation & interest management (always specify)

- **Lag compensation**: server rewinds world to the shooter's render-time
  (~RTT/2 + interp buffer) to validate hits. State the max rewind window
  (typ. 200–250ms) and the anti-abuse cap.
- **Interest management / relevancy**: distance/cell/PVS culling so a client only
  receives actors it can perceive. Prevents bandwidth blowup *and* packet-sniff
  wallhacks. Required above ~16 replicated actors.

## Constraints

- The crown produces the netcode_model spec only. Replication code, RPCs, rollback
  buffers → `DEV_TASK` to `engineering` (`game-netcode-team` / `netcode-programmer`).
- Every value state in the authority matrix is server-owned; clients send intent.
- Every `online == true` spec passes `server-authority-fairplay` (HITL) before
  production; client-trust violations escalate to The Sentinel as venom-class.
- Lockstep specs include an explicit determinism contract (shared RNG, fixed/
  audited math, ordered iteration, checksum desync detection).
- Specs at scale (>16 actors) include interest management; shooters include lag
  compensation with a stated rewind window.
- Re-sim / replication cost carries a budget (cross-ref `game-perf-budget`).
