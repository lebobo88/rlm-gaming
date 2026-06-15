# RLM-Gaming — The Arcade Crown

> A senior multi-agent **game studio** that plugs into the Hydra Enterprise Agent
> Mesh as a squad pack. RLM-Gaming is the *studio brain*: it owns vision,
> design, production, live-ops, QA/balance, and compliance, and it **delegates**
> the work it does not own — engineering to the pair-programmer harness, and
> art/audio/video asset generation to RLM-Creative (the Garland crown).

---

## 1. What this is (and is not)

RLM-Gaming is a **Hydra squad pack** (`squads/rlm-gaming/`) backed by this
source repo. It follows the same wiring as the sibling persona packs:

| Pack | Crown | Source repo | Hydra entrypoint | What it owns |
|---|---|---|---|---|
| `customer-support` | Xenia hearth | Xenia | `claude-skill` | support |
| `garland` | Garland muses | RLM-Creative | `claude-skill` | creative assets |
| `executive` | C-suite | ExecutiveSuite | `agent-impersonation` | strategy |
| `engineering` | — | pair-programmer | `mcp` | code |
| **`rlm-gaming`** | **Arcade** | **RLM-Gaming** | **`claude-skill`** | **game studio** |

**It is NOT** a re-implementation of the game engineering agents that already
live in pair-programmer (`game-feature-team`, `game-netcode-team`,
`game-cert-team`, `level-designer`, `netcode-programmer`, `game-security`, …)
nor of the asset-generation muses in RLM-Creative (Helios, Erato, …). RLM-Gaming
sits **above** both and orchestrates them.

The Arcade crown is the senior-leadership layer of a game studio. When a head
needs code written, it emits a `PRD` / `DEV_TASK` to the **engineering** squad.
When it needs a binary asset (concept art, 3D mesh, VO, music, trailer), it
emits a `CREATIVE_BRIEF` / `SHOT_LIST` / `ASSET_JOB` to the **garland** squad.
RLM-Gaming itself produces only **design, plans, specs, and gates** — never
engine code and never image/audio binaries.

---

## 2. The Arcade pantheon (roster)

Nineteen heads across the five studio layers from the Blueprint. Crown lead is
**The Director**. The security gate is **The Sentinel** (the Cerberus-equivalent
for this crown). Additional gates: **The Warden** (QA/balance), **The Arbiter**
(ratings/cert), **The Producer** (milestone/HITL), **The Custodian** (live-ops).

### Executive layer
| Plaza (slug) | Mythic | Authority | Tier | Charter |
|---|---|---|---|---|
| `game-director` | **The Director** | gatekeeper (crown lead) | opus | Vision, pillars, greenlight, scope/quality/schedule arbitration. Owns the master `DECISION_RECORD`. |
| `producer` | **The Producer** | gatekeeper | sonnet | Backlog, milestones, sprints, cross-squad coordination, HITL control points. |
| `tech-director` | **The Forgemaster** | gatekeeper | opus | Engine architecture, tech standards, build-vs-buy, perf budgets. Delegates implementation to engineering. |

### Design layer
| Plaza (slug) | Mythic | Authority | Tier | Charter |
|---|---|---|---|---|
| `systems-designer` | **The Systemsmith** | execute | sonnet | Mechanics, systems, combat math, emergence, exploit-resistance. |
| `narrative-director` | **The Loremaster** | advisory | opus | World bibles, branching narrative, quest graphs, dialogue, themes. |
| `level-design-director` | **The Cartographer** | execute | sonnet | Worlds, levels, mission flow, pacing, PCG, navigation, streaming. |
| `encounter-designer` | **The Duelist** | execute | sonnet | Encounters, bosses, enemy archetypes, AI tuning targets. |
| `economy-designer` | **The Economist** | execute | sonnet | Economy, monetization, gacha math, balance simulation, retention. |

### Technical layer (thin — delegates to engineering)
| Plaza (slug) | Mythic | Authority | Tier | Charter |
|---|---|---|---|---|
| `game-ai-director` | **The Puppeteer** | advisory | sonnet | Runtime NPC AI design (BT/GOAP/HTN/Utility/EQS/perception). Delegates code to `game-ai-programmer`. |
| `netcode-lead` | **The Netweaver** | advisory | sonnet | Replication topology, server-authority, rollback/lockstep, host migration. Delegates to `game-netcode-team`. |
| `tools-pipeline` | **The Toolwright** | execute | sonnet | Editor tooling, import/build pipelines, asset processors, CI hooks. |

