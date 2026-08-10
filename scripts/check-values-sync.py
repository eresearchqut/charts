#!/usr/bin/env python3
"""Ensure values.yaml defaults stay in sync with values.example.yaml.

values.example.yaml generates the readme and values.schema.json, so it must
mirror values.yaml: every default in values.yaml must appear in the example
with the same value, and every top-level key in the example must exist in
values.yaml. Example-only *nested* keys are allowed (they document optional
knobs whose default is empty).

Two kinds of intentional divergence are inferred directly from source
comments rather than hardcoded here:

* In values.example.yaml, a key annotated `@schema ...` with `skipProperties:
  true`, `patternProperties:`, or `itemRef:` tells helm-schema not to derive
  real structure from what's written below it (a well-known k8s type, a
  dynamic-key map, or array items validated by an external schema). Content
  under such a key is illustrative, so it's exempt from the equality check.
* In values.yaml, a key annotated `@sync-ignore: <reason>` is intentionally
  left out of the example entirely (see the marker's own comment for why)
  and is exempt from the "must appear in the example" requirement.
"""

import re
import sys
from pathlib import Path

import yaml

COMMENT_RE = re.compile(r"^\s*#(?P<text>.*)$")
KEY_RE = re.compile(r'^(?P<indent>[ \t]*)(?:-\s+)?(?P<key>"[^"]*"|\'[^\']*\'|[^\s:#][^:]*):(?:\s|$)')
BLOCK_SCALAR_TOKENS = {"|", "|-", "|+", ">", ">-", ">+"}
OPAQUE_RE = re.compile(r"\b(skipProperties\s*:\s*true|patternProperties\s*:|itemRef\s*:)")


def marked_paths(text, marker, pattern=None):
    """Dotted key paths whose immediately preceding comment block contains a
    line starting with `marker` (optionally also matching `pattern`).

    This is a small line-oriented scanner, not a full YAML+comment parser:
    it tracks nesting purely from indentation, which is exactly how
    helm-docs/helm-schema themselves associate comments with keys in this
    chart's block-style values files.
    """
    stack = []  # [(indent, key), ...] — current path down to the last key seen
    pending = []  # comment lines collected since the last non-comment line
    found = set()
    in_block = False
    block_indent = -1
    for raw_line in text.splitlines():
        if in_block:
            leading = len(raw_line) - len(raw_line.lstrip(" "))
            if raw_line.strip() == "" or leading > block_indent:
                continue  # still inside a literal/folded block scalar's body
            in_block = False

        if not raw_line.strip():
            pending = []
            continue

        m = COMMENT_RE.match(raw_line)
        if m:
            pending.append(m.group("text").strip())
            continue

        m = KEY_RE.match(raw_line)
        if not m:
            pending = []
            continue

        indent = len(m.group("indent"))
        is_list_item = raw_line[len(m.group("indent")):].startswith("- ")
        key = m.group("key").strip("\"'")
        while stack and stack[-1][0] >= indent:
            stack.pop()
        path = ".".join([k for _, k in stack] + [key])

        marker_lines = [line for line in pending if line.startswith(marker)]
        if marker_lines and (pattern is None or pattern.search(" ".join(marker_lines))):
            found.add(path)
        pending = []

        if not is_list_item:
            stack.append((indent, key))

        rest = raw_line[m.end():].strip()
        if rest in BLOCK_SCALAR_TOKENS:
            in_block = True
            block_indent = indent

    return found


def equal(a, b):
    # Be strict about bools (True == 1 in Python) but lenient about int/float.
    if isinstance(a, bool) or isinstance(b, bool):
        return isinstance(a, bool) and isinstance(b, bool) and a == b
    if isinstance(a, (int, float)) and isinstance(b, (int, float)):
        return a == b
    return a == b


def diff(defaults, example, path, errors, skip):
    if path in skip:
        return
    if not isinstance(defaults, dict):
        if not equal(defaults, example):
            errors.append(
                f"  {path}: values.yaml has {defaults!r} but the example has {example!r}"
            )
        return
    if not isinstance(example, dict):
        errors.append(f"  {path}: mapping in values.yaml but {example!r} in the example")
        return
    for key, value in defaults.items():
        child = f"{path}.{key}" if path else str(key)
        if child in skip:
            continue
        if key not in example:
            errors.append(f"  {child}: in values.yaml but missing from the example")
            continue
        diff(value, example[key], child, errors, skip)


def check_chart(chart_dir):
    defaults_text = (chart_dir / "values.yaml").read_text()
    example_text = (chart_dir / "values.example.yaml").read_text()
    defaults = yaml.safe_load(defaults_text)
    example = yaml.safe_load(example_text)

    opaque = marked_paths(example_text, "@schema", OPAQUE_RE)
    ignored = marked_paths(defaults_text, "@sync-ignore")
    skip = opaque | ignored

    errors = []
    diff(defaults, example, "", errors, skip)
    for key in example:
        if key not in defaults:
            errors.append(
                f"  {key}: documented in the example but missing from values.yaml"
                " (add it with its fallback default)"
            )
    return errors


def main():
    if len(sys.argv) > 1:
        charts = [Path(a) for a in sys.argv[1:]]
    else:
        stable = Path(__file__).resolve().parent.parent / "stable"
        charts = sorted(
            d
            for d in stable.iterdir()
            if (d / "values.yaml").is_file() and (d / "values.example.yaml").is_file()
        )
    failed = False
    for chart in charts:
        errors = check_chart(chart)
        if errors:
            failed = True
            print(f"{chart}:")
            print("\n".join(errors))
        else:
            print(f"{chart}: values.yaml and values.example.yaml are in sync")
    if failed:
        print(
            "\nvalues.example.yaml must mirror values.yaml defaults"
            " (see scripts/check-values-sync.py)."
        )
        sys.exit(1)


if __name__ == "__main__":
    main()
