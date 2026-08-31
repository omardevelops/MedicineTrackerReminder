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


# --- Input that cannot support a verdict -----------------------------------
# Regression tests from a real photo: a restaurant allergen disclaimer was
# classified as if it were an ingredients list and returned MASHBOOH.

import pytest

from halalfinds.panel import ADVISORY_ONLY, INSUFFICIENT, NotAnIngredientsList

MENU_DISCLAIMER = (
    "All dishes may contain traces of the following allergens: Gluten, "
    "Crustaceans, Eggs, Fish, Peanuts, Soybeans, Milk, Nuts (e.g. almonds, "
    "hazelnuts, walnuts, cashews, pecan nuts, Brazil nuts, pistachio nuts, "
    "macadamia nuts), Celery, Mustard, Sesame, Sulphur dioxide/sulphites, "
    "Lupin, Molluscs. For any questions regarding the allergen contents of "
    "specific dishes please contact the restaurant directly."
)


def test_allergen_disclaimer_gets_no_verdict():
    """An advisory says what food might touch, not what it is made of."""
    with pytest.raises(NotAnIngredientsList) as excinfo:
        classify(MENU_DISCLAIMER, country="GB")
    assert excinfo.value.kind == ADVISORY_ONLY


def test_disclaimer_can_be_forced():
    """--force still produces a verdict; it just should not be reached for."""
    verdict = classify(MENU_DISCLAIMER, country="GB", force=True)
    assert verdict.ruling in (Ruling.HALAL, Ruling.MASHBOOH)


@pytest.mark.parametrize(
    "allergen",
    [
        "Gluten", "Crustaceans", "Eggs", "Fish", "Peanuts", "Soybeans", "Milk",
        "almonds", "hazelnuts", "walnuts", "cashews", "pecan nuts",
        "Brazil nuts", "pistachio nuts", "macadamia nuts", "Celery", "Mustard",
        "Sesame", "Sulphur dioxide", "Lupin", "Molluscs",
    ],
)
def test_regulated_allergens_are_recognised(allergen):
    """Ordinary halal foods must not read as 'unidentified'.

    A doubtful verdict on celery makes the genuine mashbooh findings look like
    noise, which is how a user learns to ignore them.
    """
    verdict = classify(f"Sugar, {allergen}", country="GB", force=True)
    assert verdict.unknown == [], f"{allergen} was not recognised"


def test_advisory_tail_is_split_off_not_ruled_on():
    """A real label carries both; only the declaration is ruled on."""
    verdict = classify(
        "Ingredients: Sugar, Cocoa Butter, Soya Lecithin. "
        "May contain traces of nuts and milk.",
        country="GB",
    )
    assert verdict.ruling is Ruling.HALAL
    assert [f.name for f in verdict.findings] == [
        "Sugar", "Vegetable oils and fats", "Lecithin",
    ]
    assert "may contain traces" in verdict.advisory.lower()


def test_empty_text_gets_no_verdict():
    with pytest.raises(NotAnIngredientsList) as excinfo:
        classify("   ", country="GB")
    assert excinfo.value.kind == INSUFFICIENT


def test_plurals_match_singular_entries():
    verdict = classify("Eggs, Nuts, Molluscs, Crustaceans", country="GB", force=True)
    assert verdict.unknown == []


# --- Regressions from a real chocolate-bar panel ---------------------------

BAR_PANEL = (
    "Ingredients: Sugar, Glucose Syrup, PEANUTS, Skimmed MILK Powder, "
    "Cocoa Butter°, Cocoa Mass°, Sunflower Oil, Palm Fat, "
    "Whey Permeate (MILK), MILK Fat, Salt, Emulsifier (SOYA Lecithin), "
    "EGG White Powder. (May Contain: Other NUTS). May contain: Eggs, Soy"
)


def test_bar_panel_is_doubtful_only_because_of_whey():
    verdict = classify(BAR_PANEL, country="GB")
    assert verdict.ruling is Ruling.MASHBOOH
    assert [f.entry.id for f in verdict.mashbooh] == ["whey"]


def test_bar_panel_has_no_unidentified_ingredients():
    """Ordinary foods reading as doubtful erodes trust in real findings."""
    assert classify(BAR_PANEL, country="GB").unknown == []


def test_organic_marker_does_not_break_matching():
    verdict = classify("Cocoa Butter°, Cocoa Mass°", country="GB")
    assert verdict.unknown == []


def test_soya_qualifier_clears_lecithin():
    verdict = classify("Emulsifier (SOYA Lecithin)", country="GB")
    assert verdict.ruling is Ruling.HALAL
    assert verdict.findings[0].resolved_by == "label:soy"


def test_bracketed_advisory_does_not_truncate_the_list():
    """'Sugar, Milk (May contain: nuts), Salt' must not lose the Salt."""
    verdict = classify("Sugar, Milk (May contain: nuts), Salt, Gelatine", country="GB")
    names = [f.entry.id for f in verdict.findings]
    assert "gelatin" in names and "salt-spices" in names
    assert "may contain" in verdict.advisory.lower()


def test_token_text_is_clean_of_punctuation_debris():
    verdict = classify(BAR_PANEL, country="GB")
    for finding in verdict.findings:
        assert not finding.text.strip().endswith(("(", ".", ","))


def test_trailing_legal_statement_does_not_swallow_an_ingredient():
    """'EGG White Powder. MILK Chocolate contains...' is two things, not one."""
    verdict = classify(
        "Ingredients: Sugar, EGG White Powder. MILK Chocolate Contains "
        "MILK Solids 14% Minimum.",
        country="GB",
    )
    assert "egg" in [f.entry.id for f in verdict.findings]


def test_decimal_points_are_not_split_on():
    verdict = classify("Sugar, Salt, Cocoa Mass 32.5%", country="GB")
    assert verdict.unknown == []
