"""Reading source qualifiers printed alongside an ingredient.

Labels often answer the source question themselves: "emulsifier (mono- and
diglycerides of vegetable origin)", "fish gelatine", "microbial rennet". Where
an entry declares how it resolves per source, a qualifier in the label text
settles the ruling instead of leaving it doubtful.
"""

from __future__ import annotations

import re

from .models import Entry, Ruling
from .normalize import normalize

# Ordered: the first pattern to match a token wins, so the more specific and
# more severe qualifiers are tested before the general ones.
QUALIFIER_PATTERNS: list[tuple[str, str]] = [
    ("porcine", r"\b(porcine|pork|pig|swine|hog)\b"),
    ("human_hair", r"\b(human hair|hair keratin)\b"),
    ("duck_feather", r"\b(feather|duck)\b"),
    ("fish", r"\b(fish|marine|piscine)\b"),
    ("bovine_halal", r"\b(halal (beef|bovine)|bovine \(halal\)|halal-slaughtered)\b"),
    ("bovine_uncertified", r"\b(bovine|beef|cow|calf)\b"),
    ("microbial", r"\b(microbial|fermentation[- ]produced|bacterial|fungal)\b"),
    ("synthetic", r"\b(synthetic|synthetically produced|petrochemical)\b"),
    ("lanolin", r"\b(lanolin|wool grease)\b"),
    ("lichen", r"\b(lichen)\b"),
    ("hpmc", r"\b(hpmc|hypromellose|pullulan|vegetarian capsule|veg(gie)? capsule)\b"),
    ("soy", r"\b(soy|soya|soybean)\b"),
    ("sunflower", r"\b(sunflower)\b"),
    ("egg", r"\b(egg)\b"),
    ("plant", r"\b(vegetable|vegetal|plant|plant[- ]based|veg(etable)? origin|"
              r"palm|coconut|rapeseed|of vegetable origin)\b"),
]

_COMPILED = [(key, re.compile(pattern)) for key, pattern in QUALIFIER_PATTERNS]


def find_qualifier(token: str, entry: Entry) -> tuple[str, Ruling] | None:
    """Return (qualifier_key, ruling) if the token names a source the entry knows.

    Returns None when the label says nothing the entry can act on, leaving the
    entry's profile ruling in force.
    """
    if not entry.resolves:
        return None

    key = normalize(token)
    for qualifier, pattern in _COMPILED:
        if qualifier not in entry.resolves:
            continue
        if pattern.search(key):
            return qualifier, Ruling(entry.resolves[qualifier])
    return None
