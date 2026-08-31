"""Human-readable rendering of a verdict."""

from __future__ import annotations

from .models import Ruling, Verdict

BADGE = {
    Ruling.HALAL: "HALAL",
    Ruling.MASHBOOH: "MASHBOOH (doubtful)",
    Ruling.HARAM: "HARAM",
}

MARK = {Ruling.HALAL: "[ok]", Ruling.MASHBOOH: "[??]", Ruling.HARAM: "[!!]"}

COLOUR = {Ruling.HALAL: "\033[32m", Ruling.MASHBOOH: "\033[33m", Ruling.HARAM: "\033[31m"}
RESET = "\033[0m"

HEADLINE = {
    Ruling.HALAL: "No prohibited or doubtful ingredients found.",
    Ruling.MASHBOOH: "Contains ingredients whose source cannot be confirmed from the label.",
    Ruling.HARAM: "Contains at least one prohibited ingredient.",
}


def render(verdict: Verdict, colour: bool = False, verbose: bool = False) -> str:
    """Render a verdict as plain text."""
    def tint(text: str, ruling: Ruling) -> str:
        return f"{COLOUR[ruling]}{text}{RESET}" if colour else text

    lines: list[str] = []
    lines.append(tint(f"== {BADGE[verdict.ruling]} ==", verdict.ruling))
    lines.append(HEADLINE[verdict.ruling])
    lines.append("")

    context = f"Country: {verdict.country}   Profile: {verdict.profile}"
    if verdict.signals:
        context += f"   Signals: {', '.join(verdict.signals)}"
    lines.append(context)
    lines.append("")

    # Prohibited and doubtful first: that is what the user actually needs.
    ordered = sorted(
        verdict.findings, key=lambda f: (-f.ruling.severity, verdict.findings.index(f))
    )
    for finding in ordered:
        if finding.ruling is Ruling.HALAL and not verbose:
            continue
        head = f"{MARK[finding.ruling]} {finding.name}"
        if finding.text.strip().lower() != finding.name.lower():
            head += f"  (label: \"{finding.text}\")"
        lines.append(tint(head, finding.ruling))
        if finding.reason:
            lines.append(f"      {finding.reason}")
        if finding.match_kind == "fuzzy":
            lines.append(
                f"      Matched approximately ({finding.score:.0%}) - check the "
                f"spelling on the pack."
            )
        lines.append("")

    halal_count = len(
        [f for f in verdict.findings if f.ruling is Ruling.HALAL]
    )
    if not verbose and halal_count:
        noun = "ingredient" if halal_count == 1 else "ingredients"
        lines.append(f"({halal_count} further {noun} found halal.)")
        lines.append("")

    if verdict.questions:
        lines.append("Ask the manufacturer:")
        lines.extend(f"  - {q}" for q in verdict.questions)
        lines.append("")

    if verdict.notes:
        lines.append(f"Labelling notes for {verdict.country}:")
        lines.extend(f"  - {n}" for n in verdict.notes)
        lines.append("")

    lines.append(
        "This is an ingredient-label analysis, not a certification. Where a "
        "recognised halal mark is present, it supersedes this reading."
    )
    return "\n".join(lines)
