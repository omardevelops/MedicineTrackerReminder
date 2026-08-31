"""Loading and indexing the knowledge base.

The index is built once and cached. Lookups are dictionary hits, so a scan
costs microseconds rather than a model call.
"""

from __future__ import annotations

import json
import os
from functools import lru_cache
from pathlib import Path
from typing import Any

from .models import Entry
from .normalize import canonical_code, normalize

_HERE = Path(__file__).resolve()

# Candidate locations, in order: an explicit override, the packaged copy for a
# wheel install, then the repository layout for a source checkout.
_CANDIDATES = [
    _HERE.parent / "data",
    _HERE.parents[2] / "data",
]


def data_dir() -> Path:
    """Locate the knowledge base.

    HALALFINDS_DATA overrides the search, which lets a deployment ship its own
    curated database without forking the package.
    """
    override = os.environ.get("HALALFINDS_DATA")
    if override:
        path = Path(override).expanduser()
        if not (path / "ingredients.json").is_file():
            raise FileNotFoundError(
                f"HALALFINDS_DATA={override} has no ingredients.json"
            )
        return path

    for candidate in _CANDIDATES:
        if (candidate / "ingredients.json").is_file():
            return candidate

    searched = ", ".join(str(c) for c in _CANDIDATES)
    raise FileNotFoundError(f"ingredient database not found (searched: {searched})")


def _load_json(name: str) -> dict[str, Any]:
    return json.loads((data_dir() / name).read_text(encoding="utf-8"))


def _to_entry(raw: dict[str, Any]) -> Entry:
    return Entry(
        id=raw["id"],
        canonical=raw["canonical"],
        category=raw.get("category", "other"),
        ambiguity=raw.get("ambiguity", "none"),
        codes=tuple(raw.get("codes", ())),
        aliases=tuple(raw.get("aliases", ())),
        rulings=dict(raw.get("rulings", {})),
        certifiers=dict(raw.get("certifiers", {})),
        resolves=dict(raw.get("resolves", {})),
        reason=raw.get("reason", ""),
        ask=raw.get("ask", ""),
        confidence=raw.get("confidence", "normal"),
    )


class Index:
    """Alias, code and token indexes over the ingredient entries."""

    def __init__(self, entries: list[Entry]) -> None:
        self.entries = entries
        self.by_id: dict[str, Entry] = {e.id: e for e in entries}
        self.by_alias: dict[str, Entry] = {}
        self.by_code: dict[str, Entry] = {}

        for entry in entries:
            for name in (entry.canonical, *entry.aliases):
                key = normalize(name)
                # First writer wins, so a specific entry is not shadowed by a
                # broad one listed later.
                self.by_alias.setdefault(key, entry)
            for code in entry.codes:
                code_key = canonical_code(code) or code.upper()
                self.by_code.setdefault(code_key, entry)

        # Alias keys grouped by word count, for the containment pass.
        self.alias_keys = sorted(self.by_alias, key=len, reverse=True)

    def __len__(self) -> int:
        return len(self.entries)


@lru_cache(maxsize=1)
def load_index() -> Index:
    raw = _load_json("ingredients.json")
    return Index([_to_entry(e) for e in raw["entries"]])


@lru_cache(maxsize=1)
def load_countries() -> dict[str, Any]:
    return _load_json("countries.json")
