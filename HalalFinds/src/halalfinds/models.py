"""Core value types for HalalFinds."""

from __future__ import annotations

from dataclasses import dataclass, field
from enum import Enum
from typing import Any


class Ruling(str, Enum):
    """A verdict on a single ingredient or a whole product.

    Ordered by severity: aggregation always takes the worst ruling present.
    """

    HALAL = "halal"
    MASHBOOH = "mashbooh"
    HARAM = "haram"

    @property
    def severity(self) -> int:
        return _SEVERITY[self]


_SEVERITY = {Ruling.HALAL: 0, Ruling.MASHBOOH: 1, Ruling.HARAM: 2}


def worst(rulings: list[Ruling]) -> Ruling:
    """Worst-case aggregation. An empty list is halal by vacuous truth."""
    return max(rulings, key=lambda r: r.severity, default=Ruling.HALAL)


@dataclass(frozen=True)
class Entry:
    """One ingredient in the knowledge base."""

    id: str
    canonical: str
    category: str = "other"
    ambiguity: str = "none"
    codes: tuple[str, ...] = ()
    aliases: tuple[str, ...] = ()
    rulings: dict[str, str] = field(default_factory=dict)
    certifiers: dict[str, str] = field(default_factory=dict)
    resolves: dict[str, str] = field(default_factory=dict)
    reason: str = ""
    ask: str = ""
    confidence: str = "normal"

    def ruling_for(self, profile: str) -> Ruling:
        """Resolve this entry's ruling under a profile.

        Order of precedence: a certifier-specific stance, then a named profile
        override, then the entry default.
        """
        raw = (
            self.certifiers.get(profile)
            or self.rulings.get(profile)
            or self.rulings.get("default")
            or "mashbooh"
        )
        return Ruling(raw)


@dataclass
class Finding:
    """One ingredient from the label, matched (or not) against the database."""

    text: str
    ruling: Ruling
    entry: Entry | None = None
    reason: str = ""
    ask: str = ""
    match_kind: str = "none"
    score: float = 0.0
    resolved_by: str = ""

    @property
    def name(self) -> str:
        return self.entry.canonical if self.entry else self.text

    def to_dict(self) -> dict[str, Any]:
        return {
            "text": self.text,
            "matched": self.name,
            "ruling": self.ruling.value,
            "reason": self.reason,
            "ask": self.ask or None,
            "match": self.match_kind,
            "score": round(self.score, 3),
            "resolved_by": self.resolved_by or None,
            "entry_id": self.entry.id if self.entry else None,
        }


@dataclass
class Verdict:
    """The whole-product result."""

    ruling: Ruling
    findings: list[Finding]
    country: str = "GLOBAL"
    profile: str = "mainstream"
    signals: tuple[str, ...] = ()
    notes: list[str] = field(default_factory=list)
    # An allergen advisory found alongside the declaration. Reported, never
    # ruled on: it describes contamination risk, not composition.
    advisory: str = ""

    @property
    def haram(self) -> list[Finding]:
        return [f for f in self.findings if f.ruling is Ruling.HARAM]

    @property
    def mashbooh(self) -> list[Finding]:
        return [f for f in self.findings if f.ruling is Ruling.MASHBOOH]

    @property
    def unknown(self) -> list[Finding]:
        return [f for f in self.findings if f.match_kind == "none"]

    @property
    def questions(self) -> list[str]:
        """Deduplicated manufacturer questions, in order of first appearance."""
        seen: dict[str, None] = {}
        for f in self.findings:
            if f.ask and f.ruling is not Ruling.HALAL:
                seen.setdefault(f.ask, None)
        return list(seen)

    def to_dict(self) -> dict[str, Any]:
        return {
            "ruling": self.ruling.value,
            "country": self.country,
            "profile": self.profile,
            "signals": list(self.signals),
            "counts": {
                "total": len(self.findings),
                "haram": len(self.haram),
                "mashbooh": len(self.mashbooh),
                "unidentified": len(self.unknown),
            },
            "findings": [f.to_dict() for f in self.findings],
            "questions": self.questions,
            "notes": self.notes,
            "advisory": self.advisory or None,
        }
