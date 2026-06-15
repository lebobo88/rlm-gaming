---
name: game-economy-and-monetization
description: Economy-designer skill for producing economy simulations and monetization specs — currencies, source/sink/leak tables, gacha/loot math with pity timers and published odds, Monte-Carlo balancing, progression curves, retention/LTV/ARPDAU KPIs, store A/B plans, and a per-region jurisdiction table. Read this before designing any monetized or live-service economy. Invoked by The Economist and The Arbiter; feeds the loot-box-jurisdiction gate. Complements the engineering-side game-design economy-spreadsheet template in pair-programmer by adding Monte-Carlo balancing, the full jurisdiction matrix, and KPI dashboards.
---

# Game economy- and monetization-design skill

You are producing an **economy/monetization** artifact — an economy spreadsheet,
a gacha-math sheet, or a retention-KPI dashboard. The engineering-side
`game-design` economy template in pair-programmer covers the basic tabs; this
skill adds the Monte-Carlo balance pass, the full per-region jurisdiction matrix,
and the live-service KPI dashboard. The deliverable is a balanced, simulated,
legally-mapped economy spec — never code, never the live store.

This skill feeds the `loot-box-jurisdiction` gate (HITL, owned jointly by The
Economist and The Arbiter). Any randomized monetization that cannot fill the
jurisdiction table does not pass.

## The cardinal rule

> If a paid mechanic has random outcomes, the **odds are published**, there is a
> **pity floor**, and the **jurisdiction table is filled for every shipping
> region** — or it does not ship. Belgium and the Netherlands restrict/ban
> loot boxes; you disable or restructure for them, you do not "risk it".

## Anti-patterns to refuse

- **Undisclosed odds** — any randomized paid mechanic without published drop
  rates. Violates Apple/Google policy, Chinese/Korean/Japanese law, and ESRB
  notice. Non-negotiable.
- **No pity floor** — a gacha with no guaranteed-by-N counter reads as predatory
  and erodes player trust. A hard pity is a strong design + consumer-protection
  default (and some markets, e.g. China, regulate probability/disclosure) — but
  treat "no pity" as a design/trust red flag, not a blanket legal failure. Cite
  the specific market rule when you claim a legal requirement.
- **Ignoring BE/NL** — shipping paid randomized rewards to Belgium (enforcement-
  restricted; publishers commonly disable) or the Netherlands (contested/fact-
  specific after the 2022 Council of State reversal) without a region-aware plan.
  Decide per-region with counsel; an account-region gate is the usual mechanism.
- **Kompu-gacha** — "complete-the-set to win a rare" mechanics are illegal in
  Japan. Refuse the pattern entirely, not just for JP.
- **Pay-to-win with no skill ceiling** — purchasable power with no skill
  expression. Beyond the ethics, it kills retention and triggers AU/ratings
  scrutiny. Monetize cosmetics, time, and breadth — not the win condition.
- **Number-soup economy** — currencies with no source/sink/leak accounting; the
  faucet/drain MUST balance or the economy inflates/starves.
- **KPIs with no balance simulation** — projecting LTV/ARPDAU off a spreadsheet
  point estimate instead of a Monte-Carlo distribution.

## Templates

### economy_spreadsheet template (tabs)

```
# Economy spreadsheet — <Title>

## Currencies (tab)
| Currency | Premium? | Source(s) | Sink(s) | Leak(s) | Daily faucet | Daily drain | Net | Per-region note |
| Gold     | no       | quests, drops | gear, repair | decay | 5,000 | 4,600 | +400 | — |
| Gems     | yes      | IAP, events   | gacha, skips | — | — | — | — | see jurisdiction tab |

## Drop tables (tab)
| Source | Item | Rarity | Weight | Drop % (PUBLISHED) | Pity timer | Floor rate |
| Banner A | 5★ char | SSR | 0.6  | 0.60% | hard pity @ 90 | guaranteed by 90 |
| Banner A | 4★      | SR  | 5.1  | 5.10% | soft pity @ 75 | — |

## Per-region jurisdiction (tab)
| Region | Loot box | Odds published | Age gate | Special rule | Action |
| Belgium (BE) | BANNED | n/a | n/a | gambling-law ruling | DISABLE paid random; sell direct |
| Netherlands (NL) | RESTRICTED | yes | yes | tradeable-reward scrutiny | non-tradeable + odds, or disable |
| China (CN) | allowed | MANDATORY publish | yes | publish exact rates; anti-addiction time limits | publish + minor caps |
| South Korea (KR) | allowed | MANDATORY publish (2024 law) | yes | GMC oversight | publish exact rates |
| Japan (JP) | allowed | publish (industry) | — | NO kompu-gacha (illegal) | publish; ban complete-gacha |
| Apple (iOS, global) | allowed | REQUIRED (App Store 3.1.1) | yes | must disclose odds | publish in-app |
| Google (Play, global) | allowed | REQUIRED (Play policy) | yes | must disclose odds | publish in-app |
| Australia (AU) | allowed | — | M-rating | sim-gambling content → M+ | rating note → Arbiter |
| EU general | watch | yes | 18+ likely | DFA / consumer-law pressure | publish + age-gate, monitor |
| US (ESRB) | allowed | ESRB "in-game purchases (random)" label | yes | label required | apply label |

## Progression curves (tab)
| Level | XP req | Cumulative | Power | Time-to-level (median sessions) | Paywall pressure |

## Balance matrix (tab) — Monte-Carlo outputs
| Cohort | Sim runs | Median sessions-to-paywall | P5 | P95 | Inflation @ day 30 |
| F2P    | 100,000  | 18 | 9  | 41 | +2.1% |
```

