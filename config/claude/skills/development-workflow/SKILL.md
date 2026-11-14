---
name: development-workflow
description: Use when opening a planned run for a code change that spans several domains or needs more than one sitting. Small and single-domain changes are done inline without it.
---

# Development Workflow

The map of a planned run. Each stage has its own skill; read it when you get
there. Run continuously between the two user gates (✋).

## When a run, when inline

Triage: CLAUDE.md → Workflow.

## The run

| # | Stage | Skill | State after | Gate |
|---|-------|-------|-------------|------|
| 1 | Plan | writing-plans (red-team for 2+ tasks) | `stage=plan plan=<path>` | ✋ approve the plan ("go") |
| 2 | Isolate | using-git-worktrees | `stage=isolate worktree= branch= base=` | — |
| 3 | Implement | executing-plans | `stage=implement`, one ledger entry per task | — |
| 4 | Review | requesting-code-review (branch-reviewer) | `task branch-review done` | — |
| 5 | Finish | finishing-a-development-branch | `stage=finish`, then `clear` | ✋ merge + push / PR / keep / discard |

Bootstrap, once per project with no living spec: writing-specs. Not a run.

Always on, any stage: CLAUDE.md "Before writing" and
`executing-plans/writing-good-tests.md` for what gets a test and when,
systematic-debugging for any bug or unexpected result, requesting-code-review
§3 when acting on findings.

## Run state

The run lives in a file, not in your memory:

```bash
~/.claude/hooks/flow-state init <task-slug>     # opening the run
~/.claude/hooks/flow-state set stage=plan plan=<abs path>
~/.claude/hooks/flow-state show                 # resuming: where am I?
~/.claude/hooks/flow-state clear                # run finished
```

One file per repository (`<main-checkout>/.flow/run/state.json`), shared by
every worktree. On "kontynuuj", after `/clear` or after compaction: `flow-state show` and
`git log` over recollection — re-enter the recorded worktree, resume at the
first task not marked done.

## Rules

- **Run continuously between gates.** The approved plan is the instruction.
  Stop only at a gate, on a blocker you cannot resolve, on ambiguity the plan
  does not settle, or when the context check after a task asks for `/clear` +
  "kontynuuj".

## `.flow/`

Committed: `plans/`, `specs/`, `design/`, `probes/`, `reviews/`. Ignored:
`run/` — the run state and review packages, in the main checkout only.

## Models

The session model plans, implements and debugs. Each agent's model and effort
live in its definition's frontmatter: `branch-reviewer` and `plan-red-team`
run on Opus. A reviewer is at least as strong as what it reviews.