### Creative layer (thin — delegates to Garland)
| Plaza (slug) | Mythic | Authority | Tier | Charter |
|---|---|---|---|---|
| `art-director` | **The Artisan** | advisory | opus | Style bible, art direction, LOD/poly budgets. Emits `CREATIVE_BRIEF`/`ASSET_JOB` to Garland/Helios. |
| `audio-director` | **The Conductor** | advisory | sonnet | Adaptive audio, mix tiers, middleware (Wwise/FMOD). Emits `ASSET_JOB` to Garland audio sub-crew. |
| `animation-director` | **The Choreographer** | advisory | sonnet | Rigs, IK, blend trees, anim state machines, root-motion decisions. |

### Evaluation layer
| Plaza (slug) | Mythic | Authority | Tier | Charter |
|---|---|---|---|---|
| `qa-balance-lead` | **The Warden** | gatekeeper | sonnet | Test strategy, bot playthroughs, balance Monte Carlo, telemetry-driven tuning. QA gate. |
| `playtest-sim` | **The Playtester** | execute | sonnet | Synthetic players / persona simulation, fun-proxy metrics, friction reports. |
| `liveops-director` | **The Custodian** | gatekeeper | sonnet | Seasons, events, store A/B, hotfix flow, retention loops. |
| `compliance-cert` | **The Arbiter** | gatekeeper | opus | ESRB/PEGI/IARC/CERO ratings, platform cert (TRC/XR/Lotcheck/Steamworks), loot-box jurisdiction, CVAA. |
| `game-security-gate` | **The Sentinel** | gatekeeper (Cerberus-equiv) | opus | Server authority, anti-cheat, exploit threat models, fair-play. |

---

## 3. Delegation model — who does the actual work

```
                         ┌─────────────────────────┐
   goal ──/hydra:run──▶  │  RLM-Gaming (Arcade)     │
                         │  vision · design · plans │
                         │  QA/balance · cert gates │
                         └───────┬──────────┬───────┘
              PRD / DEV_TASK     │          │   CREATIVE_BRIEF / SHOT_LIST / ASSET_JOB
                                 ▼          ▼
                    ┌────────────────┐   ┌────────────────────┐
                    │  engineering   │   │  garland           │
                    │ (pair-prog.)   │   │ (RLM-Creative)     │
                    │ game-feature-  │   │ Helios visual crew │
                    │ team, netcode, │   │ Erato copy, audio  │
                    │ cert, security │   │ sub-crew, C2PA     │
                    └────────────────┘   └────────────────────┘
```

- **Code** → emit `PRD` (feature framing) and/or `DEV_TASK` to the
  `engineering` squad. Engineering runs the pair-programmer lifecycle and picks
  the right team: `game-feature-team`, `game-netcode-team`, `game-bug-fix-team`,
  `game-refactor-team`, `game-cert-team`, `game-accessibility-team`,
  `game-live-ops-team`. RLM-Gaming heads supply the design artifacts those teams
  consume (GDD, mechanic spec, encounter doc, level greybox, economy sheet).
- **Assets** → emit `CREATIVE_BRIEF` (direction), `SHOT_LIST` (cinematics /
  trailers), `ASSET_JOB` (concept art, 3D, VO, music, SFX) to the `garland`
  squad. Garland's Helios crew + C2PA governance produce signed binaries.
- **Strategy / greenlight escalation** → accept `C_SUITE_DECISION_PACKET` from
  the `executive` squad; emit `HITL_REQUEST` for greenlight, content-lock, and
  ship gates.

RLM-Gaming **never** produces engine source or media binaries directly. If a
head finds itself about to write a shader or a .png, it has crossed a boundary
and must instead emit the appropriate envelope.

---

## 4. Envelope contract

```
accepts: C_SUITE_DECISION_PACKET, PRD, CREATIVE_BRIEF, DEV_TASK, HANDOFF, HITL_REQUEST
emits:   PRD, DEV_TASK,            → engineering
         CREATIVE_BRIEF, SHOT_LIST, ASSET_JOB → garland
         DECISION_RECORD, HITL_REQUEST, HANDOFF
```

