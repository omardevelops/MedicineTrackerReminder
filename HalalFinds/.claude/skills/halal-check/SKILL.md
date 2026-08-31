---
name: halal-check
description: Determine whether a food, drink, cosmetic or medicine product is halal, haram or mashbooh (doubtful) from a photograph of its ingredients panel, a typed ingredients list, or a single ingredient name. Use when the user sends a picture of a product label, asks "is this halal", asks about an E-number or additive (E471, gelatine, carmine, L-cysteine, mono- and diglycerides), or asks whether an ingredient is permissible in a given country. Also use for questions about halal certification marks and how additive labelling differs between jurisdictions.
---

# Halal ingredient check

Classify a product from its ingredients panel. The ruling comes from the
knowledge base in `data/`, never from your own recall of what an additive is
made of. Your job is to read the label accurately and to run the classifier;
the classifier decides.

## Why this split matters

Additive sourcing is the kind of detail a model recalls plausibly and wrongly.
E471 is a real example: it is doubtful because the fatty acids may be animal or
plant, but the specific reasoning, the certifier disagreements, and the
jurisdiction rules are curated facts with citations. Answering from memory
produces confident text that is sometimes wrong about whether a family is
eating pork. Route the ruling through the data.

## Workflow

### 1. Transcribe the label

Read the ingredients panel from the image **verbatim**. Preserve:

- the exact order of ingredients
- bracketed sub-lists: `emulsifier (E471, soya lecithin)`
- any source qualifier printed on the pack: `fish gelatine`, `mono- and
  diglycerides of vegetable origin`, `microbial rennet`. These are the highest
  value tokens on the label; they settle a doubt in one step.
- E-numbers exactly as printed, including letter suffixes (`E472e`)

Do **not** silently correct, translate, or normalise names. The classifier
absorbs OCR damage with fuzzy matching, and an unrecognised token is reported
as doubtful rather than dropped. A "helpful" correction can hide a real
ingredient.

If part of the panel is unreadable — glare, a fold, a cut-off edge — say so and
ask for another photo of that section. **Never** infer what an obscured
ingredient probably was.

### 2. Note what else is on the pack

Scan the whole image, not just the ingredients block:

| What you see | Pass as |
|---|---|
| A halal certification mark (JAKIM, MUIS, HFA, HMC, IFANCA, SANHA…) | `--signal halal_certified` |
| "Vegan" or "Plant-based" claim | `--signal vegan` |
| "Vegetarian", or India's green veg dot | `--signal vegetarian` |
| A kosher mark (OU, OK, Star-K) | `--signal kosher` |
| Country of origin, importer address, language | `--country` |

Ask the user which country they are shopping in if the pack does not say. It
changes the answer: US labelling law hides flavour sources that EU law does
not, and Malaysia's national standard rejects additives that other certifiers
allow.

### 3. Classify

```bash
python3 -m halalfinds.cli check "<transcribed ingredients>" \
  --country GB --signal vegan --json
```

Run `halalfinds countries` to see the supported countries, profiles and
signals. Use `halalfinds lookup <term>` for a single-ingredient question.

Set `--profile` only when the user has told you which standard they follow
(`strict`, `mainstream`, `lenient`, or a certifier such as `JAKIM`). Otherwise
let the country supply its own default.

### 4. Report

Lead with the verdict, then the reason. Structure:

1. **The verdict** — HALAL, HARAM, or MASHBOOH.
2. **What drove it** — name the specific ingredients, not a summary. For
   mashbooh, say *why* each is doubtful: which component is source-ambiguous.
3. **What would settle it** — the classifier returns a deduplicated
   `questions` list. These are the questions to put to the manufacturer.
4. **Certification note** — a valid mark from a recognised body outranks label
   analysis, because the certifier has audited the supply chain.

State the country and profile the verdict was computed under. The same label is
genuinely a different answer in Kuala Lumpur and Chicago, and hiding that makes
the result look more universal than it is.

## Rules

- **An unrecognised ingredient is doubtful, never halal.** The classifier
  enforces this. Do not talk the user out of it.
- **Never overturn the classifier's ruling from your own knowledge.** If you
  believe an entry is wrong, say so explicitly as a caveat and propose a data
  fix — do not quietly report a different verdict.
- **Do not soften a mashbooh into a halal** because the product is popular,
  because a similar product was fine, or because the doubtful item is a minor
  additive. Quantity is not the question.
- **Do not harden a mashbooh into a haram** either. Mashbooh means unresolved,
  and telling someone a permissible food is forbidden is its own harm.
- **Report genuine scholarly disagreement as disagreement.** Carmine, wine
  vinegar and non-fish seafood divide qualified scholars. Give the positions
  and the profile used; do not present one school's view as the ruling.
- **You are not a mufti.** This is ingredient analysis. For a personal ruling on
  a disputed matter, point the user to their own scholar or certifier.

## Reference

- `references/rulings.md` — the classification model, the ambiguity axes, and
  the disputed cases with the reasoning on each side
- `references/countries.md` — labelling law and certifier stances by country
- `data/ingredients.json` — the knowledge base
