---
description: Root agent guidelines for all projects under hank_tsai
globs: *
alwaysApply: true
---

# Agent Guidelines

## Before Contributing to Any Project

Before writing any code or making any changes to a project, you **MUST**:

1. Check if an `AGENTS.md` file exists in the project root.
2. If it exists, read it fully and follow all instructions within it.
3. If it references additional guideline files (e.g. `agent/insforge.md`), read those as well.

## Skills & Guides

| Guide | Skills | When to use |
|-------|------|-------------|
| Development workflow | [`develop-guide`](develop-guide.md) | Picking up tickets, forking subagents, recovering from failures, reviewing PRs |

## Projects

| Project | Path |
|---------|------|
| yh_web | `yh_web.worktrees/yh_web/` |

<!-- codebase-memory-mcp:start -->
# Codebase Knowledge Graph (codebase-memory-mcp)

This project uses codebase-memory-mcp to maintain a knowledge graph of the codebase.
ALWAYS prefer MCP graph tools over grep/glob/file-search for code discovery.

## Priority Order

1. `search_graph` — find functions, classes, routes, variables by pattern
2. `trace_path` — trace who calls a function or what it calls
3. `get_code_snippet` — read specific function/class source code
4. `query_graph` — run Cypher queries for complex patterns
5. `get_architecture` — high-level project summary

## When to fall back to grep/glob

- Searching for string literals, error messages, config values
- Searching non-code files (Dockerfiles, shell scripts, configs)
- When MCP tools return insufficient results

## Examples

- Find a handler: `search_graph(name_pattern=".*OrderHandler.*")`
- Who calls it: `trace_path(function_name="OrderHandler", direction="inbound")`
- Read source: `get_code_snippet(qualified_name="pkg/orders.OrderHandler")`
<!-- codebase-memory-mcp:end -->