### gacha-math sheet template

```
# Gacha-math sheet — <Banner>

## Published rates (must match in-game disclosure exactly)
| Tier | Rate | Pity |
| SSR  | 0.60% | hard pity @ 90, soft pity ramp from 75 |
| SR   | 5.10% | guaranteed ≥1 per 10-pull |

## Pity model
<Soft pity: SSR rate ramps +6%/pull from pull 75. Hard pity: SSR @ 90.
50/50 rate-up rule stated. Carry-over across banners: yes/no.>

## Monte-Carlo expected cost
| Outcome | Median pulls | P95 pulls | Median $ | P95 $ | Region caps |
| 1× SSR  | 62           | 90        | $X       | $Y    | CN minor cap applies |

## Floor guarantee
<The worst-case spend a player can hit — this is the consumer-protection number.>

## Kompu-gacha check
<CONFIRM: no complete-the-set-to-unlock mechanic exists (illegal in JP).>
```

### retention-KPI dashboard template

```
# Retention-KPI dashboard — <Title>

| KPI | Definition | Target | Alert floor | Source |
| D1 retention | % returning day 1 | ≥40% | <30% | telemetry |
| D7 / D30     | % returning       | ≥20% / ≥10% | <12% / <5% | telemetry |
| ARPDAU       | revenue / DAU     | $0.15 | <$0.08 | store |
| LTV (180d)   | Monte-Carlo dist. | $4.20 median | P5 < $1.50 | sim |
| Conversion   | % payers          | ≥3% | <1.5% | store |
| Whale concentration | % rev from top 1% | <50% | >70% (risk) | store |

## Store A/B plan
| Test | Variant A | Variant B | Metric | Min sample | Stop rule |
| price point | $4.99 | $5.99 | rev/install | 10k/arm | 95% sig or 14d |
<A/B changes to live economy are HITL (RLM-GAMING §8) → The Custodian.>
```

## Constraints

- Randomized paid mechanics MUST publish odds, include a hard pity floor, and
  fill the jurisdiction table for EVERY shipping region — or they do not ship
  (`loot-box-jurisdiction`, HITL).
- BE = disable paid random; NL = restructure or disable; JP = no kompu-gacha
  (refuse the pattern globally); CN/KR/JP/Apple/Google = publish exact odds;
  AU = rating note to The Arbiter.
- No pay-to-win without a preserved skill ceiling; monetize cosmetics, time, and
  breadth — never the win condition.
- Every currency MUST balance source/sink/leak; project LTV/ARPDAU from a
  Monte-Carlo distribution (≥100k runs), never a point estimate.
- Every economy artifact carries a per-region note (this skill's core duty), an
  accessibility note (spending-control / parental-control surfaces; cross-ref
  `game-accessibility-guidelines`), and — for online economies — a
  server-authority note (server owns wallets, drops, and transactions; cross-ref
  `server-authority-fairplay`).
- Live economy changes are HITL via The Custodian; store A/B follows a stated
  stop rule.
- Cite reference titles for monetization model precedent (e.g. Genshin Impact
  pity model, Marvel Snap pity, Path of Exile cosmetic-only F2P).
- Produces only design/spec markdown and DECISION_RECORDs. Store integration,
  payment code, and telemetry pipelines are a `DEV_TASK` to engineering; store
  art is an `ASSET_JOB` to garland. Never build the store here. See
  `game-studio-pipeline`.
