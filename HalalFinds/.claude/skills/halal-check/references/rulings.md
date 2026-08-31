# The classification model

## Three verdicts

**Halal** — permitted. Every ingredient is either inherently permissible or its
source is established by the label or a certification mark.

**Haram** — prohibited. At least one ingredient is definitively impermissible:
swine derivatives, flowing blood, intoxicants, or an ingredient whose label
explicitly names a prohibited source ("gelatine (porcine)").

**Mashbooh** — doubtful. The honest middle. The ingredient *may* be
impermissible and the label does not say. This is not a soft "probably fine";
it is a statement that the question is open and can be closed by asking the
manufacturer.

Aggregation is worst-case: one haram ingredient makes the product haram, and
one unresolved doubt makes it mashbooh. There is no averaging.

## The safety asymmetry

The two possible errors are not equal.

Reporting a haram product as halal causes someone to consume what their faith
prohibits. Reporting a halal product as doubtful causes inconvenience and an
email to a manufacturer. The system is therefore deliberately biased toward
mashbooh: **an ingredient not in the database is mashbooh, never halal.**

This is why the matcher declines to guess below its similarity floor. A
confident wrong match is worse than an admitted unknown.

## Ambiguity axes

Every doubtful entry records *why* it is doubtful. The axis determines what
evidence can resolve it.

| Axis | The question | Resolved by |
|---|---|---|
| `animal_source` | Is the feedstock plant, synthetic, or animal — and if animal, which species? | A source qualifier on the pack, a vegan/vegetarian claim, or halal certification |
| `slaughter` | The species is permissible, but was it ritually slaughtered? | Halal certification only |
| `alcohol` | Is ethanol present as an intoxicant, or as a residual carrier? | Manufacturer disclosure; profile decides the trace threshold |
| `insect` | Insect-derived, on which schools differ | The profile, or certification |
| `process` | The substance is fine; a processing aid or growth medium is the question | Manufacturer disclosure |
| `school` | No factual ambiguity at all — qualified scholars simply differ | The user's own school |

The `school` axis is important to keep separate. Non-fish seafood is not
doubtful because we lack information; it is doubtful because the Hanafi
position differs from the other three schools. No amount of manufacturer
disclosure resolves it. Only the user's own madhhab does.

## Ruling profiles

The same label yields different correct answers under different standards.
Rather than pick one and present it as *the* ruling, each entry can carry a
ruling per profile.

- **strict** — resolves disagreement toward caution throughout
- **mainstream** *(default)* — the position common to most major certifiers
- **lenient** — accepts istihalah broadly, permits trace alcohol carriers,
  follows the Maliki position on insects
- **certifier profiles** — `JAKIM`, `MUI`, `HFA`, `HMC`, `IFANCA`, `SFDA`

Resolution order for an entry: a certifier-specific stance, then a named
profile override, then the entry default.

## The disputed cases

These are the entries where the profile genuinely changes the verdict. They are
disputed among qualified scholars, and the system's job is to represent the
disagreement rather than resolve it.

### Carmine / cochineal (E120)

A red pigment from the cochineal insect.

- *Permitting*: the Maliki school broadly permits insects. Transformation
  arguments also apply — the pigment is an extract, not the insect body.
- *Prohibiting*: Hanafi and Shafi'i scholars generally hold non-locust insects
  impermissible. JAKIM and MUI both reject it.
- *Verdict*: `strict` haram, `mainstream` mashbooh, `lenient` halal.

### Gelatine and istihalah

Whether chemical transformation (istihalah) purifies a substance derived from a
prohibited source.

- *Permitting*: a body of contemporary scholarship, including some resolutions
  of the Islamic Fiqh Academy, holds that complete transformation into a new
  substance changes the ruling.
- *Prohibiting*: the majority certifier position is that gelatine retains the
  ruling of its source, and hydrolysis is not a true transformation.
- *Verdict*: unqualified gelatine is mashbooh; `porcine` on the label makes it
  haram under every profile in this system.

### Wine vinegar

- *Permitting*: vinegar is explicitly permitted in hadith, and acetic
  fermentation is the archetypal case of transformation. The majority permit it.
- *Prohibiting*: a minority distinguish vinegar that formed naturally from
  vinegar deliberately manufactured from wine. JAKIM rejects it.
- *Verdict*: `lenient` halal, `mainstream` mashbooh, `strict` haram.

### Trace alcohol as a flavour carrier

Ethanol as a beverage is prohibited by consensus. As a residual solvent in a
flavouring at a fraction of a percent, it is not. Where the line falls varies:
several standards permit carry-over below 0.1%, others require none.

### Non-fish seafood

The Maliki, Shafi'i and Hanbali schools permit all sea creatures. The Hanafi
school permits only fish; shrimp is disputed within it. This is the `school`
axis — a matter of madhhab, not of labelling.

### Bone-char refined sugar

Some cane refiners decolourise using charred cattle bone. No bone material
remains in the sugar.

- *Permitting*: it is a processing aid leaving no trace; the majority permit it.
- *Avoiding*: a strict minority avoid the contact entirely.
- *Verdict*: `mainstream` halal; `strict` mashbooh; raised to mashbooh in the
  US, where cane sugar is commonly bone-char refined and the label will not say.

## Label signals

Evidence on the pack that closes an axis:

- **halal_certified** — closes everything. The certifier audited the chain.
- **vegan** — closes `animal_source`, `insect` and `slaughter`. Not `alcohol`.
- **vegetarian** (including India's green dot) — closes `animal_source` and
  `slaughter`. Not `insect`: carmine is permitted in vegetarian products in
  some markets.
- **kosher** — closes most porcine doubt, since kosher supervision excludes
  swine. It is *not* equivalent to halal: kosher permits wine and alcohol, and
  not every halal authority accepts kosher slaughter.

A signal can clear a doubt. **A signal never overturns a prohibition** — a
vegan claim on a product declaring lard does not make the lard permissible; it
means the label contradicts itself and should not be trusted.

## Adding to the knowledge base

Each entry needs: a stable `id`, the `canonical` name, every `alias` that
appears on real labels (including other languages and OCR-plausible variants),
`codes` in canonical `E471` form, the `ambiguity` axis, `rulings` per profile,
a `reason` a user can act on, and an `ask` naming the exact question for the
manufacturer.

`tests/test_data_integrity.py` enforces the invariants: unique ids, valid
ruling values, known ambiguity axes, no alias or code claimed by two entries,
and a reason on every entry. Run the suite after any data change.
