#!/usr/bin/env python3
"""Scan installed skills and report which MCP servers they need but aren't configured.

Two independent things happen here:

1. Enumerate installed skills across every scope (project / user / plugin) and, for
   each one, collect the MCP servers it *declares* it needs. The strong, machine
   readable signal is a literal ``mcp__<server>__<tool>`` reference anywhere in the
   skill's files -- that is the convention this skill nudges authors toward. A skill
   may also reference an MCP by bare tool name (e.g. ``search_graph``); those can't be
   detected reliably by regex, so an optional alias file maps such hints to a server.

2. Enumerate every MCP server that is actually configured, from all the config layers
   Claude Code reads, tagged with the scope they came from.

The report is the diff: for each skill, which declared servers are NOT configured.

Everything is print-only; nothing is modified. Run with --json for machine output.
"""
from __future__ import annotations

import argparse
import json
import os
import re
import sys
from pathlib import Path

HOME = Path.home()
MCP_REF = re.compile(r"mcp__([A-Za-z0-9_.-]+)__")


def load_json(path: Path):
    try:
        with path.open() as f:
            return json.load(f)
    except (OSError, json.JSONDecodeError):
        return None


# --------------------------------------------------------------------------- skills

def skill_dirs(project: Path):
    """Yield (scope, skill_dir) for every installed skill, most-local scope first."""
    seen = set()
    roots = [
        ("project", project / ".claude" / "skills"),
        ("user", HOME / ".claude" / "skills"),
    ]
    # Plugin-bundled skills live under the plugin cache/marketplace trees.
    plugin_root = HOME / ".claude" / "plugins"
    for base in (plugin_root / "cache", plugin_root / "marketplaces"):
        if base.is_dir():
            for skill_md in base.glob("**/skills/*/SKILL.md"):
                roots.append(("plugin", skill_md.parent.parent))

    for scope, root in roots:
        if not root.is_dir():
            continue
        # A skills root holds one dir per skill; a plugin entry is already the dir.
        candidates = [root] if (root / "SKILL.md").exists() else sorted(root.iterdir())
        for d in candidates:
            if not d.is_dir() or not (d / "SKILL.md").exists():
                continue
            real = d.resolve()
            if real in seen:
                continue
            seen.add(real)
            yield scope, d


def declared_servers(skill_dir: Path, aliases: dict) -> tuple[set, set]:
    """Return (from_mcp_refs, from_aliases) server-name sets declared by a skill."""
    refs, alias_hits = set(), set()
    for f in skill_dir.rglob("*"):
        if not f.is_file() or f.suffix.lower() not in {".md", ".txt", ".json", ".py", ".sh", ".js", ".ts"}:
            continue
        try:
            text = f.read_text(errors="ignore")
        except OSError:
            continue
        refs.update(MCP_REF.findall(text))
        # Alias hits: a bare tool/keyword that a skill uses maps to a server.
        for needle, server in aliases.items():
            if needle.startswith("_"):  # skip _comment and other metadata keys
                continue
            if needle in text:
                alias_hits.add(server)
    return refs, alias_hits


# --------------------------------------------------------------------------- configured MCP

def configured_servers(project: Path) -> dict:
    """Map server-name -> list of scopes it is configured in."""
    out: dict[str, list] = {}

    def add(name, scope):
        out.setdefault(name, [])
        if scope not in out[name]:
            out[name].append(scope)

    # Project / team scope: .mcp.json checked into the repo.
    for p in (project / ".mcp.json", project / ".claude" / ".mcp.json"):
        data = load_json(p)
        if data:
            for name in data.get("mcpServers", {}):
                add(name, "project(.mcp.json)")

    # User config: global servers + per-project servers.
    user_cfg = load_json(HOME / ".claude.json") or {}
    for name in user_cfg.get("mcpServers", {}):
        add(name, "user(global)")
    proj_entry = user_cfg.get("projects", {}).get(str(project), {})
    for name in proj_entry.get("mcpServers", {}):
        add(name, "user(this-project)")

    # Enterprise / managed config, if present (macOS path).
    managed = load_json(Path("/Library/Application Support/ClaudeCode/managed-mcp.json"))
    if managed:
        for name in managed.get("mcpServers", {}):
            add(name, "managed")

    # Plugin-bundled MCP servers.
    plugin_root = HOME / ".claude" / "plugins"
    for mcp_json in plugin_root.glob("cache/**/.mcp.json"):
        data = load_json(mcp_json)
        if data:
            for name in data.get("mcpServers", {}):
                add(name, "plugin")

    return out


# --------------------------------------------------------------------------- report

def main():
    ap = argparse.ArgumentParser(description=__doc__)
    ap.add_argument("--project", default=os.getcwd(), help="project root (default: cwd)")
    ap.add_argument("--aliases", help="JSON file mapping a bare tool/keyword -> server name")
    ap.add_argument("--json", action="store_true", help="emit machine-readable JSON")
    ap.add_argument("--include-plugins", action="store_true",
                    help="also analyze plugin-bundled skills (noisy; off by default)")
    args = ap.parse_args()

    project = Path(args.project).resolve()
    aliases = {}
    # Ship a default alias file next to this script if the user didn't pass one.
    alias_path = Path(args.aliases) if args.aliases else Path(__file__).parent / "aliases.json"
    if alias_path.exists():
        aliases = load_json(alias_path) or {}

    configured = configured_servers(project)
    configured_names = set(configured)

    # This skill documents mcp__… patterns as examples; scanning itself would
    # report those examples as real dependencies, so skip our own directory.
    self_skill = Path(__file__).resolve().parent.parent

    skills = []
    for scope, d in skill_dirs(project):
        if scope == "plugin" and not args.include_plugins:
            continue
        if d.resolve() == self_skill:
            continue
        refs, alias_hits = declared_servers(d, aliases)
        required = refs | alias_hits
        missing = sorted(s for s in required if s not in configured_names)
        skills.append({
            "name": d.name,
            "scope": scope,
            "path": str(d),
            "required": sorted(required),
            "from_mcp_refs": sorted(refs),
            "from_aliases": sorted(alias_hits),
            "missing": missing,
        })

    all_missing = sorted({m for s in skills for m in s["missing"]})

    if args.json:
        print(json.dumps({
            "project": str(project),
            "configured": configured,
            "skills": skills,
            "missing_servers": all_missing,
        }, indent=2))
        return

    print(f"Project: {project}\n")

    print("Configured MCP servers:")
    if configured:
        for name in sorted(configured):
            print(f"  ✓ {name}  [{', '.join(configured[name])}]")
    else:
        print("  (none)")
    print()

    print("Installed skills:")
    for s in skills:
        need = ", ".join(s["required"]) if s["required"] else "no MCP declared"
        flag = "  ⚠ MISSING: " + ", ".join(s["missing"]) if s["missing"] else ""
        print(f"  • {s['name']} [{s['scope']}] — {need}{flag}")
    print()

    if all_missing:
        print("Missing MCP servers (declared by a skill, not configured):")
        for m in all_missing:
            users = [s["name"] for s in skills if m in s["missing"]]
            print(f"  ✗ {m}  (needed by: {', '.join(users)})")
        print("\nNote: skills that reference MCP tools only by bare name (not the")
        print("mcp__server__tool form) may not be detected. Read those SKILL.md files")
        print("to confirm, and add mappings to scripts/aliases.json to catch them next time.")
    else:
        print("✓ Every declared MCP dependency is configured.")


if __name__ == "__main__":
    main()
