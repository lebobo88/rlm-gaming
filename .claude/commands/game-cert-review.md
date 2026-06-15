---
description: "The Arbiter-led ratings + platform cert gate — content inventory, IARC map, target-rating feasibility, per-platform TRC checklist, loot-box jurisdiction, then a submission HITL."
argument-hint: "<title/build> [--platforms PS5,XSX,Switch,PC,iOS,Android] [--target-rating E|E10|T|M] [--monetized]"
model: sonnet
---

# /game-cert-review

**The Arbiter** runs the ratings and platform-certification gate before any store submission. It inventories shippable content, maps it through IARC to the participating boards (ESRB / PEGI / USK / ClassInd / GRAC), checks feasibility of the target rating, builds a per-platform certification checklist, runs the loot-box jurisdiction check if monetized, and ends with a submission HITL. (Japan's **CERO** and Australia's **ACB** are separate, non-IARC submissions — tracked on their own.) IP, licensed-engine terms, and age-rating law that The Arbiter cannot resolve alone escalate to `legal-compliance` (Senate) via `HANDOFF`. Uses the `game-cert-and-compliance` skill.

## Steps

1. **Content inventory** — The Arbiter catalogs rateable content (violence, language, sexual content, gambling/simulated gambling, UGC, data collection).
2. **IARC map** — map the inventory through the IARC questionnaire to the participating boards (ESRB / PEGI / USK / ClassInd / GRAC). Note CERO (Japan) / ACB (Australia) as separate submissions. Fire `esrb-pegi-iarc-rating` (owner: The Arbiter, **HITL**).
3. **Target-rating feasibility** — compare the IARC result to `--target-rating`; flag any content that would breach it and route remediation back to the owning design head.
4. **Per-platform cert** — for each of `--platforms`, build the cert checklist using each platform's own program: **Sony TRC**, **Microsoft XR/XGSP**, **Nintendo Lotcheck**, **Steamworks** (+ Deck-Verified), **Apple/Google** review. (Note: "TRC" is Sony-specific — do not call Nintendo's process a TRC; Nintendo uses Lotcheck.) Delegate cert-code remediation to `engineering` (`game-cert-team`). Fire `platform-cert-readiness` (owner: The Arbiter, **HITL**; pipeline-internal cert stage).
5. **Loot-box jurisdiction** — if `--monetized` or any randomized reward, fire `loot-box-jurisdiction` with per-region disclosure/odds requirements (NL, BE, JP/CERO, etc.).
6. **Escalate** — emit `HANDOFF` to `legal-compliance` for IP clearance, licensed-engine terms, age-rating law, or UGC liability beyond The Arbiter's authority.
7. **HITL submission** — emit `HITL_REQUEST` for the human submission decision; on approval write the cert `DECISION_RECORD` and `eights.memory.add(domain="gaming")` (record platform gotchas for replay).

## Example

```
/game-cert-review "Hollow King v1.0" --platforms PS5,Switch,PC --target-rating T --monetized
```
The Arbiter inventories content, IARC returns PEGI 16 / ESRB T, Nintendo **Lotcheck** flags a missing caption option (remediation → `game-cert-team`), `loot-box-jurisdiction` requires odds disclosure, a licensing question escalates to legal via HANDOFF, and submission pauses on a HITL. (A Japan release would need a separate CERO submission.)

## Delegation

Cert-code remediation → `engineering` (`DEV_TASK`, `game-cert-team`). IP/law → `legal-compliance` (Senate) via `HANDOFF`. The Arbiter authors the content inventory, IARC map, TRC checklists, and `DECISION_RECORD`. Fires `esrb-pegi-iarc-rating` + `platform-cert-readiness` (and `loot-box-jurisdiction` when monetized).
