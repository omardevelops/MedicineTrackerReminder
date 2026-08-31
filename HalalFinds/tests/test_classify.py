from halalfinds import Ruling, classify


def test_plainly_halal_product():
    v = classify("Water, Sugar, Citric Acid, Pectin", country="GB")
    assert v.ruling is Ruling.HALAL


def test_declared_pork_is_haram():
    v = classify("Wheat flour, pork fat, salt", country="GB")
    assert v.ruling is Ruling.HARAM


def test_unqualified_gelatine_is_doubtful():
    v = classify("Sugar, Gelatine", country="GB")
    assert v.ruling is Ruling.MASHBOOH


def test_unknown_ingredient_is_doubtful_never_halal():
    """The central safety property: silence is never permission."""
    v = classify("Sugar, Zorbium Blend", country="GB")
    assert v.ruling is Ruling.MASHBOOH
    assert v.unknown and v.unknown[0].text == "Zorbium Blend"


def test_worst_case_aggregation():
    v = classify("Sugar, Gelatine, Lard", country="GB")
    assert v.ruling is Ruling.HARAM


def test_label_qualifier_clears_doubt():
    v = classify("Emulsifier (mono- and diglycerides of vegetable origin)", country="GB")
    assert v.ruling is Ruling.HALAL
    assert v.findings[0].resolved_by == "label:plant"


def test_label_qualifier_confirms_prohibition():
    v = classify("Gelatine (porcine), sugar", country="GB")
    assert v.ruling is Ruling.HARAM


def test_fish_gelatine_is_halal():
    v = classify("Sugar, fish gelatine", country="GB")
    assert v.ruling is Ruling.HALAL


def test_vegan_signal_resolves_source_doubt():
    v = classify("Sugar, Emulsifier (E471)", country="GB", signals=("vegan",))
    assert v.ruling is Ruling.HALAL


def test_vegan_signal_does_not_excuse_declared_pork():
    """A signal may settle a doubt; it can never overturn a prohibition."""
    v = classify("Sugar, Lard", country="GB", signals=("vegan",))
    assert v.ruling is Ruling.HARAM


def test_vegetarian_signal_does_not_resolve_carmine():
    v = classify("Sugar, E120", country="IN", signals=("vegetarian",))
    assert v.ruling is Ruling.MASHBOOH


def test_us_labelling_escalates_sugar():
    """Bone-char refining is a live question in the US, not in the EU."""
    us = classify("Sugar", country="US")
    gb = classify("Sugar", country="GB")
    assert us.ruling is Ruling.MASHBOOH
    assert gb.ruling is Ruling.HALAL


def test_profile_changes_the_verdict_on_carmine():
    assert classify("E120", profile="lenient").ruling is Ruling.HALAL
    assert classify("E120", profile="mainstream").ruling is Ruling.MASHBOOH
    assert classify("E120", profile="strict").ruling is Ruling.HARAM


def test_certifier_profile_overrides_the_default():
    assert classify("E120", country="MY").ruling is Ruling.HARAM


def test_country_default_profile_is_applied():
    assert classify("Sugar, Gelatine", country="MY").profile == "JAKIM"


def test_modified_starch_is_not_falsely_flagged():
    v = classify("Modified maize starch, salt", country="GB")
    assert v.ruling is Ruling.HALAL


def test_questions_are_deduplicated():
    v = classify("Gelatine, Gelatine, Natural Flavouring", country="GB")
    assert len(v.questions) == len(set(v.questions))


def test_verdict_serialises():
    d = classify("Sugar, Gelatine", country="GB").to_dict()
    assert d["ruling"] == "mashbooh"
    assert d["counts"]["mashbooh"] == 1
