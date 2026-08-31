"""Deciding what kind of text we were actually handed.

A photograph of a pack or a menu may show several different blocks, and only
one of them supports a verdict. An allergen advisory ("may contain traces of
nuts") is a statement about cross-contamination risk, not a declaration of what
is in the food. Classifying one produces a confident verdict about nothing.

Real labels usually carry both: an ingredients declaration followed by an
advisory tail. So the job is to split them, rule on the declaration, and report
the advisory separately.
"""

from __future__ import annotations

import re

# Phrases that open an advisory or disclaimer. Everything from here to the end
# of the text describes possible contamination, not composition.
ADVISORY_MARKERS = [
    r"may contain\b",
    r"may also contain\b",
    r"traces of\b",
    r"not suitable for\b",
    r"produced in a (factory|facility|kitchen)\b",
    r"prepared in a (kitchen|facility)\b",
    r"packed in a (factory|facility)\b",
    r"cannot guarantee\b",
    r"allergen (advice|information|statement)\b",
    r"the following allergens\b",
    r"for any questions\b",
    r"contact the restaurant\b",
]

# An explicit declaration header. Its presence means a real ingredients list is
# somewhere in the text.
INGREDIENTS_HEADER = re.compile(
    r"\b(ingredients|ingredients|zutaten|ingredienti|ingredientes|"
    r"samenstelling|composition)\b\s*[:\-]",
    re.IGNORECASE,
)

_ADVISORY_RE = re.compile("|".join(ADVISORY_MARKERS), re.IGNORECASE)

INGREDIENTS = "ingredients"
ADVISORY_ONLY = "advisory_only"
INSUFFICIENT = "insufficient"


class NotAnIngredientsList(ValueError):
    """Raised when the text cannot support a verdict.

    Carries the detected kind and a human-readable explanation so a caller can
    tell the user what to photograph instead.
    """

    def __init__(self, kind: str, message: str, advisory: str = "") -> None:
        super().__init__(message)
        self.kind = kind
        self.advisory = advisory


def split_panel(text: str) -> tuple[str, str]:
    """Split text into (ingredients declaration, advisory tail).

    Either part may be empty. When an explicit 'Ingredients:' header appears,
    the declaration starts there, so surrounding marketing copy is discarded.
    """
    header = INGREDIENTS_HEADER.search(text)
    if header is not None:
        text = text[header.end():]

    advisory = _ADVISORY_RE.search(text)
    if advisory is None:
        return text.strip(), ""

    # An advisory marker before any declaration means the whole text is advisory.
    head = text[: advisory.start()]
    tail = text[advisory.start():]

    # Trim a dangling connector left behind by the split.
    head = re.sub(r"[.,;:\s]*$", "", head)
    return head.strip(), tail.strip()


def detect(text: str) -> tuple[str, str, str]:
    """Classify the input.

    Returns (kind, ingredients_part, advisory_part).
    """
    ingredients, advisory = split_panel(text)

    # A declaration needs enough substance to rule on. One or two words left
    # after stripping an advisory is a fragment, not a list.
    substantive = len([p for p in re.split(r"[,;\n]", ingredients) if p.strip()])

    if substantive >= 2:
        return INGREDIENTS, ingredients, advisory
    if advisory:
        return ADVISORY_ONLY, ingredients, advisory
    if substantive >= 1:
        return INGREDIENTS, ingredients, advisory
    return INSUFFICIENT, ingredients, advisory


ADVISORY_EXPLANATION = (
    "This is an allergen advisory, not an ingredients declaration. It states "
    "what the food might be contaminated with, not what it is made of, so it "
    "cannot support a halal verdict. Photograph the 'Ingredients:' list "
    "instead. For a restaurant menu, a dish's ingredients usually have to be "
    "requested from the restaurant directly."
)

INSUFFICIENT_EXPLANATION = (
    "No ingredients declaration found in this text. Photograph the panel that "
    "begins with 'Ingredients:'."
)
