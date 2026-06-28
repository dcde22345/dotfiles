---
name: develop-guide
description: Ticket-driven development workflow for yh_web and other projects under hank_tsai
type: skill
---

# Development Guide

## Before Contributing to Any Project

1. Check if an `AGENTS.md` exists in the project root.
2. If it exists, read it fully and follow all instructions.
3. If it references additional guideline files (e.g. `agent/insforge.md`), read those too.

---

## Ticket-Driven Development Workflow

### Step 1 — Fetch tickets from Plane

```
list_work_items(pql='stateGroup IN openStates()')
```

Retrieve the full description of each candidate ticket before starting work.

---

### Step 2 — Decide whether to fork a subagent

Apply this logic for **each** ticket:

| Ticket state | Branch `feat/{project}-{id}-*` exists? | Action |
|---|---|---|
| In Progress | Yes | **Leave alone** — a fork is already on it |
| In Progress | No | **Fork a subagent** — ticket is stale/unassigned |
| Todo / Backlog | Has description | **Fork a subagent** |
| Todo / Backlog | No description | **Skip** — cannot implement without a spec |
| Done / Cancelled | — | **Skip** |

To check for an existing branch:
```bash
git branch -a | grep -i "feat/.*-{sequence_id}-"
```

---

### Step 3 — Fork subagents

Spawn one background subagent per actionable ticket. Each subagent prompt must include:

1. Instruction to read the project `AGENTS.md` and all referenced guideline files first.
2. Full ticket description and acceptance criteria.
3. List of existing files to read before editing.
4. Layer-by-layer implementation order: `migration → service → API → UI`.
5. Instruction to push the branch and open a PR when done.

Use naming convention: `feat/{project-identifier}-{sequence_id}-{short-slug}`
Example: `feat/yhgame-45-cdkey-security-phase1`

---

### Step 4 — Monitor and recover

- Wait for completion notifications (`<task-notification>`).
- On completion, run `git status` and `git log` to verify what was actually committed.
- If an agent died mid-flight:
  1. Separate partial changes onto the correct branch.
  2. Fix any failing tests before committing.
  3. Resume via `SendMessage` with a clear "already done / remaining work" briefing.

---

### Step 5 — Review

Once a PR exists, use the `/review` or `/code-review` skill to review it.
