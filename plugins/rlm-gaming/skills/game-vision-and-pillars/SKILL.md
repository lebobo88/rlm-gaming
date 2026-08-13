---
name: game-vision-and-pillars
description: Director-altitude skill for producing a game's vision artifacts — the one-pager, the testable pillar set, and the greenlight memo — at studio-leadership altitude. Read this before any greenlight, scope arbitration, or vision-lock. Owns the hook, the singular audience, the comp set, the USP, 3-5 falsifiable pillars, named anti-pillars, kill-criteria, and the target launch quarter. Invoked by The Director; feeds the game-design-pillars-testable gate. Complements (does not duplicate) the engineering-side game-design skill in pair-programmer, which authors the GDD body.
---

# Game vision & pillars skill

You are producing a **game-vision** artifact — the document a studio greenlights
against and arbitrates scope/quality/schedule against for the life of the
project. This is The Director's altitude: not the GDD body (that is the
engineering-side `game-design` skill in pair-programmer), but the spine the GDD
hangs from. The job is to produce a vision that is **falsifiable**: every claim
can be tested, every pillar can be proven wrong by a playtest, and the whole
thing can be killed by a named criterion.

This skill feeds the `game-design-pillars-testable` gate. If a pillar cannot be
written as a claim a Warden playtest could falsify, it does not pass.

## The cardinal rule

> A pillar is a **falsifiable claim about the player's experience**, not a vibe.
> "Combat is fast and satisfying" is a vibe. "A skilled player kills a basic
> enemy in under 2 seconds; 80% of playtesters describe the kill as 'crunchy'
> unprompted in exit interviews" is a pillar. If the QA/balance team (The Warden)
> cannot design a test that could prove the pillar FALSE, rewrite it.

## Anti-patterns to refuse

When the input leans on these, push back before writing a line:

- **Three-bullet vibe pillars** — "Engaging combat / Deep story / Open world".
  No decision content, nothing falsifiable. Cross-ref the same refusal in the
  engineering-side `game-design` skill; this skill adds the test column.
- **Generic verbs** — "explore", "engage", "experience", "discover", "immerse".
  These are not in the player's control scheme. Replace with the player's actual
  input and its measurable result.
- **"Hero saves the world" with no hook** — no named protagonist, no reason this
  world is worth saving, no antagonist logic, no twist on the comp set.