All types are schema-backed in `hydra_core/schemas.py`. The crown deliberately
reuses existing envelope types so the planner/synthesizer need no schema
changes. Game-specific design artifacts (GDD, mechanic_spec, level_greybox,
encounter_design_doc, economy_spreadsheet, narrative_bible, liveops_season_plan)
are **persisted via the squad shim and referenced by `context_refs:
list[MemoryRef]`** on the envelope — NOT stuffed into a `payload`/`attachments`
field (the `PRD`/`DevTask`/`Handoff` schemas have no such field). A `PRD` carries
`source_goal_id`, `summary`, `acceptance_criteria`, `user_stories`,
`dependencies`, `non_functional_requirements`; the design docs ride as
`MemoryRef` handles in `context_refs`, so engineering retrieves the full artifact
from memory rather than inline.

**HITL reason mapping.** `HITLRequest.reason` is a fixed enum; game control
points map onto it: greenlight / content-lock / cert-submission →
`acceptance_criteria`; ship / monetization-change / online-risk → `high_risk`;
season / live-ops sign-off → `campaign_signoff`; budget → `budget_approval`. The
human-readable game gate name goes in the request's `summary`/`detail`.

---

## 5. Gates (where the crown can block)

| Gate rubric | Owner head | HITL | When |
|---|---|---|---|
| `game-design-pillars-testable` | The Director | no | every greenlight |
| `loot-box-jurisdiction` | The Economist / The Arbiter | yes | `live_service` or any randomized monetization |
| `esrb-pegi-iarc-rating` | The Arbiter | yes | before store submission |
| `platform-cert-readiness` | The Arbiter | yes | `phase == 'cert'` |
| `server-authority-fairplay` | The Sentinel | yes | `online == true` |
| `ai-content-provenance` | The Artisan / The Sentinel | yes | any gen-AI asset shipped |
| `game-perf-budget` (pp rubric) | The Forgemaster | no | perf-tagged stages |
| `game-accessibility-guidelines` (pp rubric) | The Warden | no | every feature |

`game-perf-budget@1` and `game-accessibility-guidelines@1` are reused from the
pair-programmer rubric library; the rest are defined under
`squads/rlm-gaming/rubrics/`.

---

## 6. Cross-ecosystem wiring

- **Hydra** — discovered as `squads/rlm-gaming/squad.yaml`; router keywords in
  `hydra_core/router.py:_KEYWORDS['rlm-gaming']`; dispatched via `/hydra:run`,
  `/hydra:campaign`.
- **pair-programmer** — engineering delegation target. The PP game family
  (profiles `game-dev-*`, teams `game-*-team`, agents `game-ai-programmer`,
  `netcode-programmer`, `game-security`, …) is the implementation arm.
- **RLM-Creative / Garland** — asset delegation target via `CREATIVE_BRIEF` /
  `ASSET_JOB`. Helios crew renders; `governance-c2pa` signs.
- **TheEights** — memory fabric (`eights.memory`) for prior-project wisdom;
  Kan-cell audit sink for Sentinel venom events; evolution proposals for
  rubrics/agents.
- **AgentSmith** — constitution + invariants; `smith:scaffold` to add heads;
  Inspector validates new agent/skill artifacts before promotion.
- **Senate (curia)** — legal/compliance escalation (IP, licensed engines,
  age-rating law) when The Arbiter needs jurist review.
- **Xenia** — player-support feedback loop; VoC reports inform The Custodian's
  live-ops priorities.
- **Executive** — greenlight portfolio decisions arrive as
  `C_SUITE_DECISION_PACKET`.

---

## 7. Repo layout

```
RLM-Gaming/
  RLM-GAMING.md                  ← this file (architecture source of truth)
  README.md
  .claude/
    agents/      the-*.md        ← 19 Arcade heads
    skills/      */SKILL.md      ← 14 studio skills
    commands/    *.md            ← studio slash commands
  (registered into Hydra at squads/rlm-gaming/)
    squad.yaml                   ← Hydra squad descriptor
    heads.yaml                   ← Arcade crown alias overlay
    cerberus.yaml                ← The Sentinel venom gate
    rubrics/*.yaml               ← squad-level gate rubrics
```

---

## 8. Phased roadmap (from the Blueprint)

1. **Assisted** — single heads invoked for one artifact (GDD, mechanic spec).
2. **Discipline crews** — Design crew, Eval crew run as mini-pipelines.
3. **Vertical slice** — The Director + The Producer orchestrate all five layers
   for one level with full art/audio/gameplay (the `/game-vertical-slice` flow).
4. **Content factory / live-ops** — The Custodian drives semi-autonomous season
   and event generation within templates and approval gates, fed by telemetry.

Human authority is retained at: greenlight, core-art-style lock, content lock,
ship, any monetization change, and any venom-class action.
