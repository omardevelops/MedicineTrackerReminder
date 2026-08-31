# HalalFinds

Photograph a product's ingredients panel; get **halal**, **haram**, or
**mashbooh** (doubtful) — with the reason for each ingredient, and the exact
question to ask the manufacturer when the label leaves it open.

```
$ halalfinds check "Sugar, Glucose Syrup, Gelatine, Citric Acid, E120" --country GB

== MASHBOOH (doubtful) ==
Contains ingredients whose source cannot be confirmed from the label.

Country: GB   Profile: mainstream

[??] Gelatine
      Collagen hydrolysate from animal skin and bone. Porcine is the most
      common commercial source worldwide; bovine gelatine is halal only from
      ritually slaughtered cattle.

[??] Cochineal / Carmine / Carminic acid  (label: "E120")
      A red pigment extracted from the cochineal insect. Schools differ on
      consuming insects: the Maliki position permits, while Hanafi and Shafi'i
      scholars generally prohibit non-locust insects. Certifiers are divided.

(3 further ingredients found halal.)

Ask the manufacturer:
  - What species is the gelatine from, and was bovine material halal-slaughtered?
  - Can the colour be substituted with a plant-based red (e.g. anthocyanin, beetroot)?
```

## The design decision

The ruling never comes from a language model's recall.

Additive sourcing is exactly the kind of detail a model reproduces
plausibly and wrongly. So the model does what it is reliably good at — reading
a photographed label, including damaged and multilingual text — and a
deterministic lookup over a curated database does the ruling. That split is
what makes the result both fast (microseconds, no network) and auditable: every
verdict names the entry it came from.

## Install

```bash
pip install -e ".[dev]"
```

No runtime dependencies. Python 3.10+.

## Use

```bash
halalfinds check "Water, Sugar, Emulsifier (E471), Natural Flavouring" -c US
halalfinds check "$(cat label.txt)" -c MY --json
halalfinds check "Sugar, E471" -c GB --signal vegan     # a pack claim resolves the doubt
halalfinds lookup "L-cysteine"
halalfinds countries
```

Exit codes let you script it: `0` halal, `2` mashbooh, `3` haram.

As a library:

```python
from halalfinds import classify

verdict = classify("Sugar, gelatine, E120", country="MY")
verdict.ruling          # <Ruling.MASHBOOH>
verdict.questions       # what to ask the manufacturer
verdict.to_dict()       # full JSON-safe result
```

With Claude Code, the `halal-check` skill in `.claude/skills/` handles the
photo path end to end: send a picture of a label and it transcribes, classifies
and reports.

## How a verdict is reached

**1. Tokenize.** The panel is split into ingredients, unwrapping class-name
brackets so `emulsifier (E471, soya lecithin)` becomes two ingredients. A
source qualifier printed in brackets stays attached to what it qualifies.

**2. Match**, cheapest and most certain first: exact alias → E/INS code →
whole-phrase containment → fuzzy similarity for OCR damage. Below the
similarity floor the matcher declines to guess.

**3. Rule.** Each entry carries a ruling per profile, so the same label gives
the answer appropriate to the standard the user follows.

**4. Resolve.** A source qualifier on the pack (`fish gelatine`, `of vegetable
origin`) or a label signal (`vegan`, a certification mark) can settle a doubt.
A signal never overturns a prohibition.

**5. Aggregate**, worst case: one haram ingredient makes the product haram; one
unresolved doubt makes it mashbooh.

## What it refuses to rule on

A photo of a pack often shows several blocks, and only one supports a verdict.
An allergen advisory — "may contain traces of nuts", or a restaurant's menu
disclaimer — states what the food might be *contaminated* with, not what it is
made of. Ruling on one produces a confident verdict about nothing.

So `classify()` raises `NotAnIngredientsList` on advisory-only text, and the
CLI exits `4`:

```
$ halalfinds check "All dishes may contain traces of: Gluten, Crustaceans, Eggs..."
No verdict: This is an allergen advisory, not an ingredients declaration...
```

Real labels carry both. The advisory tail is split off, reported alongside the
verdict, and never ruled on — whether trace contact matters is a separate
question from the ingredients ruling.

## The safety property

**An ingredient not in the database is mashbooh, never halal.**

The two errors are not equal. Reporting a haram product as halal causes someone
to consume what their faith prohibits; reporting a halal product as doubtful
causes an email to a manufacturer. The system is biased accordingly, and
`tests/test_classify.py` enforces it.

## Disagreement is represented, not resolved

Carmine, transformed gelatine, wine vinegar, trace alcohol carriers and
non-fish seafood divide qualified scholars. Rather than pick one position and
present it as *the* ruling, entries carry a ruling per profile — `strict`,
`mainstream`, `lenient`, or a named certifier such as `JAKIM` or `HFA` — and
every verdict states which profile produced it.

Country matters for a separate reason: labelling law decides how much the pack
must disclose. `Sugar` is halal in the UK and doubtful in the US, because US
cane sugar may be bone-char refined and the label will not say. See
`.claude/skills/halal-check/references/countries.md`.

## Data

- `data/ingredients.json` — 96 entries covering 227 E-numbers and 641 label
  aliases, each with a ruling, a reason, the ambiguity axis, and per-source
  resolutions
- `data/countries.json` — 15 jurisdictions, 9 ruling profiles, 5 label signals

`tests/test_data_integrity.py` guards the invariants: unique ids, valid rulings,
known ambiguity axes, no alias or code claimed by two entries, a reason on every
entry.

## Tests

```bash
python3 -m pytest
```

## Scope

This is ingredient-label analysis, not certification. A valid mark from a
recognised body outranks it, because a certifier audits processing aids and
cross-contamination that never reach a label. For a personal ruling on a
disputed matter, ask your own scholar or certifier.

## Licence

MIT.
