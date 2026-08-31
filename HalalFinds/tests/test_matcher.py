import pytest

from halalfinds.data import load_index
from halalfinds.matcher import match


@pytest.fixture(scope="module")
def index():
    return load_index()


def test_exact_alias(index):
    entry, kind, _ = match("Soya Lecithin", index)
    assert entry.id == "lecithin"
    assert kind == "exact"


def test_code_lookup(index):
    entry, kind, _ = match("E471", index)
    assert entry.id == "e471"
    assert kind == "code"


def test_letter_suffixed_code_falls_back_to_family(index):
    entry, kind, _ = match("E472e", index)
    assert entry.id == "e472"
    assert kind == "code"


def test_fuzzy_absorbs_ocr_damage(index):
    entry, kind, score = match("glyoerides", index)
    assert entry.id == "e471"
    assert kind == "fuzzy"
    assert score >= 0.86


def test_unknown_ingredient_is_not_guessed(index):
    entry, kind, _ = match("zorbium blend", index)
    assert entry is None
    assert kind == "none"


def test_containment_prefers_the_most_severe_match(index):
    """'pork gelatine' must not be softened to plain gelatine."""
    entry, kind, _ = match("pork gelatine", index)
    assert entry.id == "pork"
    assert kind == "contains"
