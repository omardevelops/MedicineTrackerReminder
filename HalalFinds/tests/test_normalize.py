from halalfinds.normalize import canonical_code, normalize, tokenize, tokenize_with_context


def test_strips_percentages_and_case():
    assert normalize("Cocoa Butter (32%)") == "cocoa butter"
    assert normalize("  SUGAR  ") == "sugar"


def test_folds_accents_and_ampersand():
    assert normalize("Lécithine") == "lecithine"
    assert normalize("Mono- & Diglycerides") == "mono- and diglycerides"


def test_expands_class_name_wrappers():
    tokens = tokenize("Emulsifier (E471, Soya Lecithin)")
    assert tokens == ["E471", "Soya Lecithin"]


def test_keeps_non_class_head_word():
    assert "Chocolate" in tokenize("Chocolate (sugar, cocoa mass)")


def test_preserves_label_order_and_dedupes():
    assert tokenize("Salt, Sugar, Salt") == ["Salt", "Sugar"]


def test_drops_ingredients_header():
    assert tokenize("INGREDIENTS: Water, Salt") == ["Water", "Salt"]


def test_rejoins_ocr_hyphen_line_break():
    assert "Gelatine" in tokenize("Sugar, Gela-\ntine")


def test_bare_qualifier_is_context_not_token():
    pairs = tokenize_with_context("Glycerol (vegetable)")
    assert [t for t, _ in pairs] == ["Glycerol"]
    assert "vegetable" in pairs[0][1]


def test_canonical_code_forms():
    assert canonical_code("E471") == "E471"
    assert canonical_code("e 471") == "E471"
    assert canonical_code("INS-471") == "E471"
    assert canonical_code("472e") == "E472e"


def test_bare_number_outside_additive_range_is_not_a_code():
    assert canonical_code("2024") is None
    assert canonical_code("12") is None
