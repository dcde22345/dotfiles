---
name: setup
description: Audit installed skills and report which MCP servers they need but aren't configured. Use this whenever the user wants to set up their environment, check that skills will actually work, onboard a machine, verify MCP dependencies, or asks things like "掃過我裝的 skill"、"which MCPs am I missing"、"why isn't my skill working"、"setup"、"check my skills". Run it after cloning the dotfiles onto a new machine or after adding a skill that depends on an MCP server.
---

# Setup — Skill ↔ MCP Dependency Audit

A skill that calls MCP tools silently does nothing useful if that MCP server
isn't configured on this machine — the tools just aren't there. This skill finds
that gap: it scans every installed skill, works out which MCP servers each one
needs, compares against what's actually configured, and reports what's missing.

## How to run it

```bash
python3 .claude/skills/setup/scripts/scan.py --project "$(pwd)"
```

The default scan covers **project** (`.claude/skills/`) and **user**
(`~/.claude/skills/`) skills — the ones the user installed. Useful flags:

- `--include-plugins` — also audit plugin-bundled skills (noisy; only when asked)
- `--json` — machine-readable output, for piping into further checks
- `--aliases <file>` — override the bare-tool→server map (see below)

Run the script first, then read its output back to the user in plain language:
which servers are configured, which skills need what, and — the point of the
exercise — which servers are declared by a skill but not configured anywhere.

## How dependencies are detected

The script uses two signals, because skills declare MCP needs two ways:

1. **Literal `mcp__<server>__<tool>` references** — the reliable signal. Any skill
   file mentioning e.g. `mcp__codebase-memory-mcp__search_graph` clearly needs the
   `codebase-memory-mcp` server. This is the convention to prefer.

2. **Bare tool names** — some skills reference MCP tools by their short name
   (`search_graph`, `trace_path`) without the `mcp__…__` prefix. Regex can't tell
   those apart from ordinary prose, so `scripts/aliases.json` maps known bare names
   to their server. When you discover a skill that needs a server the script didn't
   catch, add the mapping there so the next scan finds it.

Because signal #2 is inherently incomplete, treat the script as a first pass. If a
skill reports "no MCP declared" but you know from its SKILL.md that it drives an
MCP, say so and offer to add an alias entry.

## Where MCP servers are configured

The script reads every layer Claude Code merges, so you can tell the user *where*
to add a missing server. From most-shared to most-local:

| Scope | File | Notes |
|-------|------|-------|
| Project / team | `<project>/.mcp.json` or `<project>/.claude/.mcp.json` | Checked into git; shared with teammates |
| User global | `~/.claude.json` → `mcpServers` | All projects for this user |
| User, this project | `~/.claude.json` → `projects.<path>.mcpServers` | This project only, not shared |
| Managed | `/Library/Application Support/ClaudeCode/managed-mcp.json` | Enterprise-provisioned |
| Plugin | plugin's bundled `.mcp.json` | Ships with an installed plugin |

## Acting on the result

When a server is missing, help the user add it — don't just report and stop:

- If the skill's docs (its SKILL.md / README) name the exact server command, add
  it to the right config layer. For a skill that lives in these dotfiles and should
  work for teammates too, prefer the project `.claude/.mcp.json` so it travels with
  the repo. For something machine-specific (a local binary path, a personal token),
  prefer the user layer.
- Never write secrets (tokens, keys) into a repo-tracked `.mcp.json`. Use an env var
  or the user-scoped config, per the coding security policy.
- After editing config, tell the user MCP servers load at Claude Code startup, so
  they'll need to restart the session for the new server to appear.

## Example

**Input:** "setup — check my skills are ready to go"

**Output:** Run the scan, then summarize, e.g.:

> Scanned 4 skills. `codebase-memory` needs `codebase-memory-mcp` — configured
> (user global + project). The other three declare no MCP dependency. ✓ Nothing
> missing; you're ready.

Or, when something is missing:

> `develop-guide` references `mcp__plane__*` but no `plane` server is configured in
> any layer. Add it to `.claude/.mcp.json` (shared) or `~/.claude.json` (just you).
> Want me to add it? I'll need the server command.
