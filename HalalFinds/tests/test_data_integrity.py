"""Guards on the knowledge base itself. Bad data is the main accuracy risk."""

import json

import pytest

from halalfinds.data import data_dir, load_countries, load_index
from halalfinds.models import Ruling
from halalfinds.normalize import canonical_code, normalize

VALID_RULINGS = {r.value for r in Ruling}
VALID_AMBIGUITIES = {
    "none", "animal_source", "alcohol", "insect", "slaughter", "process", "school",
}


@pytest.fixture(scope="module")
def index():
    return load_index()


def test_ids_are_unique(index):
    ids = [e.id for e in index.entries]
    assert len(ids) == len(set(ids))


def test_every_entry_has_a_default_ruling(index):
    for entry in index.entries:
        assert "default" in entry.rulings, entry.id


def test_all_rulings_are_valid(index):
    for entry in index.entries:
        for source in (entry.rulings, entry.certifiers, entry.resolves):
            for key, value in source.items():
                assert value in VALID_RULINGS, f"{entry.id}.{key} = {value}"


def test_ambiguity_axes_are_known(index):
    for entry in index.entries:
        assert entry.ambiguity in VALID_AMBIGUITIES, entry.id


def test_every_doubtful_entry_explains_itself(index):
    """A mashbooh verdict the user cannot act on is not useful."""
    for entry in index.entries:
        if entry.rulings.get("default") == "mashbooh":
            assert entry.reason, entry.id


def test_every_entry_has_a_reason(index):
    for entry in index.entries:
        assert entry.reason, entry.id


def test_codes_are_canonical(index):
    for entry in index.entries:
        for code in entry.codes:
            assert canonical_code(code) == code, f"{entry.id}: {code}"


def test_no_alias_collides_across_entries(index):
    """A duplicated alias silently shadows one entry, so fail loudly instead."""
    seen: dict[str, str] = {}
    for entry in index.entries:
        for name in (entry.canonical, *entry.aliases):
            key = normalize(name)
            assert key not in seen or seen[key] == entry.id, (
                f"alias '{key}' claimed by both {seen.get(key)} and {entry.id}"
            )
            seen[key] = entry.id


def test_no_code_collides_across_entries(index):
    seen: dict[str, str] = {}
    for entry in index.entries:
        for code in entry.codes:
            key = canonical_code(code) or code
            assert key not in seen or seen[key] == entry.id, (
                f"code '{key}' claimed by both {seen.get(key)} and {entry.id}"
            )
            seen[key] = entry.id


def test_country_profiles_are_defined():
    data = load_countries()
    profiles = set(data["profiles"])
    for code, row in data["countries"].items():
        assert row["default_profile"] in profiles, code


def test_country_escalations_reference_real_entries(index):
    for code, row in load_countries()["countries"].items():
        for entry_id in row.get("escalate", []):
            assert entry_id in index.by_id, f"{code} escalates unknown '{entry_id}'"


def test_signal_axes_are_known():
    for name, row in load_countries()["signals"].items():
        for axis in row["resolves"]:
            assert axis in VALID_AMBIGUITIES, f"{name} -> {axis}"


def test_json_files_are_valid_and_stable():
    for name in ("ingredients.json", "countries.json"):
        json.loads((data_dir() / name).read_text(encoding="utf-8"))
