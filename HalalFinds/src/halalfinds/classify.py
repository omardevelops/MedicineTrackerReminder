"""Deterministic classification of an ingredients panel.

The design rule: the ruling comes from the database, never from inference at
call time. What varies is which profile is applied and which label signals are
available to resolve a source ambiguity.
"""

from __future__ import annotations

from .data import Index, load_countries, load_index
from .matcher import match
from .models import Finding, Ruling, Verdict, worst
from .normalize import tokenize_with_context
from .panel import (
    ADVISORY_EXPLANATION,
    ADVISORY_ONLY,
    INSUFFICIENT,
    INSUFFICIENT_EXPLANATION,
    NotAnIngredientsList,
    detect,
)
from .qualifiers import find_qualifier

UNKNOWN_REASON = (
    "Not found in the ingredient database. Treated as doubtful rather than "
    "permitted, because an unrecognised ingredient may be animal-derived."
)
UNKNOWN_ASK = "What is this ingredient and what is it derived from?"


def _resolve_profile(country: str, profile: str | None) -> str:
    if profile:
        return profile
    countries = load_countries()["countries"]
    entry = countries.get(country.upper(), countries["GLOBAL"])
    return entry.get("default_profile", "mainstream")


def classify(
    text: str,
    country: str = "GLOBAL",
    profile: str | None = None,
    signals: tuple[str, ...] | list[str] = (),
    index: Index | None = None,
    force: bool = False,
) -> Verdict:
    """Classify a raw ingredients panel.

    Args:
        text: the transcribed ingredients list, as printed on the pack.
        country: ISO-style key into the country database, e.g. "US", "MY".
        profile: ruling profile override; defaults to the country's own.
        signals: label evidence that can resolve doubt, e.g. ("vegan",).
        force: rule on the text even if it does not look like an ingredients
            declaration. Off by default, because a verdict on an allergen
            advisory is a confident answer to a question nobody asked.

    Raises:
        NotAnIngredientsList: the text is an allergen advisory or carries no
            declaration at all, and `force` is not set.
    """
    kind, declaration, advisory = detect(text)
    if not force:
        if kind == ADVISORY_ONLY:
            raise NotAnIngredientsList(kind, ADVISORY_EXPLANATION, advisory)
        if kind == INSUFFICIENT:
            raise NotAnIngredientsList(kind, INSUFFICIENT_EXPLANATION, advisory)
        # An advisory tail describes contamination risk, not composition, so
        # only the declaration is ruled on.
        text = declaration

    index = index or load_index()
    country = country.upper()
    countries = load_countries()
    country_row = countries["countries"].get(country, countries["countries"]["GLOBAL"])
    active_profile = _resolve_profile(country, profile)
    signal_defs = countries["signals"]
    signals = tuple(s for s in signals if s in signal_defs)

    # Every ambiguity axis that the present signals can settle.
    resolvable: set[str] = set()
    for signal in signals:
        resolvable.update(signal_defs[signal]["resolves"])

    escalate = set(country_row.get("escalate", []))

    findings: list[Finding] = []
    for token, context in tokenize_with_context(text):
        entry, kind, score = match(token, index)

        if entry is None:
            findings.append(
                Finding(
                    text=token,
                    ruling=Ruling.MASHBOOH,
                    reason=UNKNOWN_REASON,
                    ask=UNKNOWN_ASK,
                    match_kind="none",
                    score=score,
                )
            )
            continue

        ruling = entry.ruling_for(active_profile)
        reason, ask, resolved_by = entry.reason, entry.ask, ""

        # The label may answer the source question itself, e.g. "fish gelatine"
        # or "mono- and diglycerides of vegetable origin". An explicit source on
        # the pack is stronger evidence than the entry's cautious default, in
        # either direction: it can clear a doubt or confirm a prohibition.
        qualified = find_qualifier(context, entry)
        if qualified is not None:
            qualifier, qualified_ruling = qualified
            ruling = qualified_ruling
            resolved_by = f"label:{qualifier}"
            reason = (
                f"{entry.reason} The label states the source as "
                f"{qualifier.replace('_', ' ')}."
            )
            ask = "" if ruling is not Ruling.MASHBOOH else entry.ask

        # A label signal can settle a doubt, but never overturns a definite
        # prohibition: a "vegan" claim does not make declared pork permissible.
        if (
            not resolved_by
            and ruling is Ruling.MASHBOOH
            and entry.ambiguity in resolvable
            and entry.ambiguity != "none"
        ):
            settling = next(
                s for s in signals if entry.ambiguity in signal_defs[s]["resolves"]
            )
            ruling = Ruling.HALAL
            resolved_by = settling
            reason = (
                f"{entry.reason} Resolved by the "
                f"{signal_defs[settling]['label'].lower()} on the pack."
            )
            ask = ""

        # A jurisdiction whose labelling law hides the source keeps the doubt
        # even where a profile would otherwise permit it.
        elif not resolved_by and ruling is Ruling.HALAL and entry.id in escalate:
            ruling = Ruling.MASHBOOH
            resolved_by = f"{country}-labelling"
            reason = (
                f"{entry.reason} Raised to doubtful for "
                f"{country_row['name']}, where labelling law does not require "
                f"the source to be disclosed."
            )
            ask = entry.ask

        findings.append(
            Finding(
                text=token,
                ruling=ruling,
                entry=entry,
                reason=reason,
                ask=ask,
                match_kind=kind,
                score=score,
                resolved_by=resolved_by,
            )
        )

    verdict = Verdict(
        ruling=worst([f.ruling for f in findings]),
        findings=findings,
        country=country,
        profile=active_profile,
        signals=signals,
    )
    verdict.notes = list(country_row.get("notes", []))
    if advisory and not force:
        verdict.advisory = advisory
    return verdict
