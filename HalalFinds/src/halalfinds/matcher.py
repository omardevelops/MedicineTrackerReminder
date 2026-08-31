"""Matching a label token to a knowledge-base entry.

Four passes, cheapest and most certain first:

  1. exact    - the normalized token is a known name or alias
  2. code     - the token carries an E/INS additive number
  3. contains - a known alias appears as a whole phrase inside the token
                ("emulsifier: mono- and diglycerides of vegetable origin")
  4. fuzzy    - character-level similarity, to absorb OCR damage

Only the fuzzy pass can be wrong, so it carries a score and a floor below
which we prefer to report the ingredient as unidentified rather than guess.
"""

from __future__ import annotations

import re
from difflib import SequenceMatcher

from .data import Index
from .models import Entry, Ruling
from .normalize import canonical_code, normalize

# Below this similarity we decline to match. Chosen so that OCR damage of one
# or two characters in a word still lands, but unrelated ingredients do not.
FUZZY_FLOOR = 0.86


def _similar(a: str, b: str) -> float:
    return SequenceMatcher(None, a, b).ratio()


def _default_severity(entry: Entry) -> int:
    """Severity of an entry's baseline ruling, independent of any profile.

    Used only to rank competing containment matches within one token.
    """
    return Ruling(entry.rulings.get("default", "mashbooh")).severity


def match(token: str, index: Index) -> tuple[Entry | None, str, float]:
    """Return (entry, match_kind, score) for one label token."""
    key = normalize(token)
    if not key:
        return None, "none", 0.0

    entry = index.by_alias.get(key)
    if entry is not None:
        return entry, "exact", 1.0

    code = canonical_code(token)
    if code is not None:
        entry = index.by_code.get(code)
        if entry is not None:
            return entry, "code", 1.0
        # A letter-suffixed code falls back to its numeric family: E472e -> E472.
        base = re.match(r"^(E\d{3,4})", code)
        if base is not None:
            entry = index.by_code.get(base.group(1))
            if entry is not None:
                return entry, "code", 0.95
        return None, "none", 0.0

    # An embedded alias, matched on whole words. A token may contain several
    # ("pork gelatine" holds both "pork" and "gelatine"); the most severe wins,
    # so a qualifier naming a prohibited source is never masked by a longer
    # but milder alias. Length breaks ties toward the more specific name.
    padded = f" {key} "
    hits = [
        index.by_alias[alias_key]
        for alias_key in index.alias_keys
        if len(alias_key) >= 3 and f" {alias_key} " in padded
    ]
    if hits:
        best_hit = max(
            hits,
            key=lambda e: (
                _default_severity(e),
                len(normalize(e.canonical)),
            ),
        )
        return best_hit, "contains", 0.9

    best: Entry | None = None
    best_score = 0.0
    for alias_key, entry in index.by_alias.items():
        # Cheap length gate before the expensive ratio.
        if abs(len(alias_key) - len(key)) > 4:
            continue
        score = _similar(key, alias_key)
        if score > best_score:
            best, best_score = entry, score

    if best is not None and best_score >= FUZZY_FLOOR:
        return best, "fuzzy", best_score
    return None, "none", best_score
