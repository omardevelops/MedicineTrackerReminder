"""Command-line entry point: halalfinds check ..."""

from __future__ import annotations

import argparse
import json
import sys

from .classify import classify
from .data import load_countries, load_index
from .models import Ruling
from .render import render

# Exit codes let a caller branch on the verdict without parsing output.
EXIT_CODE = {Ruling.HALAL: 0, Ruling.MASHBOOH: 2, Ruling.HARAM: 3}


def build_parser() -> argparse.ArgumentParser:
    parser = argparse.ArgumentParser(
        prog="halalfinds",
        description="Classify a product's ingredient list as halal, haram or mashbooh.",
    )
    sub = parser.add_subparsers(dest="command", required=True)

    check = sub.add_parser("check", help="classify an ingredients list")
    check.add_argument(
        "text",
        nargs="?",
        help="the ingredients list; omit to read from stdin",
    )
    check.add_argument("-c", "--country", default="GLOBAL", help="country code, e.g. US, MY, GB")
    check.add_argument("-p", "--profile", default=None, help="ruling profile override")
    check.add_argument(
        "-s",
        "--signal",
        action="append",
        default=[],
        help="label signal, repeatable: vegan, vegetarian, halal_certified, kosher",
    )
    check.add_argument("--json", action="store_true", help="emit JSON instead of text")
    check.add_argument("-v", "--verbose", action="store_true", help="list halal ingredients too")
    check.add_argument("--no-colour", action="store_true", help="disable ANSI colour")

    sub.add_parser("countries", help="list supported countries and profiles")

    lookup = sub.add_parser("lookup", help="look up one ingredient")
    lookup.add_argument("term")
    lookup.add_argument("-p", "--profile", default="mainstream")

    return parser


def _cmd_check(args: argparse.Namespace) -> int:
    text = args.text if args.text is not None else sys.stdin.read()
    if not text.strip():
        print("No ingredients provided.", file=sys.stderr)
        return 1

    verdict = classify(
        text,
        country=args.country,
        profile=args.profile,
        signals=tuple(args.signal),
    )

    if args.json:
        print(json.dumps(verdict.to_dict(), indent=2, ensure_ascii=False))
    else:
        colour = sys.stdout.isatty() and not args.no_colour
        print(render(verdict, colour=colour, verbose=args.verbose))
    return EXIT_CODE[verdict.ruling]


def _cmd_countries(_: argparse.Namespace) -> int:
    data = load_countries()
    print("Countries:")
    for code, row in data["countries"].items():
        certifiers = ", ".join(dict.fromkeys(row.get("certifiers", []))) or "-"
        print(f"  {code:7} {row['name']:26} profile={row['default_profile']:11} {certifiers}")
    print("\nProfiles:")
    for name, desc in data["profiles"].items():
        print(f"  {name:11} {desc}")
    print("\nSignals:")
    for name, row in data["signals"].items():
        print(f"  {name:20} {row['label']}")
    return 0


def _cmd_lookup(args: argparse.Namespace) -> int:
    from .matcher import match

    entry, kind, score = match(args.term, load_index())
    if entry is None:
        print(f"'{args.term}' is not in the database (closest score {score:.0%}).")
        print("It would be reported as MASHBOOH - unidentified.")
        return 2

    ruling = entry.ruling_for(args.profile)
    print(f"{entry.canonical}  [{ruling.value.upper()}]  (match: {kind})")
    if entry.codes:
        print(f"  codes:    {', '.join(entry.codes)}")
    print(f"  category: {entry.category}")
    print(f"  doubt:    {entry.ambiguity}")
    print(f"  reason:   {entry.reason}")
    if entry.resolves:
        print("  resolves:")
        for source, outcome in entry.resolves.items():
            print(f"    {source:22} -> {outcome}")
    if entry.certifiers:
        print("  certifiers:")
        for body, outcome in entry.certifiers.items():
            print(f"    {body:22} -> {outcome}")
    if entry.ask:
        print(f"  ask:      {entry.ask}")
    return EXIT_CODE[ruling]


def main(argv: list[str] | None = None) -> int:
    args = build_parser().parse_args(argv)
    handlers = {"check": _cmd_check, "countries": _cmd_countries, "lookup": _cmd_lookup}
    return handlers[args.command](args)


if __name__ == "__main__":
    raise SystemExit(main())
