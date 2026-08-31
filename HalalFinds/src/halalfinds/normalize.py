"""Turning a photographed ingredients panel into comparable tokens.

OCR output is messy: ligature damage, stray punctuation, line-wrapped words,
parenthetical sub-lists, and mixed-script labels. Everything here is string
work with no model in the loop, which is what keeps a scan fast.
"""

from __future__ import annotations

import re
import unicodedata

# Wrappers that describe a *function* rather than a substance. We strip them so
# "emulsifier (soya lecithin)" matches the lecithin entry rather than missing.
CLASS_WORDS = {
    "emulsifier", "emulsifiers", "stabiliser", "stabilizer", "stabilisers",
    "thickener", "thickeners", "preservative", "preservatives", "antioxidant",
    "antioxidants", "colour", "color", "colours", "colors", "colouring",
    "coloring", "acid", "acidity regulator", "raising agent", "raising agents",
    "anti-caking agent", "anticaking agent", "flour treatment agent",
    "sweetener", "sweeteners", "humectant", "firming agent", "glazing agent",
    "flavour enhancer", "flavor enhancer", "gelling agent", "bulking agent",
    "sequestrant", "propellant", "packaging gas", "carrier", "foaming agent",
    "anti-foaming agent",
}

# Bare source qualifiers. They are never ingredients in their own right, but
# they answer the source question for the ingredient they sit beside, so they
# are dropped as tokens and kept as context.
QUALIFIER_WORDS = {
    "vegetable", "vegetal", "plant", "plant-based", "of vegetable origin",
    "vegetable origin", "synthetic", "microbial", "bovine", "porcine", "fish",
    "marine", "halal", "animal", "beef", "soy", "soya", "sunflower", "egg",
    "lanolin", "lichen", "hpmc", "hypromellose", "non-animal",
}

# Noise that carries no ingredient meaning.
NOISE = {
    "ingredients", "ingredient", "contains", "may contain", "and", "or", "of",
    "the", "with", "from", "including", "e", "less than", "made with",
}

_TRAILING_PCT = re.compile(r"\s*\(?\d+(?:[.,]\d+)?\s*%\)?\s*$")
_LEADING_PCT = re.compile(r"^\s*\d+(?:[.,]\d+)?\s*%\s*")
_MULTISPACE = re.compile(r"\s+")
_ECODE = re.compile(r"\b(?:E|INS)[\s\-]?(\d{3,4}[a-z]{0,2})\b", re.IGNORECASE)
_BARE_CODE = re.compile(r"^(\d{3,4}[a-z]{0,2})$")


def strip_accents(text: str) -> str:
    """Fold accents so 'lecithine' and its accented spelling compare equal."""
    decomposed = unicodedata.normalize("NFKD", text)
    return "".join(c for c in decomposed if not unicodedata.combining(c))


def normalize(text: str) -> str:
    """Canonical form of a single ingredient token."""
    text = strip_accents(text.lower())
    text = text.replace("&", " and ")
    text = _LEADING_PCT.sub("", text)
    text = _TRAILING_PCT.sub("", text)
    # Keep hyphens and apostrophes; they distinguish real names.
    text = re.sub(r"[^\w\s\-']", " ", text)
    text = text.replace("_", " ")
    return _MULTISPACE.sub(" ", text).strip(" -")


def canonical_code(token: str) -> str | None:
    """Return a canonical 'E471'-style code if the token names an additive number.

    Handles 'E471', 'e 471', 'INS 471', '471' and the 'E472e' letter suffixes.
    Bare numbers are only treated as codes in the 100-1599 additive range.
    """
    match = _ECODE.search(token)
    if match:
        return "E" + match.group(1).lower().replace(" ", "")
    bare = _BARE_CODE.match(token.strip())
    if bare:
        digits = re.match(r"\d+", bare.group(1))
        assert digits is not None
        if 100 <= int(digits.group()) <= 1599:
            return "E" + bare.group(1).lower()
    return None


def _split_top_level(text: str) -> list[str]:
    """Split on commas and semicolons that are not inside brackets."""
    parts: list[str] = []
    depth = 0
    current: list[str] = []
    for char in text:
        if char in "([{":
            depth += 1
            current.append(char)
        elif char in ")]}":
            depth = max(0, depth - 1)
            current.append(char)
        elif char in ",;\n" and depth == 0:
            parts.append("".join(current))
            current = []
        else:
            current.append(char)
    parts.append("".join(current))
    return [p for p in parts if p.strip()]


def _expand(part: str, context: str = "") -> list[tuple[str, str]]:
    """Expand 'emulsifier (E471, soya lecithin)' into (token, context) pairs.

    The wrapper is kept as a candidate too, unless it is a bare function word,
    because some entries ('modified starch') are themselves class-like names.
    Context is the whole original segment, so a source qualifier printed in
    brackets stays attached to the ingredient it qualifies.
    """
    part = part.strip()
    context = context or part
    match = re.match(r"^([^(\[]*)[(\[](.*)[)\]]\s*$", part, re.DOTALL)
    if not match:
        return [(part, context)]

    head, inner = match.group(1).strip(), match.group(2).strip()
    out: list[tuple[str, str]] = []
    if head and normalize(head) not in CLASS_WORDS:
        out.append((head, context))
    for sub in _split_top_level(inner):
        out.extend(_expand(sub, context))
    if not out:
        out.append((head or inner, context))
    return out


def tokenize_with_context(text: str) -> list[tuple[str, str]]:
    """Split an ingredients panel into (token, context) pairs in label order.

    Duplicates are dropped, so a repeated 'salt' is reported once.
    """
    # Drop a leading "Ingredients:" header and unwrap OCR line breaks that
    # split a word across lines.
    text = re.sub(r"^\s*ingredient(s)?\s*[:\-]", " ", text, flags=re.IGNORECASE)
    text = re.sub(r"(\w)-\s*\n\s*(\w)", r"\1\2", text)
    text = text.replace("\r", "\n")
    # A sentence-ending period separates ingredients from the legal statements
    # that follow them ("...EGG White Powder. MILK Chocolate contains..."). A
    # period inside a decimal is left alone by the lookahead.
    # Two word characters must precede it, which leaves "e.g." and "i.e."
    # intact while still separating "...Powder. MILK Chocolate contains...".
    text = re.sub(r"(?<=\w{2})\.(?=\s|$)", ",", text)

    tokens: list[tuple[str, str]] = []
    seen: set[str] = set()
    for part in _split_top_level(text):
        for candidate, context in _expand(part):
            cleaned = candidate.strip().strip(".,;:·•*-()[] ")
            if not cleaned:
                continue
            key = normalize(cleaned)
            if not key or key in NOISE or key in seen:
                continue
            # A bare qualifier is context for its neighbour, not an ingredient.
            if key in QUALIFIER_WORDS:
                continue
            # A token that is only digits and no additive code is packaging noise.
            if key.isdigit() and canonical_code(key) is None:
                continue
            seen.add(key)
            tokens.append((cleaned, context.strip()))
    return tokens


def tokenize(text: str) -> list[str]:
    """Split a raw ingredients panel into individual ingredient strings."""
    return [token for token, _ in tokenize_with_context(text)]