- **"Casual to hardcore" audience** — targeting both targets neither. Name ONE
  player, ideally by what they bounced off ("Hades players who want a co-op
  roguelike", not "action fans").
- **Unmeasurable adjectives** — "realistic", "satisfying", "deep", "fun",
  "immersive", "AAA-quality". Replace each with a reference title + a number.
- **Pillars that are features** — "has a crafting system" is a feature, not a
  pillar. A pillar is why the feature exists and how you'd know it's working.
- **No anti-pillars** — a vision without named anti-pillars cannot arbitrate
  scope creep. If everything is in scope, nothing is.
- **No kill-criteria** — a greenlight memo with no condition under which the
  project dies is a wish, not a decision.

## Templates

### One-pager template

```
# <Title> — Vision One-Pager

## Hook (≤60 words)
<The single most interesting thing. If a publisher reads only this, they
should want the meeting. No "in a world where".>

## Singular audience
<ONE player. "Soulslike players who bounced off Elden Ring's open-world
sprawl and want a 12-hour tight metroidvania." NOT "RPG fans.">

## Comp set (3-4 titles, with deltas)
| Comp | What we SHARE | What we DIFFER (the delta) |
| <Title, year, est. units/scores> | <shared loop/feel> | <our wedge> |

## USP (one sentence)
<What we do that no comp does. Falsifiable: a player could verify it.>

## Pillars (3-5; see pillar-test matrix)
1. <Falsifiable claim>
2. <Falsifiable claim>
3. <Falsifiable claim>

## Anti-pillars (2-4)
- NOT <thing we will refuse even when tempted>
- NOT <thing the comp set does that we reject>

## Tone (3 adjectives + 1 rejected)
<"Crunchy, melancholy, defiant — NOT 'whimsical'."> Cite 2 tone reference
titles (a game + a film/show/album is ideal).

## Platforms + perf tiers
| Platform | Perf tier | Target fps / res | Notes |
| <PS5> | <tier-1> | <60fps / 1440p> | |
| <Switch 2 / Steam Deck / mobile-mid> | <tier-3> | <30fps / 720p> | |

## Monetization model
<Premium | F2P | live-service | premium+DLC | subscription.> If monetized,
per-region note required (cross-ref loot-box-jurisdiction) + pointer to the
economy_spreadsheet (game-economy-and-monetization skill).

## Online / server-authority note
<If online: true — one line on what is server-authoritative.
Cross-ref server-authority-fairplay.>

## Accessibility note
<One line per the floor we commit to. Cross-ref game-accessibility-guidelines.>

## Target launch quarter
<Q-Y. Drives The Producer's milestone plan.>
```

### Pillar-test matrix template

Every pillar gets a row. The `Falsifying test` column is what makes this skill
distinct from the GDD pillars list — it is the contract with The Warden.

```
| # | Pillar (falsifiable claim) | Metric | Target | Falsifying test (Warden owns) | Owning head |
| 1 | A skilled player parries the 3rd boss with no hits taken | hitless-clear rate among top-decile testers | ≥25% | If <10% after 20 tuning passes, pillar is false | Systemsmith |
| 2 | First-time players reach the first save in <8 min without a tutorial popup | median time-to-first-save, popup count | <8 min, 0 popups | If median >12 min or popups required, pillar is false | Cartographer |
| 3 | Players describe the world as "lonely" unprompted | unprompted exit-interview tag rate | ≥40% | If <20%, tone pillar is false | Loremaster |
```

### Greenlight memo template

```
# Greenlight Memo — <Title>

## Decision requested
GREENLIGHT to <phase: prototype | vertical-slice | full-production>.

## Vision (1 paragraph)
<Hook + audience + USP compressed.>

## Why now / why us
<Market window, studio capability fit, the unfair advantage.>

## Pillars & their tests
<Pointer to pillar-test matrix. List the 3-5 one-liners.>

## Scope envelope
| In scope (serves a pillar) | Out of scope (an anti-pillar guards it) |

## Budget & schedule frame
<Headcount, $ range, target launch quarter, biggest schedule risk.>

## Monetization & compliance posture
<Model + the 2-3 jurisdictions that most constrain it. Cross-ref
loot-box-jurisdiction + esrb-pegi-iarc-rating.>

## KILL-CRITERIA (mandatory)
The project DIES if, by <milestone>:
- <Pillar N> fails its falsifying test after N tuning passes, OR
- <fun-proxy metric> stays below <threshold> across 3 playtest cohorts, OR
- <cost/CAC/retention threshold> is breached.
<No memo passes the gate without at least 2 measurable kill-criteria.>

## Recommendation
<GREENLIGHT / GREENLIGHT-CONDITIONAL / NO-GO> + the one thing that would
flip the recommendation.

## Authority
Greenlight is a HITL control point — human sign-off required (RLM-GAMING §8).
This memo travels as the payload of a DECISION_RECORD.
```

## Constraints

- Every pillar MUST be falsifiable — write the Warden test or it is not a pillar.
- Every vision artifact MUST name ≥2 anti-pillars and ≥2 measurable
  kill-criteria; a memo without them does not pass `game-design-pillars-testable`.
- Pick ONE audience. "Casual to hardcore" is an automatic rejection.
- Every artifact carries an accessibility note (cross-ref
  `game-accessibility-guidelines`); monetized artifacts carry a per-region note
  (cross-ref `loot-box-jurisdiction`); online artifacts carry a server-authority
  note (cross-ref `server-authority-fairplay`).
- Cite reference titles (with year/scores where possible) for tone, feel, and
  every comp-set delta — never an unmeasurable adjective.
- This skill produces only design/spec markdown and DECISION_RECORDs. It NEVER
  produces code (→ engineering) or media binaries (→ garland). See
  `game-studio-pipeline` for the routing contract.
- Greenlight is human-gated. Emit a HITL_REQUEST; do not self-approve.
